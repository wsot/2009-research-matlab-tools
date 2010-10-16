tankName = 'L:\Research Data\Simeon Morgan\New\New\104_76\20101012 Map before first stim session\20101012 SM 104_76 map';
blockName = 'Block-2';

spikeThreshold = 4.2;
minSamplesBeforeNextDetect = 0;

%readOverRequiredLengthSamples means that additional stream data will be
%collected over what is required, so that snippets can be processed that
%overrun the end of the specified period
readOverRequiredLengthSamples = 32;

%stim duration in seconds - i.e. 0.05 for 50ms
ignorePreStimDuration = 0.0;
stimDuration = 0.05;
%duration used immediately prior to next stim to use for RMS generation (in
%seconds - i.e. 0.1 = 100ms). The 1ms prior to the next stim will
%not be used to ensure that the RMS calculation does not run into the
%beginning of the next stim
preStimDurationForRMS = 0.15;

%threshold crossing directions to use: -1 = only negative, 1 = only
%positive, 0 = either direction
spikeCrossingDirection = 0;

chanCount = 32;
firstChan = 1; 
%spikeEpocName = 'SS08';
freqEpocName = 'Freq';
ampEpocName = 'Amp_';
sweepEpocName = 'SweS';

%It would be nice to read this directly from the tank, but it appears to be
%a messy thing to try to do - have to use CurBlockNotes which has an awful
%format
sampleRate = 24414.06;


%set up a filter
%A_stop1 = 60;		% Attenuation in the first stopband = 24 dB
%F_stop1 = 250;		% Edge of the stopband = 150 Hz
%F_pass1 = 300;  	% Edge of the passband = 300 Hz
%F_pass2 = 5000;     % Closing edge of the passband = 5000 Hz
%F_stop2 = 6000;	% Edge of the second stopband = 10000 Hz
%A_stop2 = 60;		% Attenuation in the second stopband = 24 dB
%A_pass = 0.1;		% Amount of ripple allowed in the passband = 1 dB

%BandPassSpecObj = ...
%   fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
%		F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, ...
%		A_stop2, 24414)
%BandPassFilt = design(BandPassSpecObj, 'butter')


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

freqList = freqList(1:44);
ampList = ampList(1:7);

clear spikeMeans;
clear spikeSDs;
clear spikeNs;
clear spikeTimes;
%repCount = length(freqEpocs(1,:)) / length(freqList) / length(ampList);
spikeMeans = zeros(length(ampList), length(freqList), chanCount);
spikeSDs = zeros(length(ampList), length(freqList), chanCount);
spikeNs = zeros(length(ampList), length(freqList), chanCount);
spikeTimes = cell(length(ampList), length(freqList), chanCount);

lastChan = firstChan + chanCount - 1;

TT.SetGlobalV('RespectOffsetEpoc', 0);

%calculate interstim period
    swepEpocs = TT.GetEpocsV(sweepEpocName,0,0,2);
    swepPeriod = swepEpocs(2,2) - swepEpocs(2,1);
    clear swepEpocs;
%build map

