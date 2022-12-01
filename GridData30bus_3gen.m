%% mpc data
clear
clc
close all

PowerM = 5;

mpc = loadcase('case30pwl.m');
Ngen = 3; % Number of generators
CgenNum = 3; % Number of linear piece
Cgen_k = [1200, 3600, 7600;
    2000, 4400, 8400;
    2000, 4400, 8400] * mpc.baseMVA / 1e8 * 0.25; % 1e8 CNY/p.u.
Cgen_b = [0, -288, -1728;
    0, -288, -1728;
    0, -288, -1728] / 1e8 * 0.25; % CNY
Ingen = [1; 2; 22];
Nbus = 30; % Number of buses
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
Sbranch = mpc.branch(:, 6) * PowerM / mpc.baseMVA; % branch capacity
IFrom = zeros(Nbranch, Nbus);
ITo = zeros(Nbranch, Nbus);
for i = 1: Nbranch
    IFrom(i, Ibranch(i, 1)) = 1;
    ITo(i, Ibranch(i, 2)) = 1;
end

Nwind = 2; % number of wind farm
Iwind = zeros(Nbus, Nwind);
Iwind(13, 1) = 1; Iwind(27, 2) = 1;
Face_Num = 15;
WindPower = zeros(Face_Num+4,4,Nwind);
load('WindLinear1.5.mat','P1');
WindPower(:,:,1) = [P1.H(:,1)/1.5*mpc.baseMVA,P1.H(:,2),P1.H(:,3)*mpc.baseMVA,P1.H(:,4)]/mpc.baseMVA;
load('WindLinear0.75.mat','P1');
WindPower(:,:,2) = [P1.H(:,1)/0.75*mpc.baseMVA,P1.H(:,2),P1.H(:,3)*mpc.baseMVA,P1.H(:,4)]/mpc.baseMVA;
Windmax = [1.5*25*25*1.5/mpc.baseMVA; 0.75*20*20*1.5/mpc.baseMVA];

Nes = 3; % number of energy storage
Ines = [13; 23; 27];
Ies = zeros(Nbus, Nes);
Ies(13, 1) = 1; Ies(23, 2) = 1; Ies(27, 3) = 1;
ESemax = [50; 50; 50];
ESpmax = [10; 10; 10];

save Grid.mat
