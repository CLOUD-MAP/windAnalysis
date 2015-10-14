% This is an example of how lidar data from the LATTE experiment can be 
% read in and processed. This is only meant to get the ball rolling as it
% were

% Clear memory
clear all

% ===============================================
% User Inputs - change accordingly
% ===============================================
% directory where data files are stored
dataDir = '/Users/chilson/Dropbox (Univ. of Oklahoma)/LATTE/LATTE/Lidars_raw/WindCube_data/Raw WindCube Data MATLAB Files/';
% date to process
procYear = 2014;
procMonth = 2;
procDay = 26;
% beginning and ending times to be used when averaging
begHour = 15;
begMinute = 0;
begSecond = 0;
endHour = 15;
endMinute = 15;
endSecond = 0;
% === End user inputs ===

fileName = sprintf('WC_%4.4d%2.2d%2.2d.mat', procYear, procMonth, procDay);
load([ dataDir fileName ])
% ht - height of measurement above ground level in meters
% u, v, w - zonal, meridional, and vertical wind speeds in m/s 
% vertical_beam_ws - Radial wind speed measured by the vertical beam in m/s

% create time axis for plotting - this is to overcome a bug in Matlab
pltTime = time - datenum(procYear, procMonth, procDay);

% Average the data
begTime = datenum(0, 0, 0, begHour, begMinute, begSecond);
endTime = datenum(0, 0, 0, endHour, endMinute, endSecond);
ind = find(begTime <= pltTime & pltTime <= endTime);
uAvg = nanmean(u(ind, :), 1);
vAvg = nanmean(v(ind, :), 1);
wAvg = nanmean(w(ind, :), 1);

% -----------------------------
% Plot the data
% -----------------------------
% Note: It is necessary to transpose the u, v, and w matrices to make them
% compatible for plotting.
% transpose(u) is the same as u.'

% Plotting u as a time-height pseudo color plot
figure(1)
pcolor(pltTime, ht, u.')
shading flat
datetick('x', 15)
colorbar
xlabel('Time (UTC)')
ylabel('Height AGL (m)')
title('Wind Cube Lidar: u (m/s)')
shg

% Plotting v as a time-height pseudo color plot
figure(2)
pcolor(pltTime, ht, v.')
shading flat
datetick('x', 15)
colorbar
xlabel('Time (UTC)')
ylabel('Height AGL (m)')
title('Wind Cube Lidar: v (m/s)')
shg

% Plotting w as a time-height pseudo color plot
figure(3)
pcolor(pltTime, ht, w.')
shading flat
set(gca, 'clim', [-2 2])
datetick('x', 15)
colorbar
xlabel('Time (UTC)')
ylabel('Height AGL (m)')
title('Wind Cube Lidar: w (m/s)')
shg

% Plotting the averaged wind data
figure(4)
subplot(1, 3, 1)
plot(uAvg, ht, '-*')
xlabel('u (m/2)')
ylabel('Height AGL (m)')
subplot(1, 3, 2)
plot(vAvg, ht, '-*')
xlabel('v (m/2)')
title(sprintf('%s - %s', ...
    datestr(pltTime(ind(1)), 13), datestr(pltTime(ind(end)), 13)))
subplot(1, 3, 3)
plot(wAvg, ht, '-*')
xlabel('w (m/2)')
set(gca, 'xlim', [-1 1])
shg