%% Initialization
clear all
clc

dirName = sprintf('.%sdata%s', filesep, filesep);
d = dir([ dirName '*.mat'] );
nFiles = length(d);

%% Processing
for iFile = 1: nFiles
    matFileName = d(iFile).name;
    fprintf('Loading file: %s\n', matFileName)
    load([ dirName matFileName ])
    nFlights = length(sumoData);
    for iFlight = 1: nFlights
        if strcmp(sumoData(iFlight).a_type, 'profile')
            zMSL = nanmean(sumoData(iFlight).GPS_alt_asc - sumoData(iFlight).GPS_alt_fixed_asc);
            meanLat = nanmean(sumoData(iFlight).lat_asc);
            meanLon = nanmean(sumoData(iFlight).lon_asc);
            fprintf('%3.3d: %s  %s - %s (%5.2f, %5.2f) @ %5.1f m\n', ...
                iFlight, ...
                datestr(sumoData(iFlight).time(1), 1), ...
                datestr(sumoData(iFlight).time(1), 15), ...
                datestr(sumoData(iFlight).time(end), 15), ...
                meanLat, meanLon, zMSL)
        end
    end
end