currentDirectory = pwd;
[upperPath, dateStr, ~] = fileparts(currentDirectory);
sessionDate = str2num(dateStr(end-3:end));
switch_flag=1;
%%
load(['TaskVars' num2str(sessionDate) '.mat']);
%load(['Trials' num2str(sessionDate) '.mat']);

load('preyData_fromDAQ.mat')
trials=preyData_fromDAQ;
if switch_flag==1
    switchNum = taskVars.trialNum_change_timing;
end
track1_occurance = length(find(trials(:,2)==314));
track2_occurance = length(find(trials(:,2)==322));

track1_engage = length(find(trials(:,3)==4));
track2_engage = length(find(trials(:,3)==2));

track1_engage_percent = track1_engage/track1_occurance;
track2_engage_percent = track2_engage/track2_occurance;

%total_search_time = sum(trials(:,6));

track1_median_engage_latency = nanmedian(trials((find(trials(:,3)==4)),4));
track2_median_engage_latency = nanmedian(trials((find(trials(:,3)==2)),4));

%median_wait4stop = median(trials(:,5));

%track1_ave_search_time = mean(trials((find(trials(:,2)==314)),6));
%track2_ave_search_time = mean(trials((find(trials(:,2)==322)),6));

%track1_occurance_freq = total_search_time/track1_occurance;
%track2_occurance_freq = total_search_time/track2_occurance;

%%
if ~isempty(find(trials(:,2)==352))
    idx_to_fix=find(trials(:,2)==352);
    trials(idx_to_fix,2)=322;
elseif ~isempty(find(trials(:,2)==354))
    idx_to_fix=find(trials(:,2)==354);
    trials(idx_to_fix,2)=314;
end

if switch_flag==1
    before_track1_engage_percent = length(find(trials(1:switchNum-1,3)==4))/length(find(trials(1:switchNum-1,2)==314));
    before_track2_engage_percent = length(find(trials(1:switchNum-1,3)==2))/length(find(trials(1:switchNum-1,2)==322));
    
    after_track1_engage_percent = length(find(trials(switchNum:end,3)==4))/length(find(trials(switchNum:end,2)==314));
    after_track2_engage_percent = length(find(trials(switchNum:end,3)==2))/length(find(trials(switchNum:end,2)==322));
    
    before_track2_div_by_track1 = before_track2_engage_percent/before_track1_engage_percent;
    after_track2_div_by_track1 = after_track2_engage_percent/after_track1_engage_percent;
    
    %all_stats= [track1_occurance track2_occurance track1_engage_percent track2_engage_percent total_search_time track1_ave_search_time track2_ave_search_time track1_occurance_freq track2_occurance_freq before_track1_engage_percent after_track1_engage_percent before_track2_engage_percent after_track2_engage_percent before_track2_div_by_track1 after_track2_div_by_track1];
    all_stats= [sessionDate track1_occurance track2_occurance track1_engage_percent track2_engage_percent track1_median_engage_latency/1000 track2_median_engage_latency/1000 before_track1_engage_percent after_track1_engage_percent before_track2_engage_percent after_track2_engage_percent before_track2_div_by_track1 after_track2_div_by_track1];
    
else
    
    all_stats= [sessionDate track1_occurance track2_occurance track1_engage_percent track2_engage_percent track1_median_engage_latency/1000 track2_median_engage_latency/1000]; %total_search_time track1_ave_search_time track2_ave_search_time track1_occurance_freq track2_occurance_freq ];
    %all_stats= [sessionDate track1_occurance track2_occurance track1_engage_percent track2_engage_percent median_wait4stop/1000 track1_median_engage_latency/1000 track2_median_engage_latency/1000]; %total_search_time track1_ave_search_time track2_ave_search_time track1_occurance_freq track2_occurance_freq ];
    
end
%% 
cd ..
dlmwrite('DAQ_stats_2.csv',all_stats,'delimiter',',', '-append');