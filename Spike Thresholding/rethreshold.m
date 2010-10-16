tankName = 'K:\Alex Harris\Electrode Test 1\AP 2010-08-18';
blockName = 'Block-26'

spikeThreshold = 4.2;
minSamplesBeforeNextDetect = 8;

%readOverRequiredLengthSamples means that additional stream data will be
%collected over what is required, so that snippets can be processed that
%overrun the end of the specified period
readOverRequiredLengthSamples = 32;

%stim duration in seconds - i.e. 0.05 for 50ms
ignorePreStimDuration = 0.0
stimDuration = 0.05;
%duration used immediately prior to next stim to use for RMS generation (in
%seconds - i.e. 0.1 = 100ms). The 1ms prior to the next stim will
%not be used to ensure that the RMS calculation does not run into the
%beginning of the next stim
preStimDurationForRMS = 0.15;

%threshold crossing directions to use: -1 = only negative, 1 = only
%positive, 0 = either direction
spikeCrossingDirection = 1;

chanCount = 1;
firstChan = 7; 
spikeEpocName = 'CSPK';
sweepEpocName = 'Swep';

%It would be nice to read this directly from the tank, but it appears to be
%a messy thing to try to do - have to use CurBlockNotes which has an awful
%format
sampleRate = 24414.06;

TT = actxserver('TTank.X');
TT.ConnectServer('Local','Me');
TT.OpenTank(tankName,'R');
TT.SelectBlock(blockName);
TT.CreateEpocIndexing;

TT.ResetFilters

swepEpocs = TT.GetEpocsV(sweepEpocName,0,0,10000);

spikeMeans = zeros(length(swepEpocs(1,:)), chanCount);
spikeSDs = zeros(length(swepEpocs(1,:)), chanCount);
spikeNs = zeros(length(swepEpocs(1,:)), chanCount);

lastChan = firstChan + chanCount - 1;

TT.SetGlobalV('RespectOffsetEpoc', 0);

%calculate interstim period
    swepPeriod = swepEpocs(2,2) - swepEpocs(2,1);
%build map

disp(['Number of sweps detected = ', num2str(length(swepEpocs(1,:)))]);

%build the RMS for each channel
TT.SetEpocTimeFilterV(sweepEpocName, swepPeriod - preStimDurationForRMS - 0.001, preStimDurationForRMS);
clear repEpocs;
repEpocs = TT.GetValidTimeRangesV;

clear rmsValues;
rmsValues = zeros(length(repEpocs(1,:)),chanCount);
for chan = firstChan:lastChan
    clear streamsForRMS;
    streamsForRMS = TT.ReadWavesOnTimeRangeV('STRM',chan);
    for repNum = 1:length(repEpocs(1,:));
        streamsForRMS(:,repNum) = streamsForRMS(:,repNum);
        rmsValues(repNum, chan - firstChan + 1) =  rms(streamsForRMS(:,repNum),round(preStimDurationForRMS*sampleRate),0,0);
    end
end
%clear streamsForRMS;
clear repEpocs;
clear repNum;
clear chan;

TT.ResetFilters
TT.SetEpocTimeFilterV(sweepEpocName, ignorePreStimDuration, stimDuration + (readOverRequiredLengthSamples/sampleRate));
clear repEpocs;
repEpocs = TT.GetValidTimeRangesV;
%TT.ResetFilters;
thisStimSpikeTimes = {};

for chan = firstChan:lastChan
    thisStimSpikeCounts = zeros(1,length(repEpocs(1,:)));
    clear streamsForSpikeDetect;
    streamsForSpikeDetect = TT.ReadWavesOnTimeRangeV('STRM',chan);
    for repNum = 1:length(repEpocs(1,:))
        t_spikeTimes = [];
        thisStimSnip(repNum)= TT.ReadEventsV(100000, spikeEpocName, chan, 0, repEpocs(1,repNum), repEpocs(2,repNum), 'ALL');
        if thisStimSnip(repNum) > 0
            thisStimSnipTimes(repNum) = {TT.ParseEvInfoV(0,thisStimSnip(repNum),6)};
            thisStimSnipData(repNum) = {TT.ParseEvV(0,thisStimSnip(repNum))};
        end
        if spikeCrossingDirection > -1 %only run positive crossings if they should be included
            %one way of detecting spikes...
            thresholdExceed = streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) > rmsValues(repNum, chan - firstChan + 1) * spikeThreshold; %find threshold exceed points
            %thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
            %thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
            %thisStimSpikeTimes(repNum) = {find(thresholdExceed (1:length(thresholdExceed ) - 1))/sampleRate};

            thresholdExceedFind = find(thresholdExceed);
            for crossingNum = 1:length(thresholdExceedFind) %find where the threshold crossing occurred
                if thresholdExceedFind(crossingNum) > 1
                    if thresholdExceed(thresholdExceedFind(crossingNum) - 1) == 0
                        thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                        t_spikeTimes(length(t_spikeTimes) + 1) = thresholdExceedFind(crossingNum)/sampleRate;
                    end
                end
            end
        end
        if spikeCrossingDirection < 1 %only run negative crossings if they should be included
            %one way of detecting spikes...
            thresholdExceed = streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) < rmsValues(repNum, chan - firstChan + 1) * spikeThreshold * -1; %find threshold exceed points
            %thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
            %thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
            %thisStimSpikeTimes(repNum) = {find(thresholdExceed (1:length(thresholdExceed ) - 1))/sampleRate};

            thresholdExceedFind = find(thresholdExceed);
            for crossingNum = 1:length(thresholdExceedFind) %find where the threshold crossing occurred
                if thresholdExceedFind(crossingNum) > 1
                    if thresholdExceed(thresholdExceedFind(crossingNum) - 1) == 0
                        thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                        t_spikeTimes(length(t_spikeTimes) + 1) = thresholdExceedFind(crossingNum)/sampleRate;
                    end
                end
            end
        end
        thisStimSpikeTimes(repNum) = {t_spikeTimes};
    end
    spikeNs((chan - firstChan + 1)) = length(repEpocs(1,:));
    spikeMeans((chan - firstChan + 1)) = mean(thisStimSpikeCounts);
    spikeSDs((chan - firstChan + 1)) = std(thisStimSpikeCounts);
end     

clear thresholdExceed;

%clear streamsForSpikeDetect;
%clear streamsForRMS;

clear repEpocs;
clear repNum;
clear chan;
clear tankName;
clear blockName;
clear spikeThreshold;
clear minSamplesBeforeNextDetect;
clear stimDuration;
clear ignorePreStimDuration;
clear preStimDurationForRMS;
clear spikeCrossingDirection;
clear chanCount;
clear firstChan;
clear spikeEpocName;
clear sweepEpocName;
clear sampleRate;
clear lastChan;
clear swepPeriod;
clear rmsValues;

TT.CloseTank
TT.ReleaseServer

%for chan = firstChan:lastChan
%    figure
%    contourf(spikeMeans(:,:,chan - firstChan + 1));
%end
