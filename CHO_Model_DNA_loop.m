% CHO_Model_DNA_loop.m
% This script simulates the model in the current manuscript, with changing
% values of DNA copy number
% NOTE: this script requires the auxiliary files listed below:
%   - SimpDiz.m
%   - dizzy2matlab2.m
%   - createMobj.m
%   - NF_CHO.cmdl

% Reset Script
clearvars; close all;
SimTime = 10000;

% direct text from dizzy file
dizzy_text = SimpDiz('NF_CHO.cmdl','Q');

% Creates Simbiology model from dizzy file
Mobj=dizzy2matlab2(dizzy_text);
ctr=1;
eDoxRange = [0,0.05]; % Dox value tested for DNA amplification

% DNA species
DNArange = 1:15;

for eDox=eDoxRange
for DNA=DNArange
    set(Mobj.Species(1),'InitialAmount',eDox) % Sets initial amount of eDox
    set(Mobj.Species(4),'InitialAmount',DNA) % Sets initial amount of Aup
    set(Mobj.Species(9),'InitialAmount',DNA) % Sets initial amount of R02
    cs = getconfigset(Mobj); %configuration
    set(cs,'SolverType','sundials') %set solver type
    [t, x,names] = sbiosimulate(Mobj,cs); %simulate model with times, values, and names
    Index = find(contains(names, 'Q')); %find Q (degradation dummy variable)
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
    % Checking levels of A
    IndexA = find(contains(names, 'A'));
    IndexA = IndexA(cellfun(@(x) strcmp(x,'A'),names(IndexA)));
    A=x(:,IndexA);
    % Checking levels of R01 
    IndexR01 = find(contains(names,'R01'));
    R01=x(:,IndexR01);
    % Checking levels of R02
    IndexR02 = find(contains(names,'R02'));
    R02=x(:,IndexR02);
    % Checking levels of M
    IndexM = find(contains(names, 'M'));
    M=x(:,IndexM);

    P=D+H+B; % Total Protein
    aveP(ctr)=mean(P(end-10:end));
    aveG(ctr) = mean(G(end-10:end));
    aveA(ctr) = mean(A(end-10:end));
    aveR01(ctr) = mean(R01(end-10:end));
    aveR02(ctr) = mean(R02(end-10:end));
    aveM(ctr) = mean(M(end-10:end));
    ctr=ctr+1

end
end

% Reshape matrix
aveP = reshape(aveP,length(DNArange),length(eDoxRange));
aveG = reshape(aveG,length(DNArange),length(eDoxRange));
aveA = reshape(aveA,length(DNArange),length(eDoxRange));
aveR01 = reshape(aveR01,length(DNArange),length(eDoxRange));
aveR02 = reshape(aveR02,length(DNArange),length(eDoxRange));
aveM = reshape(aveM,length(DNArange),length(eDoxRange));

% Plotting

% Promoter States
% Unbound
figure;
plot(DNArange,aveA(:,2)./DNArange','ko','LineWidth',2,'MarkerFaceColor','k');
hold on;
plot(DNArange,aveA(:,2)./DNArange','k-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Fraction of Unbound Promoter');
set(gca,'FontSize',15);

% Singly Bound
figure;
plot(DNArange,aveR01(:,2)./DNArange','ko','LineWidth',2,'MarkerFaceColor','k');
hold on;
plot(DNArange,aveR01(:,2)./DNArange','k-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Fraction of Singly Bound Promoter');
set(gca,'FontSize',15);

% Doubly Bound
figure;
plot(DNArange,aveR02(:,2)./DNArange','ko','LineWidth',2,'MarkerFaceColor','k');
hold on;
plot(DNArange,aveR02(:,2)./DNArange','k-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Fraction of Doubly Bound Promoter');
set(gca,'FontSize',15);

% mRNA
figure;
plot(DNArange,aveM(:,2),'bo','LineWidth',2,'MarkerFaceColor','b');
hold on;
plot(DNArange,aveM(:,2),'b-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Average mRNA molecules');
set(gca,'FontSize',15);

% eGFP
figure;
plot(DNArange,aveG(:,2),'go','LineWidth',2,'MarkerFaceColor','g');
hold on;
plot(DNArange,aveG(:,2),'g-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Average EGFP molecules');
set(gca,'FontSize',15);

% TetR
figure;
plot(DNArange,aveP(:,2),'co','LineWidth',2,'MarkerFaceColor','c');
hold on;
plot(DNArange,aveP(:,2),'c-','LineWidth',1);
xlabel('DNA copy number'); ylabel('Average tetR molecules');
set(gca,'FontSize',15);


