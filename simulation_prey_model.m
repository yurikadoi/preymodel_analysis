%% sample simulation: foraging for prey model

high_value_freq_array = [1:1:100];
low_value_freq_array = 36;
handling_time{1}=15;
handling_time{2}=30;
delay2disappear = .5;
mouse_start_latency = 1.5;%simulate when the mouse engages after the track appears
start_latency_CRIT = 5;
totalWater = zeros(length(high_value_freq_array),1); % array to store total water each simulation

timeSims = 10000*60; %time per simulation

for j = 1:2
    if j==1
        abort_or_engage_low_value_track = 0; % 0 for abort, 1 for engage with the low value track
    elseif j==2
        abort_or_engage_low_value_track = 1; % 0 for abort, 1 for engage with the low value track
        
    end
    rng('shuffle'); % shuffle random number generator
    
    for lll=1:length(low_value_freq_array)
        freq_low_value = 1/low_value_freq_array(lll);
        
        for i = 1:length(high_value_freq_array) % run once per each high value track freq
            freq_high_value = 1/high_value_freq_array(i);   
            for k = 1 %how many sessions to run
                %initialize values
                coin_positive_duringSL_reappear = 0;
                coin_negative_duringSL_reappear = 0;
                HighTrials = 0;
                LowTrials = 0;
                TrialNum = 0;
                simWater=[];
                SessionTimer = 0;
                ITI=3;
                reward_this_trial= 0;
                reappear_flag =0;
                flippin_duringITI=1;
                flippin_duringReappearWait = 1;
                flippin_duringSL = 1;
                flipping = 1;
                TrialTimer=0;
                track1_trialTimer = 0;
                track2_trialTimer = 0;
                rng('shuffle'); % shuffle random number generator
                while SessionTimer < timeSims
                    if ITI ==0
                        %track appears
                        %start latency, flip coins
                        while flippin_duringSL < (start_latency_CRIT + 0.5) && flipping > 0
                            %flip coin
                            n=rand(1);
                            if n < freq_high_value
                                track1_occur_or_not=1;
                            else
                                track1_occur_or_not=0;
                            end
                            m=rand(1);
                            if m < freq_low_value
                                track2_occur_or_not=1;
                            else
                                track2_occur_or_not=0;
                            end
                            time_so_far_duringSL = flippin_duringSL;
                            flippin_duringSL = flippin_duringSL + 1;
                            if track1_occur_or_not ==1 && track2_occur_or_not == 0
                                %track1 appears
                                track_type = 1;
                                reappear_flag=1;
                                flippin_duringReappearWait = 1;
                                flipping = 0;
                                
                                break;
                            elseif track1_occur_or_not==0 && track2_occur_or_not == 1
                                %track2 appears
                                track_type = 2;
                                reappear_flag=1;
                                flippin_duringReappearWait = 1;
                                flipping = 0;
                                
                                break;
                            elseif track1_occur_or_not == 1 && track2_occur_or_not == 1
                                %flip another coin
                                l=rand(1);
                                if l < freq_low_value/(freq_high_value + freq_low_value)
                                    track2_occur_or_not = 1;
                                    track1_occur_or_not = 0;
                                    track_type = 2;
                                    reappear_flag=1;
                                    flippin_duringReappearWait = 1;
                                    flipping = 0;
                                    
                                    break;
                                else
                                    track2_occur_or_not = 0;
                                    track1_occur_or_not = 1;
                                    track_type = 1;
                                    reappear_flag=1;
                                    flippin_duringReappearWait = 1;
                                    flipping = 0;
                                    
                                    break;
                                end
                                
                                
                            else
                                %track does not appear in this sec, keep flipping the coin
                            end
                        end
                        if current_track_type == 1
                            %engage 100% for high value track
                            HighTrials = HighTrials +1;%keep track of the occurance of high value track
                            reward_this_trial = 4;
                            ITI=2;
                            TrialTimer = TrialTimer  + mouse_start_latency+ handling_time{1};%add time to trial time
                        elseif current_track_type == 2
                            LowTrials = LowTrials +1;%keep track of the occurance of low value track
                            %abort
                            if abort_or_engage_low_value_track ==0
                                reward_this_trial = 0;
                                ITI=2.5;
                                TrialTimer = TrialTimer  + start_latency_CRIT;%add time to trial time
                            %engage
                            elseif abort_or_engage_low_value_track ==1
                                reward_this_trial = 2;
                                ITI  =2;
                                TrialTimer = TrialTimer  + mouse_start_latency+  handling_time{2};%add time to trial time
                            end
                        end

                    end
                    % ITI =2 or 2.5 track disappears after reward or abort
                    if ITI ==2 || 2.5
                        TrialTimer = TrialTimer + delay2disappear;
                        if ITI==2
                            %if reappear flag is 1, wait for 2 sec and go
                            %to ITI=4
                            if reappear_flag == 1
                                ITI=4;
                                reappear_flag = 2;
                                TrialTimer = TrialTimer + 2;
                            %if reappear flag is 0, go to ITI=3
                            elseif reappear_flag == 0
                                ITI=3;
                                
                            end
                            
                            
                        elseif ITI==2.5
                            %%%%%%%flip coins
                            if reappear_flag ==0
                                while flippin_duringReappearWait < 2
                                    %flip coin
                                    n=rand(1);
                                    if n < freq_high_value
                                        track1_occur_or_not=1;
                                    else
                                        track1_occur_or_not=0;
                                    end
                                    m=rand(1);
                                    if m < freq_low_value
                                        track2_occur_or_not=1;
                                    else
                                        track2_occur_or_not=0;
                                    end
                                    time_so_far_duringReappearWait = flippin_duringReappearWait;
                                    flippin_duringReappearWait = flippin_duringReappearWait + 1;
                                    if track1_occur_or_not ==1 && track2_occur_or_not == 0
                                        track_type = 1;
                                        reappear_flag = 1;
                                        TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                        
                                        break;
                                    elseif track1_occur_or_not==0 && track2_occur_or_not == 1
                                        track_type = 2;
                                        reappear_flag = 1;
                                        TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                        break;
                                    elseif track1_occur_or_not == 1 && track2_occur_or_not == 1
                                        l=rand(1);
                                        if l < freq_low_value/(freq_high_value + freq_low_value)
                                            track2_occur_or_not = 1;
                                            track1_occur_or_not = 0;
                                            track_type = 2;
                                            reappear_flag = 1;
                                            TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                            break;
                                        else
                                            track2_occur_or_not = 0;
                                            track1_occur_or_not = 1;
                                            track_type = 1;
                                            reappear_flag = 1;
                                            TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                            break;
                                        end
                                        
                                        
                                    else
                                        %track does not appear in this sec, keep flipping the coin
                                    end
                                end
                            end
                            
                            if reappear_flag == 1%if reappear_flag become 1 within the 2 sec, go to ITI=4
                                coin_positive_duringSL_reappear = coin_positive_duringSL_reappear +1;
                                ITI=4;
                                reappear_flag = 2;
                                TrialTimer = TrialTimer + 2;
                            elseif reappear_flag == 0%if reappear_flag is still zero after 2 sec, go to ITI=3
                                coin_negative_duringSL_reappear = coin_negative_duringSL_reappear +1;
                                TrialTimer = TrialTimer + 2;
                                ITI=3;
                                
                            end
                        end
                    end
                    % ITI=3: waiting before eligible to start new trial
                    if ITI==3
                        while 1
                            %flip coin
                            n=rand(1);
                            if n < freq_high_value
                                track1_occur_or_not=1;
                            else
                                track1_occur_or_not=0;
                            end
                            m=rand(1);
                            if m < freq_low_value
                                track2_occur_or_not=1;
                            else
                                track2_occur_or_not=0;
                            end
                            time_so_far_duringITI = flippin_duringITI;
                            flippin_duringITI = flippin_duringITI + 1;
                            if track1_occur_or_not ==1 && track2_occur_or_not == 0
                                %track1 appears
                                track_type = 1;
                                ITI=4;
                                TrialTimer = TrialTimer + time_so_far_duringITI;
                                
                                break;
                            elseif track1_occur_or_not==0 && track2_occur_or_not == 1
                                %track2 appears
                                track_type = 2;
                                ITI=4;
                                TrialTimer = TrialTimer + time_so_far_duringITI;
                                
                                break;
                            elseif track1_occur_or_not == 1 && track2_occur_or_not == 1
                                %flip another coin
                                l=rand(1);
                                if l < freq_low_value/(freq_high_value + freq_low_value)
                                    track2_occur_or_not = 1;
                                    track1_occur_or_not = 0;
                                    track_type = 2;
                                    ITI=4;
                                    TrialTimer = TrialTimer + time_so_far_duringITI;
                                    break;
                                else
                                    track2_occur_or_not = 0;
                                    track1_occur_or_not = 1;
                                    track_type = 1;
                                    ITI=4;
                                    TrialTimer = TrialTimer + time_so_far_duringITI;
                                    break;
                                end
                                
                                
                            else
                                %track does not appear in this sec, keep flipping the coin
                            end
                        end
                    end
                    % ITI=4: waiting to detect stop before initiating new trial
                    if ITI ==4
                        
                        
                        simWater = [simWater reward_this_trial]; % store water earned this trial
                        SessionTimer = SessionTimer + TrialTimer;%add the time that took for this trial to the session timer
                        %initialize values
                        reward_this_trial= 0;
                        current_track_type = track_type;
