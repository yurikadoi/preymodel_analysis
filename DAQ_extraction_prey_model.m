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

switch_flag=0;
channel_flag = 3;
%%
%channel before the move:: 2:speed, 3:lick, 4:watervalve, 5:trial events
switch channel_flag
        %original channel configuration before the move (move happened on the 10/23/18)
    case 1
        ch_speed = 2;%speed from optic mouse
        ch_lick=3;
        ch_watervalve=4;
        ch_trialevents=5;
        
        %channel after the move:: 1:speed (from optic mouse), 2:lick, 3:watervalve, 4:trial events
        %5:rotary encoder
    case 2
        ch_speed = 1;%speed from optic mouse
        ch_lick=2;
        ch_watervalve=3;
        ch_trialevents=4;
        
        %channel after the rotary encoder introduced (the date is 11/1/18. the
        %optic mouse was removed from the channel on 11/5/18 before running)
    case 3
        ch_opticmouse = 1;%speed from optic mouse
        ch_lick=2;
        ch_watervalve=3;
        ch_trialevents=4;
        ch_speed = 5;%speed from rotary encoder
        
        %%channel after the optic mouse got disconnected (starting on
        %%11/5/18)
    case 4
        ch_speed = 1;%speed from rotary encoder
        ch_lick=2;
        ch_watervalve=3;
        ch_trialevents=4;
end
%%
%load daq file
%daqdat = dir('DaqData*.daq');
daqdat = dir('*.daq');

[daq_data, daq_time, abstime, daq_events] = daqread(daqdat(1).name);
save('daq_data.mat','daq_data')
%%
%use trial events (channel 5) to identify trials
trialIDs = []; %store all trial ID

iBin = 1; % keeps track of location in trial events array (column 5 in daq_data)
numTrial = 1; % keeps track of track number
daq_end = length(daq_data(:,ch_trialevents)); % last index for daq_data time points

delay2disappear=.5;
msPrior = 1000; % ms prior to patch stop to save per trial (also used for TT)
msAfter = 2000; % ms after included
engage_latency_allowance = 15*1000;
% msPrior = 0; % ms prior to patch stop to save per trial (also used for TT)
% msAfter = 0

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
trackOff_curr = 1;
next_searchtime_duringSL=0;
%wait4stop - between the sound signal and the track appearing signal
%searchtime - between the track appearing signal and engage (or abort) signal + between reward/abort signal and the next track appearing signal
%engage latency - between the track appearing signal and engage signal

