
%%compare the stats with preydata_fromDAQ
load(['Stats',num2str(sessionDate),'.mat'])

%sanity check of ID#
disp(stats.mID)

%%
overall_percent_track1 = [stats.percentRew(1) all_stats(4)]
overall_percent_track2 = [stats.percentRew(2) all_stats(5)]
engage_latency_track1 = [stats.median_engageLatency(1) all_stats(6)]
engage_latency_track2 = [stats.median_engageLatency(2) all_stats(7)]
percent_before_track1 = [stats.percent_before_after_track1(1) all_stats(8)]
percent_after_track1 = [stats.percent_before_after_track1(2) all_stats(9)]
percent_before_track2 = [stats.percent_before_after_track2(1) all_stats(10)]
percent_after_track2 = [stats.percent_before_after_track2(2) all_stats(11)]

%%
cd ..
dlmwrite('DAQ_stats.csv',all_stats,'delimiter',',', '-append');



