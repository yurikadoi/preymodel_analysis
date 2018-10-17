currentDirectory = pwd;
[upperPath, dateStr, ~] = fileparts(currentDirectory);
sessionDate = str2num(dateStr(end-3:end));
%%
load(['TaskVars' num2str(sessionDate) '.mat']);
load(['Trials' num2str(sessionDate) '.mat']);

switchNum = taskVars.trialNum_change_timing;

track1_occurance = length(find(trials(:,2)==314));
track2_occurance = length(find(trials(:,2)==322));

track1_engage = length(find(trials(:,3)==4));
track2_engage = length(find(trials(:,3)==2));

track1_engage_percent = track1_engage/track1_occurance;
track2_engage_percent = track2_engage/track2_occurance;

total_search_time = sum(trials(:,6));

track1_ave_search_time = mean(trials((find(trials(:,2)==314)),6)); 
track2_ave_search_time = mean(trials((find(trials(:,2)==322)),6)); 

track1_occurance_freq = total_search_time/track1_occurance;
track2_occurance_freq = total_search_time/track2_occurance;


before_track1_engage_percent = length(find(trials(1:switchNum-1,3)==4))/length(find(trials(1:switchNum-1,2)==314));
before_track2_engage_percent = length(find(trials(1:switchNum-1,3)==2))/length(find(trials(1:switchNum-1,2)==322));

after_track1_engage_percent = length(find(trials(switchNum:end,3)==4))/length(find(trials(switchNum:end,2)==314));
after_track2_engage_percent = length(find(trials(switchNum:end,3)==2))/length(find(trials(switchNum:end,2)==322));

before_track2_div_by_track1 = before_track2_engage_percent/before_track1_engage_percent;
after_track2_div_by_track1 = after_track2_engage_percent/after_track1_engage_percent;

all_stats= [track1_occurance track2_occurance track1_engage_percent track2_engage_percent total_search_time track1_ave_search_time track2_ave_search_time track1_occurance_freq track2_occurance_freq before_track1_engage_percent after_track1_engage_percent before_track2_engage_percent after_track2_engage_percent before_track2_div_by_track1 after_track2_div_by_track1];