%% extract trial data from DAQ analog input signals
while iBin < daq_end
    % find next time w 'trackOn' signal
    %iBin
    trackOn_curr = iBin + find((daq_data(iBin:daq_end,ch_trialevents)> 0.8 & daq_data(iBin:daq_end,ch_trialevents)< 1.3) | (daq_data(iBin:daq_end,ch_trialevents)> 2.0 & daq_data(iBin:daq_end,ch_trialevents)< 2.2) | (daq_data(iBin:daq_end,ch_trialevents)< -2.2 & daq_data(iBin:daq_end,ch_trialevents)> -2.8) | (daq_data(iBin:daq_end,ch_trialevents)< -4.2 & daq_data(iBin:daq_end,ch_trialevents)> -4.8) ,1);
    while 1
        if isempty(trackOn_curr) %no more tracks appear
            disp('trackOn_curr empty: break')
            break
        end
        %if the signal of the time:trackOn_curr+1 also satisfies the
        %condition, this time is legitimately trackOn_curr. Otherwiese it
        %should not be regarded as trackOn_curr and the next timing that
        %satisfies the condition should be explored.
        if (daq_data(trackOn_curr+1,ch_trialevents)> 0.8 & daq_data(trackOn_curr+1,ch_trialevents)< 1.3) | (daq_data(trackOn_curr+1,ch_trialevents)> 2.0 & daq_data(trackOn_curr+1,ch_trialevents)< 2.2) | (daq_data(trackOn_curr+1,ch_trialevents)< -2.2 & daq_data(trackOn_curr+1,ch_trialevents)> -2.8) | (daq_data(trackOn_curr+1,ch_trialevents)< -4.2 & daq_data(trackOn_curr+1,ch_trialevents)> -4.8)
            break
        else
            iBin = trackOn_curr + 1
            pre_trackOn_curr = iBin + find((daq_data(iBin:daq_end,ch_trialevents)> 0.8 & daq_data(iBin:daq_end,ch_trialevents)< 1.3) | (daq_data(iBin:daq_end,ch_trialevents)> 2.0 & daq_data(iBin:daq_end,ch_trialevents)< 2.2) | (daq_data(iBin:daq_end,ch_trialevents)< -2.2 & daq_data(iBin:daq_end,ch_trialevents)> -2.8) | (daq_data(iBin:daq_end,ch_trialevents)< -4.2 & daq_data(iBin:daq_end,ch_trialevents)> -4.8) ,1);
            trackOn_curr=pre_trackOn_curr;
        end
    end
    if isempty(trackOn_curr) %no more tracks appear
        disp('trackOn_curr empty: break')
        break
    end
    trackOn_indx(end+1) = trackOn_curr; %save index if there was a patchOn
    trackOn_max(end+1)= max(daq_data(trackOn_curr:trackOn_curr+25,ch_trialevents)); %max signal during patchOn to determine trial type
    trackOn_min = min(daq_data(trackOn_curr:trackOn_curr+25,ch_trialevents));
    if trackOn_min < -1
        if switch_flag==1
            
            disp('!!!!!')
            disp(length(trackOn_max))
            disp(iBin)
            disp(trackOn_max(end))
            trackOn_max(end)= -min(daq_data(trackOn_curr:trackOn_curr+10,ch_trialevents))/2; %max signal during patchOn to determine trial type
        else
            disp('error:inapropriate trackOn_max value')
        end
    end
    % divide by .1 so you can use round to get whole numbers for patchIDs
    % (because if using probe trials, not all IDs approximate integars)
   
    %thisBin_TrackOn(numTrack,:) = daq_data(trackOn_curr:trackOn_curr+10,ch_trialevents);
    iBin = trackOn_curr + 26;
    next_trackOn_curr = iBin + find((daq_data(iBin:daq_end,ch_trialevents)> 0.8 & daq_data(iBin:daq_end,ch_trialevents)< 1.3) | (daq_data(iBin:daq_end,ch_trialevents)> 2.0 & daq_data(iBin:daq_end,ch_trialevents)< 2.2) | (daq_data(iBin:daq_end,ch_trialevents)< -2.2 & daq_data(iBin:daq_end,ch_trialevents)> -2.8) | (daq_data(iBin:daq_end,ch_trialevents)< -4.2 & daq_data(iBin:daq_end,ch_trialevents)> -4.8) ,1);

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
        sound = find((daq_data(trackOff_curr:iBin,ch_trialevents) < -3 & daq_data(trackOff_curr:iBin,ch_trialevents) > -4.1),1) + trackOff_curr;
        %searchtime(end+1) = next_searchtime_duringSL + sound - trackOff_curr;
        if ~isempty(sound)
            searchtime4mouse(end+1) = sound - trackOff_curr;%%%%%%%%%this needs to get fixed
            wait4stop(end+1) = trackOn_curr - sound;
        else
            searchtime4mouse(end+1) = NaN;
            wait4stop(end+1) = NaN;
        end
    end
    if ~isempty(find((daq_data(iBin:window_end,ch_trialevents)<-.8 & daq_data(iBin:window_end,ch_trialevents)>-3),1))
        %aborted
        %display(iBin)
        reward_size(end+1) = 0;
        aborted_rewarded(end+1)=0;%aborted
        engage_latencies(end+1) =0;
        
        trackOff_curr = iBin + find((daq_data(iBin:window_end,ch_trialevents)<-.8 & daq_data(iBin:window_end,ch_trialevents)>-3),1);
        next_searchtime_duringSL = trackOff_curr - trackOn_curr;
        tracks_type(end+1) = round(trackOn_max(end)*20);%track type will be 354 or 352 when it is the first trial after the switch
        CBA_track_type=mod(tracks_type,10)*10+floor(tracks_type/10)+300;
    elseif ~isempty(find(daq_data(iBin:(window_end),ch_trialevents)> 0.4 & daq_data(iBin:(window_end),ch_trialevents)< 0.6,1))
        %rewarded
        reward_size(end+1) = floor((round(trackOn_max(end)*20))/10);
        aborted_rewarded(end+1)=1;%rewarded
        engage_latencies(end+1) = find(daq_data(iBin:(window_end),ch_trialevents)> 0.4 & daq_data(iBin:(window_end),ch_trialevents)< 0.6,1);
        trackOff_curr = iBin + find(daq_data(iBin:next_trackOn_curr,ch_trialevents)>3,1);
        next_searchtime_duringSL = engage_latencies(end);
        tracks_type(end+1) = round(trackOn_max(end)*20);
        CBA_track_type=mod(tracks_type,10)*10+floor(tracks_type/10)+300;
    else
        display('error: did not find either engage or abort signal after track appearing');
        display(iBin)
    end
    
    if (trackOff_curr+msAfter <= length(daq_data(:,2)))% break if +msAfter exceeds last timepoint for daq data
        
        tracksApp_speed{numTrial} = daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,ch_speed);
        tracksApp_licks{numTrial} = daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,ch_lick);
        tracksApp_rewvalve{numTrial} = .5*daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,ch_watervalve); %1/2 voltage so it fits plots nicer
        tracksApp_trialevents{numTrial} = .5*daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,ch_trialevents); % 1/2 so it fits nicer on plots
        if channel_flag ==3
            tracksApp_opticmouse{numTrial} = daq_data(trackOn_curr-msPrior:trackOff_curr+msAfter,ch_opticmouse);
        end

    else
        disp('line 98 break'); 
        break
    end
    
    numTrial=numTrial+1; 
end

preyData_fromDAQ = [1:length(tracks_type); CBA_track_type; reward_size; engage_latencies; wait4stop; searchtime4mouse]';

if channel_flag ==3
    save('tracksApp.mat','tracksApp_speed','tracksApp_licks','tracksApp_rewvalve','tracksApp_trialevents','tracksApp_opticmouse')
    
else
    save('tracksApp.mat','tracksApp_speed','tracksApp_licks','tracksApp_rewvalve','tracksApp_trialevents')
end
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