%                         if current_track_type ==1
%                             
%                             track1_trialTimer = track1_trialTimer + TrialTimer;
%                         elseif current_track_type ==2
%                             track2_trialTimer = track2_trialTimer + TrialTimer;
% 
%                         end
                        reappear_flag =0;
                        ITI = 0;
                        flippin_duringITI=1;
                        flippin_duringReappearWait = 1;
                        flippin_duringSL = 1;
                        flipping = 1;
                        TrialTimer = 0;
                        TrialNum = TrialNum + 1;
                    end
                    
                    
                end
                totalWater_per_session(i,k) = sum(simWater);
            end
            totalWater(i) = mean(totalWater_per_session(i,:)); % save total water earned per simulation

        end
        totalWater_per_low_freq{lll} = totalWater;
        
        %display([HighTrials LowTrials TrialNum]);
        %display([track1_trialTimer track2_trialTimer])
    end
    %save the total water in mat file
    if abort_or_engage_low_value_track == 0
        totalWater_all_low_aborted = totalWater_per_low_freq;
        save('15_30_low_freq_36_totalWater_all_low_aborted.mat','totalWater_all_low_aborted')
    elseif abort_or_engage_low_value_track == 1
        totalWater_all_low_engaged = totalWater_per_low_freq;
        save('15_30_low_freq_36_totalWater_all_low_engaged.mat','totalWater_all_low_engaged')
    end
end
%calculate and save the indifference point (threshold where it is the same total water whether the mouse engage or abort the low value track)
indifference_point = max(find(totalWater_all_low_aborted{1,1}>totalWater_all_low_engaged{1,1}));
save('15_30_low_freq_36_indifference_point.mat','indifference_point')


%%
%plot
% load('test_longtime_totalWater_all_low_aborted.mat')
% load('test_longtime_totalWater_all_low_engaged.mat')
figure;
plot(totalWater_all_low_aborted{1,1})
hold on
plot(totalWater_all_low_engaged{1,1})
legend('low value track aborted','low value track engaged')
xlabel('high value freq')
ylabel('total water in 10000 hours')
title('disstance 15-30, low value freq = 36, SL = 1.5, indifference point = 36')