for freqOffset = 1:length(freqList)
    for ampOffset = 1:length(ampList)
        disp(['Frequency ', num2str(freqList(freqOffset)), ' (', num2str(freqOffset), ' of ' , num2str(length(freqList)), '), Amplitude ', num2str(ampList(ampOffset)), ' (', num2str(ampOffset), ' of ' , num2str(length(ampList)), ')']);
        TT.ResetFilters
        TT.SetFilterWithDescEx([freqEpocName, ' = ', num2str(freqList(freqOffset)), ' and ', ampEpocName, ' = ', num2str(ampList(ampOffset))]);

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
        clear streamsForRMS;
        clear repEpocs;
        clear repNum;
        clear chan;

        TT.ResetFilters
        TT.SetFilterWithDescEx([freqEpocName, ' = ', num2str(freqList(freqOffset)), ' and ', ampEpocName, ' = ', num2str(ampList(ampOffset))]);        
        TT.SetEpocTimeFilterV(sweepEpocName, ignorePreStimDuration, stimDuration);
        clear repEpocs;
        repEpocs = TT.GetValidTimeRangesV;
        %TT.ResetFilters;
                
        for chan = firstChan:lastChan
            thisStimSpikeCounts = zeros(1,length(repEpocs(1,:)));
            streamsForSpikeDetect = TT.ReadWavesOnTimeRangeV('STRM',chan);
            %for repNum = 1:length(repEpocs(1,:))
            %    streamsForSpikeDetect(:,repNum) = filter(BandPassFilt, streamsForSpikeDetect(:,repNum));
            %end
            
            for repNum = 1:length(repEpocs(1,:))
                t_spikeTimes = [];
                if spikeCrossingDirection == 1 %only run positive crossings if they should be included
                    lastSpikeSample = minSamplesBeforeNextDetect * -1;
                    %one way of detecting spikes...
                    thresholdExceed = streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) > rmsValues(repNum, chan - firstChan + 1) * spikeThreshold; %find threshold exceed points
                    %thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
                    %thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
                    %thisStimSpikeTimes(repNum) = {find(thresholdExceed (1:length(thresholdExceed ) - 1))/sampleRate};

                    thresholdExceedFind = find(thresholdExceed);
                    for crossingNum = 1:length(thresholdExceedFind) %find where the threshold crossing occurred
                        if thresholdExceedFind(crossingNum) > 1 %if this is the first sample of the block, we can't detect a spike because we don't know if the stream was already above threshold
                            if thresholdExceed(thresholdExceedFind(crossingNum) - 1) == 0 %check that the previous sample was below threshold (i.e. this is a threshold crossing)
                                if thresholdExceedFind(crossingNum) > (lastSpikeSample + minSamplesBeforeNextDetect) %check that the last detected spike was outside the minSamplesBeforeNextDetect window - i.e. enough time has passed to capture another spike
                                    thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                                    t_spikeTimes(length(t_spikeTimes) + 1) = thresholdExceedFind(crossingNum)/sampleRate;
                                    lastSpikeSample = thresholdExceedFind(crossingNum);
                                end
                            end
                        end
                    end
                end

                if spikeCrossingDirection == -1 %only run negative crossings if they should be included
                    lastSpikeSample = minSamplesBeforeNextDetect * -1;
                    %one way of detecting spikes...
                    thresholdExceed = streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) < rmsValues(repNum, chan - firstChan + 1) * spikeThreshold * -1; %find threshold exceed points
                    %thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
                    %thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
                    %thisStimSpikeTimes(repNum) = {find(thresholdExceed (1:length(thresholdExceed ) - 1))/sampleRate};

                    thresholdExceedFind = find(thresholdExceed);
                    for crossingNum = 1:length(thresholdExceedFind) %find where the threshold crossing occurred
                        if thresholdExceedFind(crossingNum) > 1 %if this is the first sample of the block, we can't detect a spike because we don't know if the stream was already above threshold
                            if thresholdExceed(thresholdExceedFind(crossingNum) - 1) == 0 %check that the previous sample was below threshold (i.e. this is a threshold crossing)
                                if thresholdExceedFind(crossingNum) > (lastSpikeSample + minSamplesBeforeNextDetect) %check that the last detected spike was outside the minSamplesBeforeNextDetect window - i.e. enough time has passed to capture another spike
                                    thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                                    t_spikeTimes(length(t_spikeTimes) + 1) = thresholdExceedFind(crossingNum)/sampleRate;
                                    lastSpikeSample = thresholdExceedFind(crossingNum);
                                end
                            end
                        end
                    end
                end

                if spikeCrossingDirection == 0 %only run positive crossings if they should be included
                    lastSpikeSample = minSamplesBeforeNextDetect * -1;
                    %one way of detecting spikes...
                    thresholdExceed = streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) > rmsValues(repNum, chan - firstChan + 1) * spikeThreshold; %find threshold exceed points
                    thresholdExceed = or(thresholdExceed, streamsForSpikeDetect(1:length(streamsForSpikeDetect(:,1))-readOverRequiredLengthSamples,repNum) < rmsValues(repNum, chan - firstChan + 1) * spikeThreshold * -1);
                    %thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
                    %thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
                    %thisStimSpikeTimes(repNum) = {find(thresholdExceed (1:length(thresholdExceed ) - 1))/sampleRate};

                    thresholdExceedFind = find(thresholdExceed);
                    for crossingNum = 1:length(thresholdExceedFind) %find where the threshold crossing occurred
                        if thresholdExceedFind(crossingNum) > 1 %if this is the first sample of the block, we can't detect a spike because we don't know if the stream was already above threshold
                            if thresholdExceed(thresholdExceedFind(crossingNum) - 1) == 0 %check that the previous sample was below threshold (i.e. this is a threshold crossing)
                                if thresholdExceedFind(crossingNum) > (lastSpikeSample + minSamplesBeforeNextDetect) %check that the last detected spike was outside the minSamplesBeforeNextDetect window - i.e. enough time has passed to capture another spike
                                    thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                                    t_spikeTimes(length(t_spikeTimes) + 1) = thresholdExceedFind(crossingNum)/sampleRate;
                                    lastSpikeSample = thresholdExceedFind(crossingNum);
                                end
                            end
                        end
                    end
                end
                clear thresholdExceed;
                clear thresholdExceedFind;
                clear crossingNum;
                t_thisStimSpikeTimes(repNum) = {t_spikeTimes};
            end
            spikeNs(ampOffset, freqOffset, (chan - firstChan + 1)) = length(repEpocs(1,:));
            spikeMeans(ampOffset, freqOffset, (chan - firstChan + 1)) = mean(thisStimSpikeCounts);
            spikeSDs(ampOffset, freqOffset, (chan - firstChan + 1)) = std(thisStimSpikeCounts);
            spikeTimes(ampOffset, freqOffset, (chan - firstChan + 1)) = {t_thisStimSpikeTimes};
            clear thisStimSpikeCounts;
            clear t_thisStimSpikeTimes;
        end
        %clear streamsForSpikeDetect;
        clear repNum;
        clear streamsForSpikeDetect;
        clear repEpocs;
        clear chan;
    end
