tankName = 'C:\Simeon\112_1024\2009-08-31 Mapping 2 with correct calibration\2009-08-31 112_1024 Map1';
blockName = 'Map 1'

chanCount = 32;
firstChan = 1;
spikeEpocName = 'CSPK';
freqEpocName = 'Frq1';
ampEpocName = 'Lev1';
sweepEpocName = 'Swep';

TT = actxserver('TTank.X');
TT.ConnectServer('Local','Me');
TT.OpenTank(tankName,'R');
TT.SelectBlock(blockName);
TT.CreateEpocIndexing;


TT.ResetFilters

freqEpocs = TT.GetEpocsV(freqEpocName,0,0,10000);
freqList = sort(unique(freqEpocs(1,:)));
ampEpocs = TT.GetEpocsV(ampEpocName,0,0,10000);
ampList = sort(unique(ampEpocs(1,:)));
%repCount = length(freqEpocs(1,:)) / length(freqList) / length(ampList);
spikeMeans = zeros(length(ampList), length(freqList), chanCount);
spikeSDs = zeros(length(ampList), length(freqList), chanCount);
spikeNs = zeros(length(ampList), length(freqList), chanCount);
lastChan = firstChan + chanCount - 1;

for freqOffset = 1:length(freqList)
    for ampOffset = 1:length(ampList)
        disp(['Frequency ', num2str(freqList(freqOffset)), ' (', num2str(freqOffset), ' of ' , num2str(length(freqList)), '), Amplitude ', num2str(ampList(ampOffset)), ' (', num2str(ampOffset), ' of ' , num2str(length(ampList)), ')']);
        TT.ResetFilters
        TT.SetFilterWithDescEx([freqEpocName, ' = ', num2str(freqList(freqOffset)), ' and ', ampEpocName, ' = ', num2str(ampList(ampOffset))]);
        TT.SetEpocTimeFilterV(sweepEpocName, 0, 0.05);
        clear repEpocs;
        repEpocs = TT.GetValidTimeRangesV;
        TT.ResetFilters;
        
        for chan = firstChan:lastChan
            thisStimSpikeCounts = zeros(0,length(repEpocs(1,:)));
            for repNum = 1:length(repEpocs(1,:));
                thisStimSpikeCounts(repNum)= TT.ReadEventsV(100000, spikeEpocName, chan, 0, repEpocs(1,repNum), repEpocs(2,repNum), 'JUSTTIMES');
            end
            spikeNs(ampOffset, freqOffset, (chan - firstChan + 1)) = length(repEpocs(1,:));
            spikeMeans(ampOffset, freqOffset, (chan - firstChan + 1)) = mean(thisStimSpikeCounts);
            spikeSDs(ampOffset, freqOffset, (chan - firstChan + 1)) = std(thisStimSpikeCounts);
        end        
    end
end

%for chan = firstChan:lastChan
%    figure
%    contourf(spikeMeans(:,:,chan - firstChan + 1));
%end