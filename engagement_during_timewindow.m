%can make it into sliding window?
%%
time_bin=10*60*1000;%10min of one time bin
load('trackOn_indx.mat')
load('preyData_fromDAQ.mat')

switch_timing=trackOn_indx(20);
for i=1:5
    TW_start=time_bin*(i-1)+1;%time window start
    TW_end=time_bin*(i);%time window end
    trials_in_TW{i}.indx=find(trackOn_indx >=TW_start & trackOn_indx <= TW_end);
    min_TW=min(trials_in_TW{i}.indx);
    max_TW=max(trials_in_TW{i}.indx);
    trials_in_TW{i}.num_of_track1=length(find(preyData_fromDAQ(min_TW:max_TW,2)==314 | preyData_fromDAQ(min_TW:max_TW,2)==354));
    trials_in_TW{i}.engage_of_track1=length(find(preyData_fromDAQ(min_TW:max_TW,3)==4));
    trials_in_TW{i}.num_of_track2=length(find(preyData_fromDAQ(min_TW:max_TW,2)==322 | preyData_fromDAQ(min_TW:max_TW,2)==352));
    trials_in_TW{i}.engage_of_track2=length(find(preyData_fromDAQ(min_TW:max_TW,3)==2));

    track1_percent_TW(i)=trials_in_TW{i}.engage_of_track1/trials_in_TW{i}.num_of_track1;
    track2_percent_TW(i)=trials_in_TW{i}.engage_of_track2/trials_in_TW{i}.num_of_track2;
    overall_percent_TW(i)=(trials_in_TW{i}.engage_of_track1+trials_in_TW{i}.engage_of_track2)/(trials_in_TW{i}.num_of_track1+trials_in_TW{i}.num_of_track2);
    normalized_track2_percent_TW(i)=track2_percent_TW(i)/track1_percent_TW(i);
end
%%
figure;
plot(track1_percent_TW,'o-')
hold on
plot(track2_percent_TW,'o-')
plot([switch_timing/time_bin switch_timing/time_bin], [0 .5]);
ylim([0 1]);
xlabel('time bin # (one time bin=10min)')
ylabel('engage percent')
legend('track1','track2','switch timing')
title('engage percent over time [mouse2, 10/17/18, 1/72->1/18]')
saveas(gcf,'overtime_track2eng_percent.png')
saveas(gcf,'overtime_track2eng_percent.fig')
%%
figure;
hold on
plot(normalized_track2_percent_TW,'o-','Color',[0.4940 0.1840 0.5560])
plot([switch_timing/time_bin switch_timing/time_bin], [0 .5],'Color',[0.9290 0.6940 0.1250]);
xlabel('time bin # (one time bin=10min)')
ylabel('engage percent')
legend('track2/track1','switch timing')
title('engage percent over time [mouse2, 10/17/18, 1/72->1/18]')
saveas(gcf,'normalized_overtime_track2eng_percent.png')
saveas(gcf,'normalized_overtime_track2eng_percent.fig')
%%

figure;
plot(overall_percent_TW,'o-')
hold on
plot([switch_timing/time_bin switch_timing/time_bin], [0 .5]);
ylim([0 1]);