format long 
clc; clear all; 
close all
materials = [];
 
problem = HBProblem();  

experimentNumber = 2;
problem.objective_func = @HT_objective_func_alt;
problem.constraints_func = @(chrom) HT_constraints(chrom, problem.bc);
problem.decoding_func = @(chrom) decodeParams(chrom, problem.bc);

problem.grid_dims = [3 3 2 2 2 2];  

problem.bc = struct();
problem.bc.Tb = 200 + 273; % Temperature @ base [K]
problem.bc.T_inf = 25 + 273; %Fluid Temperature [K]
problem.bc.h = 50; % Fluid Convection coefficient [W/ m^2 K]
problem.bc.H =  0.1;% Base Body Height [m]
problem.bc.W = 0.1; % Base Body Width [m]
problem.bc.ThetaBase = problem.bc.Tb - problem.bc.T_inf;% Excess temperature @ base [K]

% Materials (reads a .csv)
% (properties taken from table A1 - Incropera 7th ed.)
% Cost is interpreted as [dollar/kg] 
if(isempty(materials))
    materials = importfile('materials.csv');
end
for i = 1:size(materials,1)
    problem.bc.Mats{i}.name = materials{i,1};
    problem.bc.Mats{i}.K    = materials{i,2};    
    problem.bc.Mats{i}.rho  = materials{i,3};
    problem.bc.Mats{i}.cost = materials{i,4};
end
 
problem.bc.min_pitch = 2e-3; % minimum pitch constrain (clearance in mm)
problem.bc.budget    = 10;%50; 
problem.bc.maxVol    = inf;%1e-5;  % 1e-6;
problem.bc.minQt     = 2000;%1500;

% PARAMETERS UPPER AND LOWER BOUNDS
% Individual Structure: 
% N : {1,...,10}  number of fins
% w : {1e-3,..,wall width} width
% t : {1,...,wall height} thickness
% l : {0,..,0.5} length
% fin type: {1,..,3} fin type
% Material: {1,..,3} fin material  
problem.LB = [ 1,   1e-3,         1e-3,          1e-3,  1,  1   ];   
problem.UB = [ 20,  problem.bc.W, problem.bc.H,  1e-1 , 3, size(problem.bc.Mats,2)]; 

% Perform optimization

problem.n_candidates = 5;

[population, candidates] = optimizationLauncher(problem);
 
decodedCandidates = batchDecode(candidates, problem.decoding_func);
bc = problem.bc;
file = sprintf('candidates_%s_expNo=%i', datestr(date), experimentNumber); 
save(file, 'decodedCandidates', 'bc');
saveas(gcf,strcat(file,'.png'));
