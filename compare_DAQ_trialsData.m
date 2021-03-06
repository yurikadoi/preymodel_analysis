%%
load(['Trials',num2str(sessionDate),'.mat'])
%%
%before 10/10 when the first trials data (matfile) is garbage and the last trial is
%not saved in the trials data (matfile)
new_preyData_fromDAQ = preyData_fromDAQ;
new_preyData_fromDAQ(:,4) = preyData_fromDAQ(:,4)/1000;
new_preyData_fromDAQ(:,5) = preyData_fromDAQ(:,5)/1000;
new_preyData_fromDAQ(:,6) = preyData_fromDAQ(:,6)/1000;

new_preyData_fromDAQ = new_preyData_fromDAQ(1:end,:);

new_trialsData = trials;
new_trialsData = new_trialsData(1:end,:);
%%
for i =2:3
    if new_preyData_fromDAQ(:,i)==new_trialsData(:,i)
        disp('no discrepancy')
    else
        disp('discrepancy')
    end
end
%%
if new_preyData_fromDAQ(:,4) - 0.1 < new_trialsData(:,4) & new_preyData_fromDAQ(:,4) + 0.1 > new_trialsData(:,4)
    disp('no discrepancy')
else
    disp('discrepancy')
end
%%
if new_preyData_fromDAQ(:,5) - 0.2 < new_trialsData(:,5) & new_preyData_fromDAQ(:,5) + 0.2 > new_trialsData(:,5)
    disp('no discrepancy')
else
    disp('discrepancy')
end
%%

if new_preyData_fromDAQ(:,6) - 0.2 < new_trialsData(:,6) & new_preyData_fromDAQ(:,6) + 0.2 > new_trialsData(:,6)
    disp('no discrepancy')
else
    disp('discrepancy')
end
%%
%{
new_preyData_fromDAQ(:,6) - new_trialsData(:,6)
%}