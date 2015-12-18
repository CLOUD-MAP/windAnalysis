%% Initialization

clear all
clc

dirName = sprintf('.%sdata%s', filesep, filesep);
matFileNameIn = 'SUMO_BLLAST_DATA.mat';
fprintf('Reading the file\n')
load(matFileNameIn)
fprintf('Done\n')

%% Processing

nFlights = length(sumo);
procFlightDay = fix(sumo(1).time(1));
matFileNameOut = sprintf('%sSUMOBLLAST.mat', datestr(procFlightDay, 'yyyymmdd'));
icnt = 1;
sumoData = sumo(1);

for iFlight = 2: nFlights
    rdFlightDay = fix(sumo(iFlight).time(1));
    if rdFlightDay ~= procFlightDay
        fprintf('Creating file: %s\n', matFileNameOut)
        save([ dirName matFileNameOut ], 'sumoData');
        procFlightDay = rdFlightDay;
        matFileNameOut = sprintf('%sSUMOBLLAST.mat', datestr(procFlightDay, 'yyyymmdd'));
        icnt = 1;
        sumoData = sumo(iFlight);
    else
        icnt = icnt + 1;
        sumoData(icnt) = sumo(iFlight);
    end
end
fprintf('Creating file: %s\n', matFileNameOut)
save([ dirName matFileNameOut ], 'sumoData');
