%% Initialization
clear all
fclose all;
clc

%% User inputs
% Choose the year, month, day
% Choice for the year is 2011
% Choices for the month are 6 and 7
% Choices for the day for June
% 19, 20, 24, 25, 26, 27, 30
% Choices for the day for July
% 01, 02, 05
procYear = 2011;
procMonth = 6;
procDay = 20;

% Select the height range for plotting. We will use AGL
heightLim = [0 1500];
% Select the station height. Can we get this from the data?
heightStation_m = 610; 

% Select the heights for wind averaging and comparison and set up a new
% height coordinate
heightMin_m = 50;
heightMax_m = 1500;
heightStep_m = 50;
heightGrid_m = heightMin_m: heightStep_m: heightMax_m;
nGridHeights = length(heightGrid_m);

% Time interval lee way
timeDel_s = 30;
timeDel = timeDel_s/24/60/60; % in Matlab time

% Base directory name
baseDirName = '/Users/JennyHandsley/Documents/Oklahoma/CLOUD MAP/GitHub/windAnalysis/BLLAST/';

%% Read Sumo data
% Data are processed later
dataDirName = [ baseDirName 'SUMOData/' ];
fileName = sprintf('%4.4d%2.2d%2.2dSUMOBLLAST.mat', procYear, procMonth, procDay);
if exist([ dataDirName fileName ], 'file')
    load([ dataDirName fileName]);
else
    fprintf('*** SUMO data not found ... exiting!\n')
    return
end

%% Read tethersonde data
dataDirName = [ baseDirName 'TetheredBalloonsData/' ];
str = sprintf('%sMF-tethersonde_1Hz-full_%4.4d%2.2d%2.2d*', ...
    dataDirName, procYear, procMonth, procDay);
d = dir(str);
fileName = d(1).name;
fp = fopen([ dataDirName fileName ], 'rt');
for j = 1: 20
    fgetl(fp);
end
str = fgetl(fp);
launchHour = str2double(str(30:31));
launchMinute = str2double(str(32:33));
launchSecond = str2double(str(34:35));
str = fgetl(fp);
landHour = str2double(str(29:30));
landMinute = str2double(str(31:32));
landSecond = str2double(str(33:34));
while ~feof(fp)
    dataArr = fscanf(fp, '%f', [7, inf]);
end
fclose(fp);

%% Pack the tethersonde data into an array
dataArr(dataArr == 65535) = NaN;
tetherSonde.obsTime = datenum(procYear, procMonth, procDay) + ...
    dataArr(1, :)/86400;
tetherSonde.height_m = dataArr(2, :) - heightStation_m;
tetherSonde.pressure_hPa = dataArr(3, :);
tetherSonde.temperature_C = dataArr(4, :);
tetherSonde.relativeHumidity_perCent = dataArr(5, :);
tetherSonde.windDirection_deg = dataArr(6, :);
tetherSonde.windSpeed_mps = dataArr(7, :);
tetherSonde.u_mps = tetherSonde.windSpeed_mps.*sind(tetherSonde.windDirection_deg + 180);
tetherSonde.v_mps = tetherSonde.windSpeed_mps.*cosd(tetherSonde.windDirection_deg + 180);

%% Process data
nFlights = length(sumoData);
% Create vector of flags to stating if wind comparison was made for a flight
windCompareFlag = zeros(nFlights, 1);
% Allocate memory for the gridded (averaged) data
sumoGrid.uAsc_mps = nan(nFlights, nGridHeights);
sumoGrid.uDes_mps = nan(nFlights, nGridHeights);
sumoGrid.vAsc_mps = nan(nFlights, nGridHeights);
sumoGrid.vDes_mps = nan(nFlights, nGridHeights);
sumoGrid.height_m = heightGrid_m;
tetherSondeGrid.uAsc_mps = nan(nFlights, nGridHeights);
tetherSondeGrid.uDes_mps = nan(nFlights, nGridHeights);
tetherSondeGrid.vAsc_mps = nan(nFlights, nGridHeights);
tetherSondeGrid.vDes_mps = nan(nFlights, nGridHeights);
tetherSondeGrid.height_m = heightGrid_m;

% Begin creating the parameter data
paramGrid.procYear = procYear;
paramGrid.procMonth = procMonth;
paramGrid.procDay = procDay;
paramGrid.nFlights = nFlights;
paramGrid.timeDel_s = timeDel_s;
paramGrid.heightStep_m = heightStep_m;

