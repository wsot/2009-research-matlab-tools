tankName = 'L:\Research Data\Simeon Morgan\New\New\104_76\20101012 Map before first stim session\20101012 SM 104_76 map';
blockName = 'Block-2'

spikeThreshold = 3.5;
minSamplesBeforeNextDetect = 8;

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
spikeCrossingDirection = 0;

chanCount = 1;
firstChan = 1; 
spikeEpocName = 'SS08';
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

%repCount = length(freqEpocs(1,:)) / length(freqList) / length(ampList);
spikeMeans = zeros(length(ampList), length(freqList), chanCount);
spikeSDs = zeros(length(ampList), length(freqList), chanCount);
spikeNs = zeros(length(ampList), length(freqList), chanCount);


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
            streamsForRMS = TT.ReadWavesOnTimeRangeV('STRM',chan - firstChan + 1);
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
        TT.SetFilterWithDescEx([freqEpocName, ' = ', num2str(freqList(freqOffset)), ' and ', ampEpocName, ' = ', num2str(ampList(ampOffset))]);        
        TT.SetEpocTimeFilterV(sweepEpocName, ignorePreStimDuration, stimDuration);
        clear repEpocs;
        repEpocs = TT.GetValidTimeRangesV;
        %TT.ResetFilters;
        
        for chan = firstChan:lastChan
            thisStimSpikeCounts = zeros(1,length(repEpocs(1,:)));
            clear streamsForSpikeDetect;
            streamsForSpikeDetect = TT.ReadWavesOnTimeRangeV('STRM',chan - firstChan + 1);
            %for repNum = 1:length(repEpocs(1,:))
            %    streamsForSpikeDetect(:,repNum) = filter(BandPassFilt, streamsForSpikeDetect(:,repNum));
            %end
            for repNum = 1:length(repEpocs(1,:))
                if spikeCrossingDirection > -1 %only run positive crossings if they should be included
                    
                    %one way of detecting spikes...
                    thresholdExceed = streamsForSpikeDetect(:,repNum) > rmsValues(repNum, chan) * spikeThreshold; %find threshold exceed points
                    thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
                    thisStimSpikeCounts(repNum) = length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
                    
                    %positiveThresholdExceed = find(streamsForSpikeDetect(:,repNum) > rmsValues(repNum, chan)* spikeThreshold ); %find threshold exceed points
                    %for crossingNum = 1:length(positiveThresholdExceed) %find where the threshold crossing occurred
                    %    if streamsForSpikeDetect(positiveThresholdExceed(crossingNum)-1,repNum) < (rmsValues(repNum, chan)* spikeThreshold)
                    %        thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                    %    end
                    %end
                end
                if spikeCrossingDirection < 1 %only run negative crossings if they should be included
                    thresholdExceed = streamsForSpikeDetect(:,repNum) < rmsValues(repNum, chan) * spikeThreshold * -1; %find threshold exceed points
                    thresholdExceed = and(cat(1,thresholdExceed ,[0]), xor(cat(1, thresholdExceed , [0]), cat(1, [1], thresholdExceed )));
                    thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + length(find(thresholdExceed (1:length(thresholdExceed ) - 1)));
                    %negativeThresholdExceed = find(streamsForSpikeDetect(:,repNum) < (rmsValues(repNum, chan) * -1 * spikeThreshold ));
                    %for crossingNum = 1:length(negativeThresholdExceed) %find where the threshold crossing occurred
                    %    if streamsForSpikeDetect(positiveThresholdExceed(crossingNum)-1,repNum) < (rmsValues(repNum, chan)* spikeThreshold)
                    %        thisStimSpikeCounts(repNum) = thisStimSpikeCounts(repNum) + 1;
                    %    end
                    %end
                end
                
                %thisStimSpikeCounts(repNum)= TT.ReadEventsV(100000, spikeEpocName, chan, 0, repEpocs(1,repNum), repEpocs(2,repNum), 'JUSTTIMES');
                %streamsForSpikeDetect 
            end
            spikeNs(ampOffset, freqOffset, (chan - firstChan + 1)) = length(repEpocs(1,:));
            spikeMeans(ampOffset, freqOffset, (chan - firstChan + 1)) = mean(thisStimSpikeCounts);
            spikeSDs(ampOffset, freqOffset, (chan - firstChan + 1)) = std(thisStimSpikeCounts);
        end     
        clear exceedThresholdPoints
        clear streamsForSpikeDetect;
        clear repEpocs;
        clear repNum;
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
