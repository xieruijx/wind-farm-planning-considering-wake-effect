%% mpc data
clear
clc
close all

PowerM = 1;

mpc = loadcase('case118.m');
Index_gen = mpc.gen(:,2)>0;
mpc.gen = mpc.gen(Index_gen,:);
mpc.gencost = mpc.gencost(Index_gen,:);
[Ngen,~] = size(mpc.gen); % Number of generators
CgenNum = 1; % Number of linear piece
Cgen_k = (mpc.gencost(:,5).*mpc.gen(:,9)+mpc.gencost(:,6))*7*mpc.baseMVA/1e8; % 1e8 CNY/p.u.
Cgen_b = zeros(Ngen,1); % CNY
Ingen = mpc.gen(:,1);
Nbus = 118; % Number of buses
Iref = 1; % Ref bus
PD = mpc.bus(:, 3) * PowerM / mpc.baseMVA; % P demand
Igen = zeros(Nbus, Ngen); % bus of generator
for i = 1: Ngen
    Igen(mpc.gen(i, 1), i) = 1;
end
PMAXgen = mpc.gen(1: Ngen, 9) * PowerM / mpc.baseMVA;
PMINgen = mpc.gen(1: Ngen, 10) * PowerM / mpc.baseMVA;
Rampgen = 0.4 * PMAXgen;

Ibranch = mpc.branch(:, 1: 2); % branch: from bus, to bus
[Nbranch, ~] = size(Ibranch);
BR_X = mpc.branch(:, 4);
% mpc = runopf(mpc);
Sbranch = 1.8 * ones(Nbranch,1); % branch capacity
IFrom = zeros(Nbranch, Nbus);
ITo = zeros(Nbranch, Nbus);
for i = 1: Nbranch
    IFrom(i, Ibranch(i, 1)) = 1;
    ITo(i, Ibranch(i, 2)) = 1;
end

Nwind = 4; % number of wind farm
Iwind = zeros(Nbus, Nwind);
Iwind(12, 1) = 1; Iwind(31, 2) = 1; Iwind(55, 3) = 1; Iwind(87, 4) = 1;
Face_Num = 15;
WindPower = zeros(Face_Num+4,4,Nwind);
load('WindLinear1.5.mat','P1');
P15 = P1;
load('WindLinear0.75.mat','P1');
P075 = P1;
WindPower(:,:,1) = [P15.H(:,1)/1.5*mpc.baseMVA,P15.H(:,2),P15.H(:,3)*mpc.baseMVA,P15.H(:,4)]/mpc.baseMVA;
WindPower(:,:,2) = [P075.H(:,1)/0.75*mpc.baseMVA,P075.H(:,2),P075.H(:,3)*mpc.baseMVA,P075.H(:,4)]/mpc.baseMVA;
WindPower(:,:,3) = [P075.H(:,1)/0.75*mpc.baseMVA,P075.H(:,2),P075.H(:,3)*mpc.baseMVA,P075.H(:,4)]/mpc.baseMVA;
WindPower(:,:,4) = [P15.H(:,1)/1.5*mpc.baseMVA,P15.H(:,2),P15.H(:,3)*mpc.baseMVA,P15.H(:,4)]/mpc.baseMVA;
Windmax = [1.5*25*25*1.5/mpc.baseMVA; 0.75*20*20*1.5/mpc.baseMVA; 0.75*20*20*1.5/mpc.baseMVA; 1.5*25*25*1.5/mpc.baseMVA];

NPV = 2; % number of PV
IPV = zeros(Nbus, NPV);
IPV(46, 1) = 1; IPV(91, 2) = 1;
PVmax = [10; 10];

Nes = 3; % number of energy storage
Ines = [12; 46; 87];
Ies = zeros(Nbus, Nes);
Ies(12, 1) = 1; Ies(46, 2) = 1; Ies(87, 3) = 1;
ESemax = 50 * ones(Nes,1);
ESpmax = 10 * ones(Nes,1);

save Grid.mat