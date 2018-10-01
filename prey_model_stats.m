
track1_occurance = length(find(trials(:,2)==314));
track2_occurance = length(find(trials(:,2)==322));

track1_engage = length(find(trials(:,3)==4));
track2_engage = length(find(trials(:,3)==2));

track1_engage_percent = track1_engage/track1_occurance;
track2_engage_percent = track2_engage/track2_occurance;

total_search_time = sum(trials(:,6));

track1_ave_search_time =mean(trials((find(trials(:,2)==314)),6)); 
track2_ave_search_time = mean(trials((find(trials(:,2)==322)),6)); 

track1_occurance_freq = total_search_time/track1_occurance;
track2_occurance_freq = total_search_time/track2_occurance;

all_stats= [track1_occurance track2_occurance track1_engage_percent track2_engage_percent total_search_time track1_ave_search_time track2_ave_search_time track1_occurance_freq track2_occurance_freq];