end

clear tankName;
clear blockName;
clear spikeThreshold;
clear minSamplesBeforeNextDetect;
clear stimDuration;
clear preStimDurationForRMS;
clear spikeCrossingDirection;
clear chanCount;
clear firstChan;
clear spikeEpocName;
clear freqEpocName;
clear ampEpocName;
clear sweepEpocName;
clear sampleRate;
clear freqEpocs;
clear ampEpocs;
clear lastChan;
clear swepPeriod;
clear rmsValues;

TT.CloseTank
TT.ReleaseServer

%for chan = firstChan:lastChan
%    figure
%    contourf(spikeMeans(:,:,chan - firstChan + 1));
%end
    SPPage=invoke(SPItems,'Add','1');
    CurrentPage=get(CurrentNotebook,'CurrentPageItem');

SPApp=actxserver('SigmaPlot.Application.1');
set(SPApp,'Visible',1);
SPNotebooks=get(SPApp,'Notebooks');
invoke(SPNotebooks,'Add');
CurrentNotebook=get(SPApp,'ActiveDocument');
for chan=1:length(spikeMeans(1,1,:));
    if chan > 1
        SPPage=invoke(SPItems,'Add','1');
    end
    
    SPData=invoke(CurrentNotebook,'CurrentDataItem');
    SPTable=get(SPData,'DataTable');
    SPItems=invoke(CurrentNotebook,'NotebookItems');
    SPPage=invoke(SPItems,'Add','2');
    CurrentPage=get(CurrentNotebook,'CurrentPageItem');
    invoke(SPApp,'Top','0');

    SPInputCells = num2cell(freqList);
    invoke(SPTable,'PutData',SPInputCells,0,0);
    clear SPInputCells;
    SPInputCells = num2cell(ampList);
    invoke(SPTable,'PutData',SPInputCells,1,0);
    clear SPInputCells;
    SPInputCells = num2cell(spikeMeans(:,:,chan));
    invoke(SPTable,'PutData',SPInputCells,3,0);
    clear SPInputCells;

    SPInputCells = cell(6);
    SPInputCells{1} = '@rgb(255,255,255)';
    SPInputCells{2} = '@rgb(0,0,255)';
    SPInputCells{3} = '@rgb(0,255,255)';
    SPInputCells{4} = '@rgb(0,255,0)';
    SPInputCells{5} = '@rgb(255,255,0)';
    SPInputCells{6} = '@rgb(255,0,0)';
    invoke(SPTable,'PutData',SPInputCells',2,0);
    clear SPInputCells;

    sizex = size(spikeMeans(:,:,chan));

    SPInputCells = cell(3,4);
    SPInputCells{1,1}=0;
    SPInputCells{2,1}=0;
    SPInputCells{3,1}=31999999;
    SPInputCells{1,2}=1;
    SPInputCells{2,2}=0;
    SPInputCells{3,2}=31999999;
    SPInputCells{1,3}=3;
    SPInputCells{2,3}=0;
    SPInputCells{3,3}=31999999;
    SPInputCells{1,4}=3+sizex(1) - 1;
    SPInputCells{2,4}=0;
    SPInputCells{3,4}=31999999;

    invoke(SPPage,'CreateWizardGraph','Contour Plot', 'Filled Contour Plot', 'XY Many Z', SPInputCells);
end