%%
% get date
currentDirectory = pwd;
[upperPath, dateStr, ~] = fileparts(currentDirectory);
sessionDate = str2num(dateStr(end-3:end));
mouseNum = str2num(upperPath(end));
display(sessionDate)

if sessionDate < 1010
    sound_trigger_added_flag = 0;
else
    sound_trigger_added_flag = 1;
end
if sessionDate < 1007
    searchtime_calc_changed_flag = 0;
else
    searchtime_calc_changed_flag = 1;

end


%Channel 2:spped, 3:lick, 4:watervalve, 5:trial events
%%
%load daq file
%daqdat = dir('DaqData*.daq');
daqdat = dir('*.daq');

[daq_data, daq_time, abstime, daq_events] = daqread(daqdat.name);
%%
%use trial events (channel 5) to identify trials
trialIDs = []; %store all trial ID

iBin = 1; % keeps track of location in trial events array (column 5 in daq_data)
numTrial = 1; % keeps track of track number
daq_end = length(daq_data(:,5)); % last index for daq_data time points

delay2disappear=.5;
msPrior = 1000; % ms prior to patch stop to save per trial (also used for TT)
msAfter = 2000; % ms after included
engage_latency_allowance = 15*1000;
% msPrior = 0; % ms prior to patch stop to save per trial (also used for TT)
% msAfter = 0;
trackOn_curr = []; % current patchOn index
trackOn_indx = []; % array of all patchOn indices
trackOn_max = []; % maximum trial event value for patchOn

trackOff_curr = 1; % current patchOff index

tracks_type = []; % patch type (i.e. rew size)
reward_size=[];
aborted_rewarded = [];%use to store if the trial is aborted(0) or rewarded(1)
engage_latencies=[];
searchtime=[];
searchtime4mouse=[];
wait4stop = [];
trackOff_curr = find(daq_data(:,5)> 3,1);
next_searchtime_duringSL=0;
%wait4stop - between the sound signal and the track appearing signal
%searchtime - between the track appearing signal and engage (or abort) signal + between reward/abort signal and the next track appearing signal
%engage latency - between the track appearing signal and engage signal

%% extract trial data from DAQ analog input signals
while iBin < daq_end
    % find next time w 'trackOn' signal
    trackOn_curr = iBin + find(daq_data(iBin:daq_end,5)> 0.8 & daq_data(iBin:daq_end,5)< 2.5 ,1);
    
    if isempty(trackOn_curr) %no more tracks appear
        disp('trackOn_curr empty: break')
        break
    end
    trackOn_indx(end+1) = trackOn_curr; %save index if there was a patchOn
    trackOn_max(end+1)= max(daq_data(trackOn_curr:trackOn_curr+10,5)); %max signal during patchOn to determine trial type
    
    % divide by .1 so you can use round to get whole numbers for patchIDs
    % (because if using probe trials, not all IDs approximate integars)
   
    %thisBin_TrackOn(numTrack,:) = daq_data(trackOn_curr:trackOn_curr+10,5);
    iBin = trackOn_curr + 10;
    next_trackOn_curr = iBin + find(daq_data(iBin:daq_end,5)> 0.8 & daq_data(iBin:daq_end,5)< 2.5,1);
    if isempty(next_trackOn_curr)
        next_trackOn_curr = daq_end;
    end
    %find out if the trial was aborted or rewarded
    %positive_signal = next_trackOn_curr;\
    if iBin+engage_latency_allowance < daq_end
        window_end = iBin+engage_latency_allowance;
    else
        window_end=daq_end;
    end
    %next_searchtime_duringSL
    if sound_trigger_added_flag == 1
        sound = find(daq_data(trackOff_curr:iBin,5) < -3,1) + trackOff_curr;
        %searchtime(end+1) = next_searchtime_duringSL + sound - trackOff_curr;
        searchtime4mouse(end+1) = sound - trackOff_curr;%%%%%%%%%this needs to get fixed
        wait4stop(end+1) = trackOn_curr - sound;
    end
    if ~isempty(find(daq_data(iBin:window_end,5)<-.8,1))
        %aborted
        %display(iBin)
        reward_size(end+1) = 0;
        aborted_rewarded(end+1)=0;%aborted
        engage_latencies(end+1) =0;
        
        trackOff_curr = iBin + find(daq_data(iBin:window_end,5)<-.8,1);
        next_searchtime_duringSL = trackOff_curr - trackOn_curr;
        tracks_type(end+1) = round(trackOn_max(end)*20);
        CBA_track_type=mod(tracks_type,10)*10+floor(tracks_type/10)+300;
    elseif ~isempty(find(daq_data(iBin:(window_end),5)> 0.4 & daq_data(iBin:(window_end),5)< 0.6,1))
        %rewarded
        reward_size(end+1) = floor((round(trackOn_max(end)*20))/10);
        aborted_rewarded(end+1)=1;%rewarded
        engage_latencies(end+1) = find(daq_data(iBin:(window_end),5)> 0.4 & daq_data(iBin:(window_end),5)< 0.6,1);
        trackOff_curr = iBin + find(daq_data(iBin:next_trackOn_curr,5)>3,1);
        next_searchtime_duringSL = engage_latencies(end);
        tracks_type(end+1) = round(trackOn_max(end)*20);
        CBA_track_type=mod(tracks_type,10)*10+floor(tracks_type/10)+300;
    else
        display('error: did not find either engage or abort signal after track appearing');
        display(iBin)
    end
    
    if (trackOff_curr+msAfter <= length(daq_data(:,2)))% break if +msAfter exceeds last timepoint for daq data
        
        tracksApp_speed{numTrial} = daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,2);
        tracksApp_licks{numTrial} = daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,3);
        tracksApp_rewvalve{numTrial} = .5*daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,4); %1/2 voltage so it fits plots nicer
        tracksApp_trialevents{numTrial} = .5*daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,5); % 1/2 so it fits nicer on plots
        

    else
        disp('line 98 break'); 
        break
    end
    
    numTrial=numTrial+1; 
end

preyData_fromDAQ = [1:length(tracks_type); CBA_track_type; reward_size; engage_latencies; wait4stop; searchtime4mouse]';

save('tracksApp.mat','tracksApp_speed','tracksApp_licks','tracksApp_rewvalve','tracksApp_trialevents')
save('preyData_fromDAQ.mat','preyData_fromDAQ')


%%
% for thisTrial=1:10
%     figure;
%     plot(tracksApp_speed{thisTrial});
%     hold on;
%     plot(tracksApp_licks{thisTrial});
%     plot(tracksApp_rewvalve{thisTrial});
%     plot(tracksApp_trialevents{thisTrial});
% end