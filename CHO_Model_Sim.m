% CHO_Model_Sim.m
% This script simulates the model in the current manuscript, both with and 
% without TetR mutation
% NOTE: this script requires the auxiliary files listed below:
%   - SimpDiz.m
%   - dizzy2matlab2.m
%   - createMobj.m
%   - NF_CHO.cmdl

% Reset script
clearvars; close all;
close all
SimTime=10000;

% direct text from dizzy file
dizzy_text = SimpDiz('NF_CHO.cmdl','Q');

% Set flag to analyze TetR mutation (true or false)
tetmut = false;
if tetmut
    dizzy_text(142:143)=''; % Set binding rate of TetR to DNA to be zero
end

% Creates Simbiology model from dizzy file
Mobj=dizzy2matlab2(dizzy_text);
ctr=1;
eDoxRange = [0,0.05,0.2,0.8,3,6,10,12.5,20,35,50,500];
% Loop through each Dox value, get steady state value for components
for eDox=eDoxRange
    set(Mobj.Species(1),'InitialAmount',eDox) % Sets initial amount of eDox
    cs = getconfigset(Mobj); %configuration
    set(cs, 'StopTime', SimTime); %set stop time 
    set(cs,'SolverType','sundials') %set solver type
    set(cs.SolverOptions,'AbsoluteToleranceScaling',0);
    [t, x,names] = sbiosimulate(Mobj,cs); %simulate model with times, values, and names
    Index = find(contains(names, 'Q')); %find Q (dummy degradation variable)
    names(Index)=[]; %get rid of Q
    x(:,Index)=[]; %get rid of Q
    IndexD = find(contains(names, 'D'));
    IndexH = find(contains(names, 'H'));
    IndexB = find(contains(names, 'B'));
    IndexG = find(contains(names, 'G'));
    D=x(:,IndexD); %find vales for D
    H=x(:,IndexH); %find values for H
    B=x(:,IndexB); %find values for B
    G=x(:,IndexG); %find values for G

    P=D+H+B; % Total protein
    aveP(ctr)=mean(P(end-10:end));
    stdP(ctr)=std(P(end-10:end));
    aveG(ctr)=mean(G(end-10:end));
    ctr=ctr+1
end

% Plotting
fakeeDox = eDoxRange; fakeeDox(end) = 60; % For axis consistency
xtl = [0:10:50,500];
figure;
plot(fakeeDox,aveG,'ko','LineWidth',2,'MarkerFaceColor','k');
hold on; plot(fakeeDox,aveG,'k-','LineWidth',1);
xticklabels(xtl); xlabel('Doxycycline (ng/ml)', 'FontSize',15); 
ylabel('Mean EGFP Protein Count', 'FontSize', 15);
set(gca,'FontSize',15);

% Special plotting instructions for TetR mutation
if tetmut
    ylim([0 5*10^4])
    h = get(gca, 'Children');
    set(h(1), 'Color', [0.5 0.5 0.5]); 
    set(h(2), 'MarkerFaceColor', [0.5 0.5 0.5]);
    set(h(2), 'Color', [0.5 0.5 0.5]);
end

