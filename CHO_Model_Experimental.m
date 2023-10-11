% CHO_Model_Experimental.m
% This script compares the simulated CHO model with the experimental data
% from Farquhar, K. S. et al "Role of network-mediated stochasticity in
% mammalian drug resistance"
% NOTE: this script requires the auxiliary files listed below:
%   - CHO_Model_Sim.m
%   - mNF-PuroR


% Run simulated model
CHO_Model_Sim
% Output to user what simulation was run
if tetmut
    fprintf('Simulation: Mutated TetR\n');
else
    fprintf('Simulation: Normal TetR\n');
end

% Load experimental data into MATLAB
close all;
% NOTE: adjust this line to path name of mNF-PuroR folder
foldername = 'C:\Users\Chris\Desktop\CHO Manuscript\mNF-PuroR'; 
s = dir(foldername); names = {s.name}; names(1:2) = [];

% Extract experimental data
for v = 1:length(names)
    x = load([foldername,'\',names{v}]);
    EXP_DATA{v} = x.gated_FL1A;
end

% Data processing
all_mean_KD = cellfun(@mean, EXP_DATA); % mean
reshape_mean_KD = reshape(all_mean_KD,3,[]); % reshape
avg_KD = mean(reshape_mean_KD); % average
std_KD = std(reshape_mean_KD); % std
max_val = max(avg_KD); % max

% Plotting 
plot(fakeeDox, avg_KD./max_val, 'b^-')
hold on
er = errorbar(fakeeDox, avg_KD./max_val, std_KD./max_val);
er.Color = [0 0 1];
plot(fakeeDox, aveG./max(aveG), 'ro--')
ylim([0 1.1]); ylabel('Normalized Expression'); xlabel('Doxycycline (ng/ml)');
set(gca,'XTickLabels', xtl);
set(gca,'Fontsize',15)
legend({'Experimental','','Simulation'},'Location','SE')