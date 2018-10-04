%% sample simulation: foraging for prey model


high_value_freq_array = [1:1:200];
%high_value_freq_array = [15:60];
low_value_freq_array = [10 15 20 25 30 35 40 35 50];
handling_time{1}=10;
handling_time{2}=20;
delay2disappear = .5;
mouse_start_latency = 1.5;
start_latency_CRIT = 5;
totalWater = zeros(length(high_value_freq_array),1); % arr ay to store triforce totals after each simulation

%numSims = 10000; % number of simulations per behavior
timeSims = 60*60; %time per simulation

for j = 1:2
    display(j)
    if j==1
        abort_or_engage_low_value_track = 0; % 0 for abort, 1 for engage
    elseif j==2
        abort_or_engage_low_value_track = 1; % 0 for abort, 1 for engage
        
    end
    for lll=1:length(low_value_freq_array)
        disp(lll)
        freq_low_value = 1/low_value_freq_array(lll);
        
        for i = 1:length(high_value_freq_array) % run once per each possible behavior
            %disp(i)
            freq_high_value = 1/high_value_freq_array(i);
            %simWater = zeros(numSims,1); % reset array of triforce per sim to zero
            
            
            for k = 1:500
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
                rng('shuffle'); % shuffle random number generator
                %disp(k);
                while SessionTimer < timeSims
                    if ITI ==0
                        %track appears
                        %start latency, flip coins
                        while flippin_duringSL < (start_latency_CRIT + 0.5) && flipping > 0
                            %if flippin_duringITI_SW > flippin_duringITI
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
                        %display(current_track_type)
                        if current_track_type == 1
                            %engage
                            reward_this_trial = 4;
                            ITI=2;
                            TrialTimer = TrialTimer  + mouse_start_latency+ handling_time{1};
                        elseif current_track_type == 2
                            %abort
                            if abort_or_engage_low_value_track ==0
                                reward_this_trial = 0;
                                ITI=2.5;
                                TrialTimer = TrialTimer  + start_latency_CRIT;
                                %engage
                            elseif abort_or_engage_low_value_track ==1
                                reward_this_trial = 2;
                                ITI  =2;
                                TrialTimer = TrialTimer  + mouse_start_latency+  handling_time{2};
                            end
                        end
                        %display(reward_this_trial)
                    end
                    % ITI =2 or 2.5 track disappears after reward or abort
                    if ITI ==2 || 2.5
                        TrialTimer = TrialTimer + delay2disappear;
                        if ITI==2
                            ITI=3;
                            
                        elseif ITI==2.5
                            %%%%%%%flip coins
                            if reappear_flag ==0
                                while flippin_duringReappearWait < 2.5
                                    %if flippin_duringITI_SW > flippin_duringITI
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
                                    %                             flippin_duringReappearWait = flippin_duringReappearWait + 1;
                                    if track1_occur_or_not ==1 && track2_occur_or_not == 0
                                        %track1 appears
                                        track_type = 1;
                                        reappear_flag = 1;
                                        TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                        
                                        break;
                                    elseif track1_occur_or_not==0 && track2_occur_or_not == 1
                                        %track2 appears
                                        track_type = 2;
                                        reappear_flag = 1;
                                        TrialTimer = TrialTimer + time_so_far_duringReappearWait;
                                        break;
                                    elseif track1_occur_or_not == 1 && track2_occur_or_not == 1
                                        %flip another coin
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
                            if reappear_flag == 1
                                ITI=4;
                                reappear_flag = 2;
                                TrialTimer = TrialTimer + 2;
                            elseif reappear_flag == 0
                                TrialTimer = TrialTimer + 2;
                                
                                ITI=3;
                                
                            end
                        end
                    end
                    % ITI=3: waiting before eligible to start new trial
                    if ITI==3
                        %fluppin_duringITI_SW = fluppin_duringITI_SW + dt;
                        while 1
                            %if flippin_duringITI_SW > flippin_duringITI
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
                        %display(reward_this_trial)
                        simWater = [simWater reward_this_trial]; % store triforce earned
                        SessionTimer = SessionTimer + TrialTimer;
                        %initialize values
                        reward_this_trial= 0;
                        current_track_type = track_type;
                        
                        reappear_flag =0;
                        ITI = 0;
                        flippin_duringITI=1;
                        flippin_duringReappearWait = 1;
                        flippin_duringSL = 1;
                        flipping = 1;
                        TrialTimer = 0;
                        
                    end
                    
                    
                end
                totalWater_per_hour(i,k) = sum(simWater);
            end
            totalWater(i) = mean(totalWater_per_hour(i,:)); % save total triforce earned per simulation
%             if j==1
%                 allWater_abort(i,:) = {simWater};
%             elseif j==2
%                 allWater_engage(i,:) = {simWater};
%             end
        end
        totalWater_per_low_freq{lll} = totalWater;
    end
    if abort_or_engage_low_value_track == 0
        totalWater_all_low_aborted = totalWater_per_low_freq;
        save('totalWater_all_low_aborted.mat','totalWater_all_low_aborted')
    elseif abort_or_engage_low_value_track == 1
        totalWater_all_low_engaged = totalWater_per_low_freq;
        save('totalWater_all_low_engaged.mat','totalWater_all_low_engaged')
    end
end

%clear all
% %%
% load('totalWater_all_low_aborted.mat')
% load('totalWater_all_low_engaged.mat')
% figure;
% plot(totalWater_all_low_aborted)
% hold on
% plot(totalWater_all_low_engaged)
% flip_point = max(find(totalWater_all_low_aborted>totalWater_all_low_engaged));
% save('flip_point.mat','flip_point');