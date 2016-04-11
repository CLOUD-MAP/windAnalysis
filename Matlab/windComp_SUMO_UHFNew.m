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
procDay = 30;

% Select the height range for plotting. We will use AGL
heightLim = [0 1500];
% Select the station height. Can we get this from the data?
heightStation_m = 610; 

% Select the heights for wind averaging and comparison and set up a new
% height coordinate
heightMin_m = 770 - heightStation_m;
heightMax_m = 4970 - heightStation_m;
heightStep_m = 75;
heightGrid_m = heightMin_m: heightStep_m: heightMax_m;
nGridHeights = length(heightGrid_m);

% Base directory name
baseDirName = '/Users/chilson/Matlab/CLOUDMAP/windAnalysis/BLLAST/';

%% Read Sumo data
% Read SUMO
dataDirName = [ baseDirName 'SUMOData/' ];
fileName = sprintf('%4.4d%2.2d%2.2dSUMOBLLAST.mat', procYear, procMonth, procDay);
if exist([ dataDirName fileName ], 'file')
    load([ dataDirName fileName]);
else
    fprintf('*** SUMO data not found ... exiting!\n')
    return
end
nFlights = length(sumoData);
% Create vector of flags to stating if wind comparison was made for a flight
windCompareFlag = zeros(nFlights, 1);
% Allocate memory for the gridded (averaged) data
sumoGrid.uAsc_mps = nan(nFlights, nGridHeights);
sumoGrid.uDes_mps = nan(nFlights, nGridHeights);
sumoGrid.vAsc_mps = nan(nFlights, nGridHeights);
sumoGrid.vDes_mps = nan(nFlights, nGridHeights);
sumoGrid.height_m = heightGrid_m;
radarGrid.u_mps = nan(nFlights, nGridHeights);
radarGrid.v_mps = nan(nFlights, nGridHeights);
radarGrid.height_m = heightGrid_m;

% Begin creating the parameter data
paramGrid.procYear = procYear;
paramGrid.procMonth = procMonth;
paramGrid.procDay = procDay;
paramGrid.nFlights = nFlights;
paramGrid.heightStep_m = heightStep_m;

%% Process the data

% Open radar data file
dataDirName = [ baseDirName 'UHFRadarData/' ];
fileName = 'uhf-LA_BLLAST_10jun11-05jul11-mb.edt2asc';
%fileName = 'uhf-LA_BLLAST_10jun11-05jul11-mh.edt2asc';
fp = fopen([ dataDirName fileName ], 'rt');

