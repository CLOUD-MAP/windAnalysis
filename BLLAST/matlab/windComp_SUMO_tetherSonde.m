%% Initialization
clear all
fclose all;
clc

%% User inputs
% Choices for the day for June
% 19, 20, 24, 25, 26, 27, 30
% Choices for the day for July
% 01, 02, 05
baseDirName = '/Users/chilson/Matlab/CLOUDMAP/windAnalysis/BLLAST/';
procYear = 2011;
procMonth = 6;
procDay = 27;

heightLim = [0 1500];

%% Read Sumo data
dataDirName = [ baseDirName 'SUMOData/' ];
fileName = sprintf('%4.4d%2.2d%2.2dSUMOBLLAST.mat', procYear, procMonth, procDay);
load([ dataDirName fileName]);

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

dataArr(dataArr == 65535) = NaN;
tetherSonde.obsTime = datenum(procYear, procMonth, procDay) + ...
    dataArr(1, :)/86400;
tetherSonde.height_m = dataArr(2, :);
tetherSonde.pressure_hPa = dataArr(3, :);
tetherSonde.temperature_C = dataArr(4, :);
tetherSonde.relativeHumidity_perCent = dataArr(5, :);
tetherSonde.windDirection_deg = dataArr(6, :);
tetherSonde.windSpeed_mps = dataArr(7, :);

%% Process data
nFlights = length(sumoData);

heightStation_m = 593;
heightLim = heightLim + 600;

for iFlight = 1: nFlights
    fprintf('Flight %d of %d\n', iFlight, nFlights)
    if isempty(sumoData(iFlight).WS_int_asc)
        fprintf('*** No profile data for this flight ... skipping!\n')
    else
        begTime = sumoData(iFlight).time(1);
        endTime = sumoData(iFlight).time(end);
        xFlight_m = sumoData(iFlight).NAV_x;
        yFlight_m = sumoData(iFlight).NAV_y;
        zFlight_m = sumoData(iFlight).GPS_alt_fixed + heightStation_m;
        height_m = sumoData(iFlight).zvec + heightStation_m;
        windSpeedAsc_mps = sumoData(iFlight).WS_int_asc;
        windSpeedDes_mps = sumoData(iFlight).WS_int_des;
        windDirectionAsc_deg = sumoData(iFlight).WD_int_asc;
        windDirectionDes_deg = sumoData(iFlight).WD_int_des;
        temperatureAsc_C = sumoData(iFlight).SHT_T_int_asc;
        temperatureDes_C = sumoData(iFlight).SHT_T_int_des;
        relativeHumidityAsc_perCent = sumoData(iFlight).SHT_RH_int_asc;
        relativeHumidityDes_perCent = sumoData(iFlight).SHT_RH_int_des;

        fprintf('Evaluation period: %s - %s\n', datestr(begTime), datestr(endTime))
        indSonde = find(begTime <= tetherSonde.obsTime & tetherSonde.obsTime <= endTime);
        if isempty(indSonde)
            fprintf('*** No tethersonde data found ...continuing\n')
        else
            
            % -------
            figure(11)
            % -------
            clf
            plot3(xFlight_m, yFlight_m, zFlight_m)
            set(gca, 'zlim', heightLim)
            xlabel('Zonal direction (m)')
            ylabel('Meridional direction (m)')
            zlabel('Height (m)')
            title([datestr(sumoData(iFlight).time(1)) ' - ' datestr(sumoData(iFlight).time(end))])
            shg
            % -------
            figure(12)
            % -------
            clf
            subplot(1, 2, 1)
            plot(windSpeedAsc_mps, height_m, '-*b')
            hold on
            plot(windSpeedDes_mps, height_m, '-*r')
            plot(tetherSonde.windSpeed_mps(indSonde), tetherSonde.height_m(indSonde), 'ko')
            hold off
            set(gca, 'xlim', [0 15])
            set(gca, 'ylim', heightLim)
            xlabel('Wind speed (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(windDirectionAsc_deg, height_m, '-*b')
            hold on
            plot(windDirectionDes_deg, height_m, '-*r')
            plot(tetherSonde.windDirection_deg(indSonde), tetherSonde.height_m(indSonde), 'ko')
            hold off
            set(gca, 'xlim', [0 360])
            set(gca, 'ylim', heightLim)
            xlabel('Wind direction (deg)')
            ylabel('Height (m)')
            shg
            % -------
            figure(13)
            % -------
            clf
            subplot(1, 2, 1)
            plot(temperatureAsc_C, height_m, '-*b')
            hold on
            plot(temperatureDes_C, height_m, '-*r')
            hold off
            set(gca, 'xlim', [0 30])
            set(gca, 'ylim', heightLim)
            xlabel('Temperature (C)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(relativeHumidityAsc_perCent, height_m, '-*b')
            hold on
            plot(relativeHumidityDes_perCent, height_m, '-*r')
            hold off
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
