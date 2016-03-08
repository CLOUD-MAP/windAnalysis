%% User inputs
baseDirName = '/Users/chilson/Matlab/CLOUDMAP/windAnalysis/BLLAST/';
procYear = 2011;
procMonth = 6;
procDay = 17;

heightLim = [0 1500];

%% Read Sumo data and Radar data
dataDirName = [ baseDirName 'SUMOData/' ];
fileName = sprintf('%4.4d%2.2d%2.2dSUMOBLLAST.mat', procYear, procMonth, procDay);
load([ dataDirName fileName]);
dataDirName = [ baseDirName 'UHFRadarData/' ];
fileName = 'uhf-LA_BLLAST_10jun11-05jul11-mb.edt2asc';
fp = fopen([ dataDirName fileName ], 'rt');

nFlights = length(sumoData);

heightStation_m = 597;
heightLim = heightLim + 600;

clc
for iFlight = 1: nFlights
    if isempty(sumoData(iFlight).WS_int_asc)
        fprintf('*** No profile data for this flight ... skipping!\n')
        break
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
        
        iCnt = 1;
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
                    radar(iCnt).obsTime = obsTime;
                    fgetl(fp);
                    fgetl(fp);
                    [dataArray, count] = fscanf(fp, '%f', [13, nLevels]);
                    dataArray(dataArray == 9999) = NaN;
                    radar(iCnt).height_m = dataArray(1, :);
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

        % -------
        figure(1)
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
        figure(2)
        % -------
        clf
        subplot(1, 2, 1)
        plot(windSpeedAsc_mps, height_m, '-*b')
        hold on
        plot(windSpeedDes_mps, height_m, '-*r')
        for iRadar = 1: nRadarObs
            plot(radar(iRadar).windSpeed_mps, radar(iRadar).height_m)
        end
        hold off
        set(gca, 'xlim', [0 15])
        set(gca, 'ylim', heightLim)
        xlabel('Wind speed (m/s)')
        ylabel('Height (m)')
        subplot(1, 2, 2)
        plot(windDirectionAsc_deg, height_m, '-*b')
        hold on
        plot(windDirectionDes_deg, height_m, '-*r')
        for iRadar = 1: nRadarObs
            plot(radar(iRadar).windDirection_deg, radar(iRadar).height_m)
        end
        hold off
        set(gca, 'xlim', [0 360])
        set(gca, 'ylim', heightLim)
        xlabel('Wind direction (deg)')
        ylabel('Height (m)')
        shg
        % -------
        figure(3)
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
fclose(fp);