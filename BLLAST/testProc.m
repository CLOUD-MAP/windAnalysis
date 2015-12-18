%% Initialization
clear all
clc

dirName = sprintf('.%sdata%s', filesep, filesep);
d = dir([ dirName '*.mat'] );
nFiles = length(d);

%% Processing and plotting

heightLim = [0 1500];

for iFile = 1: nFiles
    matFileName = d(iFile).name;
    fprintf('Loading file: %s\n', matFileName)
    load([ dirName matFileName ])
    nFlights = length(sumoData);
    for iFlight = 1: nFlights
        if ~isempty(sumoData(iFlight).WS_int_asc)
            % -------
            figure(1)
            % -------
            clf
            plot3(sumoData(iFlight).NAV_x, sumoData(iFlight).NAV_y, sumoData(iFlight).GPS_alt_fixed)
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
            plot(sumoData(iFlight).WS_int_asc, sumoData(iFlight).zvec, '-*b')
            hold on
            plot(sumoData(iFlight).WS_int_des, sumoData(iFlight).zvec, '-*r')
            hold off
            set(gca, 'xlim', [0 15])
            set(gca, 'ylim', heightLim)
            xlabel('Wind speed (m/s)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumoData(iFlight).WD_int_asc, sumoData(iFlight).zvec, '-*b')
            hold on
            plot(sumoData(iFlight).WD_int_des, sumoData(iFlight).zvec, '-*r')
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
            plot(sumoData(iFlight).SHT_T_int_asc, sumoData(iFlight).zvec, '-*b')
            hold on
            plot(sumoData(iFlight).SHT_T_int_des, sumoData(iFlight).zvec, '-*r')
            hold off
            set(gca, 'xlim', [0 30])
            set(gca, 'ylim', heightLim)
            xlabel('Temperature (C)')
            ylabel('Height (m)')
            subplot(1, 2, 2)
            plot(sumoData(iFlight).SHT_RH_int_asc, sumoData(iFlight).zvec, '-*b')
            hold on
            plot(sumoData(iFlight).SHT_RH_int_des, sumoData(iFlight).zvec, '-*r')
            hold off
            set(gca, 'xlim', [0 100])
            set(gca, 'ylim', heightLim)
            xlabel('RH (%)')
            ylabel('Height (m)')
            shg
            reply = input('Press RETURN to continue (q to quit): ', 's');
            if upper(reply) == 'Q', return, end
        end
    end
end

% sumoData = 
% 
% 1x279 struct array with fields:
% 
%     a_data
%     a_str
%     t_GPS
%     a_FUN
%     GPS_utmE_o
%     GPS_utmN_o
%     GPS_chi_o
%     GPS_alt_o
%     GPS_GS_o
%     GPS_CS_o
%     t_MLX
%     MLX_a_o
%     MLX_b_o
%     MLX_c_o
%     t_AHR
%     AHR_a_o
%     AHR_b_o
%     AHR_c_o
%     t_ATT
%     ATT_a_o
%     ATT_b_o
%     ATT_c_o
%     t_NAV
%     NAV_x_o
%     NAV_y_o
%     t_SHT
%     SHT_RH_o
%     SHT_T_o
%     t_SCP
%     SCP_P_o
%     SCP_Tp_o
%     t_TMP
%     TMP_T_o
%     a_selected_start
%     a_selected_end
%     AHR_a
%     AHR_b
%     AHR_c
%     ATT_a
%     ATT_b
%     ATT_c
%     GPS_utmE
%     GPS_utmN
%     GPS_chi
%     GPS_alt
%     GPS_GS
%     GPS_CS
%     MLX_a
%     MLX_b
%     MLX_c
%     NAV_x
%     NAV_y
%     SCP_P
%     SCP_Tp
%     SHT_RH
%     SHT_T
%     lat
%     lon
%     time
%     a_starttime
%     a_endtime
%     TMP_T
%     GPS_alt_original
%     GPS_alt_original_o
%     a_location
%     GPS_alt_fixed
%     GPS_alt_o_fixed
%     a_type
%     WSS
%     WDD
%     W_alt
%     WS_asc
%     WS_des
%     WD_asc
%     WD_des
%     W_alt_asc
%     W_alt_des
%     alt_asc
%     alt_des
%     AHR_a_asc
%     AHR_a_des
%     AHR_b_asc
%     AHR_b_des
%     AHR_c_asc
%     AHR_c_des
%     ATT_a_asc
%     ATT_a_des
%     ATT_b_asc
%     ATT_b_des
%     ATT_c_asc
%     ATT_c_des
%     GPS_utmE_asc
%     GPS_utmE_des
%     GPS_utmN_asc
%     GPS_utmN_des
%     GPS_chi_asc
%     GPS_chi_des
%     GPS_alt_asc
%     GPS_alt_des
%     GPS_GS_asc
%     GPS_GS_des
%     GPS_CS_asc
%     GPS_CS_des
%     GPS_alt_original_asc
%     GPS_alt_original_des
%     GPS_alt_fixed_asc
%     GPS_alt_fixed_des
%     GPS_alt_o_fixed_asc
%     GPS_alt_o_fixed_des
%     MLX_a_asc
%     MLX_a_des
%     MLX_b_asc
%     MLX_b_des
%     MLX_c_asc
%     MLX_c_des
%     NAV_x_asc
%     NAV_x_des
%     NAV_y_asc
%     NAV_y_des
%     SCP_P_asc
%     SCP_P_des
%     SCP_Tp_asc
%     SCP_Tp_des
%     SHT_RH_asc
%     SHT_RH_des
%     SHT_T_asc
%     SHT_T_des
%     lat_asc
%     lat_des
%     lon_asc
%     lon_des
%     TMP_T_asc
%     TMP_T_des
%     zvec
%     AHR_a_int_asc
%     AHR_a_int_des
%     AHR_b_int_asc
%     AHR_b_int_des
%     AHR_c_int_asc
%     AHR_c_int_des
%     ATT_a_int_asc
%     ATT_a_int_des
%     ATT_b_int_asc
%     ATT_b_int_des
%     ATT_c_int_asc
%     ATT_c_int_des
%     GPS_utmE_int_asc
%     GPS_utmE_int_des
%     GPS_utmN_int_asc
%     GPS_utmN_int_des
%     GPS_chi_int_asc
%     GPS_chi_int_des
%     GPS_alt_int_asc
%     GPS_alt_int_des
%     GPS_GS_int_asc
%     GPS_GS_int_des
%     GPS_CS_int_asc
%     GPS_CS_int_des
%     GPS_alt_original_int_asc
%     GPS_alt_original_int_des
%     GPS_alt_fixed_int_asc
%     GPS_alt_fixed_int_des
%     GPS_alt_o_fixed_int_asc
%     GPS_alt_o_fixed_int_des
%     MLX_a_int_asc
%     MLX_a_int_des
%     MLX_b_int_asc
%     MLX_b_int_des
%     MLX_c_int_asc
%     MLX_c_int_des
%     NAV_x_int_asc
%     NAV_x_int_des
%     NAV_y_int_asc
%     NAV_y_int_des
%     SCP_P_int_asc
%     SCP_P_int_des
%     SCP_Tp_int_asc
%     SCP_Tp_int_des
%     SHT_RH_int_asc
%     SHT_RH_int_des
%     SHT_T_int_asc
%     SHT_T_int_des
%     WD_int_asc
%     WD_int_des
%     WS_int_asc
%     WS_int_des
%     W_alt_int_asc
%     W_alt_int_des
%     lat_int_asc
%     lat_int_des
%     lon_int_asc
%     lon_int_des
%     TMP_T_int_asc
%     TMP_T_int_des