% Go through all sumo flight data
for iFlight = 1: nFlights
    % check if flight is profile or not
    fprintf('Flight %d of %d\n', iFlight, nFlights)
    if ~strcmp(sumoData(iFlight).a_type, 'profile')
        fprintf('*** No profile data for this flight ... skipping!\n')
        paramGrid.begTime(iFlight) = NaN;
        paramGrid.endTime(iFlight) = NaN;
        paramGrid.begTimeAsc(iFlight) = NaN;
        paramGrid.endTimeAsc(iFlight) = NaN;
        paramGrid.begTimeDes(iFlight) = NaN;
        paramGrid.endTimeDes(iFlight) = NaN;
    else
        % Get the start and stop times for the flight
        begTime = sumoData(iFlight).time(1);
        endTime = sumoData(iFlight).time(end);
        paramGrid.begTime(iFlight) = begTime;
        paramGrid.endTime(iFlight) = endTime;
        fprintf('Evaluation period: %s - %s\n', datestr(begTime), datestr(endTime))
        % check if tethersonde data exists for this profile flight
        indSonde = find(begTime <= tetherSonde.obsTime & tetherSonde.obsTime <= endTime);
        if isempty(indSonde)
            fprintf('*** No corresponding tethersonde data found ...skipping\n')
            paramGrid.begTimeAsc(iFlight) = NaN;
            paramGrid.endTimeAsc(iFlight) = NaN;
            paramGrid.begTimeDes(iFlight) = NaN;
            paramGrid.endTimeDes(iFlight) = NaN;
        elseif 10*length(sumoData(iFlight).WSS) + 1 > length(sumoData(iFlight).time)
                fprintf('*** Problem finding times for wind data ... skipping\n')
                paramGrid.begTimeAsc(iFlight) = NaN;
                paramGrid.endTimeAsc(iFlight) = NaN;
                paramGrid.begTimeDes(iFlight) = NaN;
                paramGrid.endTimeDes(iFlight) = NaN;
        else
            windCompareFlag(iFlight) = 1;
            % -------------------------------------
            % Position data with correspondig time
            % -------------------------------------
            sumo.x_m = sumoData(iFlight).NAV_x;
            sumo.y_m = sumoData(iFlight).NAV_y;
            sumo.z_m = sumoData(iFlight).GPS_alt_fixed;
            sumo.time = sumoData(iFlight).time;
            % -----------------------------------------------------
            % Thermodynamic data with corresponding time and height
            % -----------------------------------------------------
            % Thermo heights are the same as position height
            % Thermo times are the same as for position
            sumo.pressure_Pa = sumoData(iFlight).SCP_P;
            sumo.temperature_C = sumoData(iFlight).SHT_T;
            sumo.relativeHumidity_perCent = sumoData(iFlight).SHT_RH;
            % ---------------------------------------------
            % Wind data with corresponding time and height
            % ---------------------------------------------
            sumo.windSpeed_mps = sumoData(iFlight).WSS;
            sumo.windDirection_deg = sumoData(iFlight).WDD;
            sumo.u_mps = sumo.windSpeed_mps.*sind(sumo.windDirection_deg + 180);
            sumo.v_mps = sumo.windSpeed_mps.*cosd(sumo.windDirection_deg + 180);
            sumo.windHeight_m = sumoData(iFlight).W_alt;
            % Not sure why this works, but it seems to give an estimate of
            % the time the wind data were collected
            nWind = length(sumoData(iFlight).WSS);
            ind = 1: 10: 10*(nWind - 1) + 1;
            sumo.windTime = sumoData(iFlight).time(ind);
            % ---------------------------------------------------
            % separate the sumo wind data by up and down legs
            % ---------------------------------------------------
            % Find the indices for the up and down legs (wind)
            nHeightsAsc = length(sumoData(iFlight).W_alt_asc);
            nHeightsDes = length(sumoData(iFlight).W_alt_des);
            indAsc = 1: nHeightsAsc;
            indDes = nHeightsAsc + (1: nHeightsDes);
            % Create the new asc & des parameters
            sumo.windSpeedAsc_mps = sumo.windSpeed_mps(indAsc);
            sumo.windSpeedDes_mps = sumo.windSpeed_mps(indDes);
            sumo.windDirectionAsc_mps = sumo.windDirection_deg(indAsc);
            sumo.windDirectionDes_mps = sumo.windDirection_deg(indDes);
            sumo.uAsc_mps = sumo.u_mps(indAsc);
            sumo.uDes_mps = sumo.u_mps(indDes);
            sumo.vAsc_mps = sumo.v_mps(indAsc);
            sumo.vDes_mps = sumo.v_mps(indDes);
            sumo.windHeightAsc_m = sumo.windHeight_m(indAsc);
            sumo.windHeightDes_m = sumo.windHeight_m(indDes);
            sumo.windTimeAsc = sumo.windTime(indAsc);
            sumo.windTimeDes = sumo.windTime(indDes);
            paramGrid.begTimeAsc(iFlight) = sumo.windTimeAsc(1);
            paramGrid.endTimeAsc(iFlight) = sumo.windTimeAsc(end);
            paramGrid.begTimeDes(iFlight) = sumo.windTimeDes(1);
            paramGrid.endTimeDes(iFlight) = sumo.windTimeDes(end);
            % Calculate the gridded data
            for iHeight = 1: nGridHeights
                % Ascent
                ind1 = find(heightGrid_m(iHeight) - heightStep_m/2 <= sumo.windHeightAsc_m & ...
                    sumo.windHeightAsc_m <= heightGrid_m(iHeight) + heightStep_m/2);
                if ~isempty(ind1)
                    sumoGrid.uAsc_mps(iFlight, iHeight) = nanmean(sumo.uAsc_mps(ind1));
                    sumoGrid.vAsc_mps(iFlight, iHeight) = nanmean(sumo.vAsc_mps(ind1));
                    t1 = sumo.windTimeAsc(ind1(1));
                    t2 = sumo.windTimeAsc(ind1(end));
                    ind2 = find(heightGrid_m(iHeight) - heightStep_m/2 <= tetherSonde.height_m & ...
                        tetherSonde.height_m <= heightGrid_m(iHeight) + heightStep_m/2 & ...
                        t1 - timeDel <= tetherSonde.obsTime & tetherSonde.obsTime <= t2 + timeDel);
                    if ~isempty(ind2)
                        tetherSondeGrid.uAsc_mps(iFlight, iHeight) = nanmean(tetherSonde.u_mps(ind2));
                        tetherSondeGrid.vAsc_mps(iFlight, iHeight) = nanmean(tetherSonde.v_mps(ind2));
                    end
                end
                % Descent
                ind1 = find(heightGrid_m(iHeight) - heightStep_m/2 <= sumo.windHeightDes_m & ...
                    sumo.windHeightDes_m <= heightGrid_m(iHeight) + heightStep_m/2);
                if ~isempty(ind1)
                    sumoGrid.uDes_mps(iFlight, iHeight) = nanmean(sumo.uDes_mps(ind1));
                    sumoGrid.vDes_mps(iFlight, iHeight) = nanmean(sumo.vDes_mps(ind1));
                    t1 = sumo.windTimeDes(ind1(1));
                    t2 = sumo.windTimeDes(ind1(end));
                    ind2 = find(heightGrid_m(iHeight) - heightStep_m/2 <= tetherSonde.height_m & ...
                        tetherSonde.height_m <= heightGrid_m(iHeight) + heightStep_m/2 & ...
                        t1 <= tetherSonde.obsTime & tetherSonde.obsTime <= t2);
                    if ~isempty(ind2)
                        tetherSondeGrid.uDes_mps(iFlight, iHeight) = nanmean(tetherSonde.u_mps(ind2));
                        tetherSondeGrid.vDes_mps(iFlight, iHeight) = nanmean(tetherSonde.v_mps(ind2));
                    end
                end
            end
            plotFlag = 0;
            if plotFlag
            % -------
            figure(1)
            % -------
            clf
            plot(sumo.time, sumo.z_m, '-b')
            hold on
            plot(sumo.windTime, sumo.windHeight_m, '-r')
            set(gca, 'ylim', heightLim)
            datetick('x', 13)
            shg
            % -------
            figure(11)
            % -------
            clf
            plot3(sumo.x_m, sumo.y_m, sumo.z_m)
            set(gca, 'zlim', heightLim)
            xlabel('Zonal direction (m)')
            ylabel('Meridional direction (m)')
            zlabel('Height (m)')
            title([datestr(begTime) ' - ' datestr(endTime)])
            shg
            % -------
            figure(12)
            % -------
            clf
            subplot(1, 2, 1)
            plot(sumo.uAsc_mps, sumo.windHeightAsc_m, '-*r')
            hold on
            plot(sumo.uDes_mps, sumo.windHeightDes_m, '-*b')
            plot(tetherSonde.u_mps(indSonde), tetherSonde.height_m(indSonde), 'ko')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('u (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumo.vAsc_mps, sumo.windHeightAsc_m, '-*r')
            hold on
            plot(sumo.vDes_mps, sumo.windHeightDes_m, '-*b')
            plot(tetherSonde.v_mps(indSonde), tetherSonde.height_m(indSonde), 'ko')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('v (m/s)')
            ylabel('Height (m)')
            shg
            % -------
            figure(13)
            % -------
            clf
            subplot(1, 2, 1)
            plot(sumoGrid.uAsc_mps(iFlight, :), sumoGrid.height_m, '-*r')
            hold on
            plot(sumoGrid.uDes_mps(iFlight, :), sumoGrid.height_m, '-*b')
            plot(tetherSondeGrid.uAsc_mps(iFlight, :), tetherSondeGrid.height_m, '^', ...
                'markersize', 8, 'markerfacecolor', 'k')
            plot(tetherSondeGrid.uDes_mps(iFlight, :), tetherSondeGrid.height_m, 'v', ...
                'markersize', 8, 'markerfacecolor', 'k')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('u (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumoGrid.vAsc_mps(iFlight, :), sumoGrid.height_m, '-*r')
            hold on
            plot(sumoGrid.vDes_mps(iFlight, :), sumoGrid.height_m, '-*b')
            plot(tetherSondeGrid.vAsc_mps(iFlight, :), tetherSondeGrid.height_m, '^', ...)
                'markersize', 8, 'markerfacecolor', 'k')
            plot(tetherSondeGrid.vDes_mps(iFlight, :), tetherSondeGrid.height_m, 'v', ...)
                'markersize', 8, 'markerfacecolor', 'k')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('v (m/s)')
            ylabel('Height (m)')
            shg
            % -------
            figure(14)
            % -------
            clf
            subplot(1, 2, 1)
            plot(sumo.temperature_C, sumo.z_m, '-*b')
            set(gca, 'xlim', [0 30])
            set(gca, 'ylim', heightLim)
            xlabel('Temperature (C)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumo.relativeHumidity_perCent, sumo.z_m, '-*b')
            set(gca, 'xlim', [0 100])
            set(gca, 'ylim', heightLim)
            xlabel('RH (%)')
            ylabel('Height (m)')
            shg
            reply = input('Press RETURN to continue (q to quit): ', 's');
            if upper(reply) == 'Q', break, end
            end
        end
    end
end

RMSD.uAsc = nan(1, nFlights);
RMSD.vAsc = nan(1, nFlights);
RMSD.uDes = nan(1, nFlights);
RMSD.vDes = nan(1, nFlights);
CV.uAsc = nan(1, nFlights);
CV.vAsc = nan(1, nFlights);
CV.uDes = nan(1, nFlights);
CV.vDes = nan(1, nFlights);

for iFlight = 1: nFlights
    RMSD.uAsc(iFlight) = sqrt(nanmean((sumoGrid.uAsc_mps(iFlight, :)-tetherSondeGrid.uAsc_mps(iFlight, :)).^2));
    CV.uAsc(iFlight) = abs(RMSD.uAsc(iFlight)/nanmean((sumoGrid.uAsc_mps(iFlight, :)+tetherSondeGrid.uAsc_mps(iFlight, :))/2));
    RMSD.vAsc(iFlight) = sqrt(nanmean((sumoGrid.vAsc_mps(iFlight, :)-tetherSondeGrid.vAsc_mps(iFlight, :)).^2));
    CV.vAsc(iFlight) = abs(RMSD.vAsc(iFlight)/nanmean((sumoGrid.vAsc_mps(iFlight, :)+tetherSondeGrid.vAsc_mps(iFlight, :))/2));
    RMSD.uDes(iFlight) = sqrt(nanmean((sumoGrid.uDes_mps(iFlight, :)-tetherSondeGrid.uDes_mps(iFlight, :)).^2));
    CV.uDes(iFlight) = abs(RMSD.uDes(iFlight)/nanmean((sumoGrid.uDes_mps(iFlight, :)+tetherSondeGrid.uDes_mps(iFlight, :))/2));
    RMSD.vDes(iFlight) = sqrt(nanmean((sumoGrid.vDes_mps(iFlight, :)-tetherSondeGrid.vDes_mps(iFlight, :)).^2));
    CV.vDes(iFlight) = abs(RMSD.vDes(iFlight)/nanmean((sumoGrid.vDes_mps(iFlight, :)+tetherSondeGrid.vDes_mps(iFlight, :))/2));
end

paramGrid.windCompareFlag = windCompareFlag;
