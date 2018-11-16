%%
M = dlmread('DAQ_stats_2.csv',',',1,0);
N = dlmread('freq.csv',',',1,0);
M(20,:)=[];
N(20,:)=[];
%%
%remove 10/30 data beause he did not run well
%%
overall_track1_percent=M(:,4);
overall_track2_percent=M(:,5);
engage_SL_track1=M(:,6);
engage_SL_track2=M(:,7);

%%
%plot overall engage percent
figure;
hold on
mean_Data=[mean(overall_track1_percent) mean(overall_track2_percent)];
bar(mean_Data)                 

hold on
plot([1:2], [overall_track1_percent overall_track2_percent],'o-','color','g','linewidth',3,'markersize',5,'markerfacecolor','g');
%%
xlim([0 3])
ylim([0 1])
xlabel('track type')
ylabel('overall engage percent')
title('engage percent [mouse2, num ofsessions=25]')
%%
saveas(gcf,'overall_engage_percent.png')
saveas(gcf,'overall_engage_percent.fig')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%plot overall start latency
figure;
hold on
mean_Data=[mean(engage_SL_track1) mean(engage_SL_track2)];
bar(mean_Data)                 

hold on
plot([1:2], [engage_SL_track1 engage_SL_track2],'o-','color','g','linewidth',3,'markersize',5,'markerfacecolor','g');
%%
xlim([0 3])
xticks([1 2])
ylim([0 3])
xlabel('track type')
ylabel('engage start latency')
title('engage start latency [mouse2, num ofsessions=25]')
%%
saveas(gcf,'engage_SL.png')
saveas(gcf,'engage_SL.fig')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
before_high_freq_session_idx=find(N(:,2)<0.056 & (N(:,2)>0.055));
after_high_freq_session_idx=find(N(:,3)<0.056 & (N(:,3)>0.055));

before_mid_freq_session_idx=find(N(:,2)<0.028 & (N(:,2)>0.027));
after_mid_freq_session_idx=find(N(:,3)<0.028 & (N(:,3)>0.027));

before_low_freq_session_idx=find(N(:,2)<0.014 & (N(:,2)>0.013));
after_low_freq_session_idx=find(N(:,3)<0.014 & (N(:,3)>0.013));

freq_data={};
freq_data{1}=[];%high freq
freq_data{2}=[];%mid freq
freq_data{3}=[];%low freq

%%this is not correct, needs to be corrected
for j=1:6
    session_idx={before_high_freq_session_idx,after_high_freq_session_idx,before_mid_freq_session_idx,after_mid_freq_session_idx,before_low_freq_session_idx,after_low_freq_session_idx};
    k=floor(j/2.5)+1;
    l=mod(j,2);
    for i=1:(length(session_idx{j}))
        if N(session_idx{j}(i),3)==0%
            freq_data{k}=[freq_data{k}; M(session_idx{j}(i),5)];%/M(session_idx{j}(i),4)];
            
        elseif l==1%before
            freq_data{k}=[freq_data{k}; M(session_idx{j}(i),10)];%/M(session_idx{j}(i),8)];
            
        elseif l==0%after
            freq_data{k}=[freq_data{k}; M(session_idx{j}(i),11)];%/M(session_idx{j}(i),9)];
        end
    end
end
%%
max_lenth=max([length(freq_data{1}) length(freq_data{2}) length(freq_data{3})]);
for i=1:3
    if length(freq_data{i}) < max_lenth
        gap=max_lenth-length(freq_data{i});
        for l =1:gap
            freq_data{i}(end+1)=NaN;
        end
        
    end
end
freq_data_matrix=cell2mat(freq_data);
figure;
boxplot(freq_data_matrix)
%%
xlabel('track1 freq')
xticklabels({'high' 'med' 'low'})
ylabel('track2 engage percent')
title('track2 engage percent on different track1 freq [mouse2 sessions=24]')
%%
figure;
bar(nanmean(freq_data_matrix),'FaceColor','cyan','EdgeColor','none');
hold on
for i =1:3
scatter(i*ones(length(freq_data{i}),1), freq_data{i},'o','filled');
end
%%
xlabel('track1 freq')
xticklabels({'high' 'med' 'low'})
ylabel('track2 engage percent')
title('track2 engage percent on different track1 freq [mouse2 sessions=24]')

%%
saveas(gcf,'boxplot_track2eng_percent.png')
saveas(gcf,'boxplot_track2eng_percent.fig')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%pick dates that compare between 1/18 and 1/72
[1017 1102]
idx=find(M(1,:)==1017);
%plot([1:2], [M(idx, )],'o-','color','g','linewidth',3,'markersize',5,'markerfacecolor','g');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%%
ste_Data=[std(overall_track1_percent)/ sqrt( length( overall_track1_percent )) std(overall_track1_percent)/ sqrt( length( overall_track1_percent ))];
er = errorbar(1:2, mean_Data, std_Data, std_Data);    % create the error bars
er.Color = [0 0 0];                            % make the errorbars black
er.LineStyle = 'none';                         % remove the line connecting the errorbars
hold off

%%
scatter(ones(length(overall_track1_percent),1), overall_track1_percent)
hold on
scatter(2*ones(length(overall_track2_percent),1), overall_track2_percent)
%}