for iFlight = 1: nFlights
    % check if flight is profile or not
    fprintf('Flight %d of %d\n', iFlight, nFlights)
    if ~strcmp(sumoData(iFlight).a_type, 'profile')
        fprintf('*** No profile data for this flight ... skipping!\n')
        paramGrid.begTime(iFlight) = NaN;
        parmaGrid.endTime(iFlight) = NaN;
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
        iCnt = 1;
        maxLevels = 0;
        while ~feof(fp)
            str = fgetl(fp);
            if strfind(str, 'DATE (aammjj)')
                obsYear = str2double(str(16:17)) + 2000;
                obsMonth = str2double(str(18:19));
                obsDay = str2double(str(20:21));
                obsHour = str2double(str(42:43));
                if isnan(obsHour), obsHour = 0; end
                obsMinute = str2double(str(44:45));
                if isnan(obsMinute), obsMinute = 0; end
                obsSecond = str2double(str(46:47));
                obsTime = datenum(obsYear, obsMonth, obsDay, obsHour, obsMinute, obsSecond);
                if begTime <= obsTime && obsTime <= endTime
                    nLevels = str2double(str(58:59));
                    maxLevels = max(maxLevels, nLevels);
                    radar(iCnt).obsTime = obsTime;
                    radar(iCnt).nLevels = nLevels;
                    fgetl(fp);
                    fgetl(fp);
                    [dataArray, count] = fscanf(fp, '%f', [13, nLevels]);
                    dataArray(dataArray == 9999) = NaN;
                    radar(iCnt).height_m = dataArray(1, :) - heightStation_m;
                    radar(iCnt).u_mps = dataArray(2, :);
                    radar(iCnt).v_mps = dataArray(3, :);
                    radar(iCnt).w_mps = dataArray(4, :);
                    radar(iCnt).windSpeed_mps = sqrt(radar(iCnt).u_mps.^2 + radar(iCnt).v_mps.^2);
                    radar(iCnt).windDirection_deg = atan2d(radar(iCnt).u_mps, radar(iCnt).v_mps) + 180;
                    iCnt = iCnt + 1;
                end
                if obsTime >= endTime, break, end
            end
        end
        nRadarObs = iCnt - 1;
        % pack u & v data into a separate array for averaging
        uArr_mps = nan(nRadarObs, maxLevels);
        vArr_mps = nan(nRadarObs, maxLevels);
        for iRadarObs = 1: nRadarObs
            nLevels = radar(iRadarObs).nLevels;
            uArr_mps(iRadarObs, 1: nLevels) = radar(iRadarObs).u_mps;
            vArr_mps(iRadarObs, 1: nLevels) = radar(iRadarObs).v_mps;
        end
        radarGrid.u_mps(iFlight, 1: maxLevels) = nanmedian(uArr_mps, 1);
        radarGrid.v_mps(iFlight, 1: maxLevels) = nanmedian(vArr_mps, 1);
        
        % check if radar data exists for this profile flight
        if nRadarObs == 0
            fprintf('*** No corresponding radar data found ... skipping\n')
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
                end
                % Descent
                ind1 = find(heightGrid_m(iHeight) - heightStep_m/2 <= sumo.windHeightDes_m & ...
                    sumo.windHeightDes_m <= heightGrid_m(iHeight) + heightStep_m/2);
                if ~isempty(ind1)
                    sumoGrid.uDes_mps(iFlight, iHeight) = nanmean(sumo.uDes_mps(ind1));
                    sumoGrid.vDes_mps(iFlight, iHeight) = nanmean(sumo.vDes_mps(ind1));
                end
                % Radar
%                radarGrid.u_mps(iFlight, iHeight) = 
            end
            % -------
            figure(1)
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
            figure(2)
            % -------
            clf
            subplot(1, 2, 1)
            plot(sumo.uAsc_mps, sumo.windHeightAsc_m, '-*r')
            hold on
            plot(sumo.uDes_mps, sumo.windHeightDes_m, '-*b')
            for iRadar = 1: nRadarObs
                plot(radar(iRadar).u_mps, radar(iRadar).height_m)
            end
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('u (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumo.vAsc_mps, sumo.windHeightAsc_m, '-*r')
            hold on
            plot(sumo.vDes_mps, sumo.windHeightDes_m, '-*b')
            for iRadar = 1: nRadarObs
                plot(radar(iRadar).v_mps, radar(iRadar).height_m)
            end
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('v (m/s)')
            ylabel('Height (m)')
            shg
            % -------
            figure(3)
            % -------
            clf
            subplot(1, 2, 1)
            plot(sumoGrid.uAsc_mps(iFlight, :), sumoGrid.height_m, '-*r')
            hold on
            plot(sumoGrid.uDes_mps(iFlight, :), sumoGrid.height_m, '-*b')
            plot(radarGrid.u_mps(iFlight, :), radarGrid.height_m, '-ok')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('u (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumoGrid.vAsc_mps(iFlight, :), sumoGrid.height_m, '-*r')
            hold on
            plot(sumoGrid.vDes_mps(iFlight, :), sumoGrid.height_m, '-*b')
            plot(radarGrid.v_mps(iFlight, :), radarGrid.height_m, '-ok')
            hold off
            set(gca, 'xlim', [-15 15])
            set(gca, 'ylim', heightLim)
            xlabel('v (m/s)')
            ylabel('Height (m)')
            shg
            % -------
            figure(4)
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
fclose(fp);