%% Modeling Diet-Gut Microbiome Interactions in Thai Adults
% Author: Nachonase
% Date: Apr 28, 2025
% 
% This script models diet-gut microbiome interactions using Thai gut microbial models (GMiMs).
% It consists of three major parts:
%   1. Reconstruction and modeling of Thai GMiMs with an average Thai diet
%   2. Analysis of microbial contributions to SCFA production
%   3. Simulation of prebiotic responses
% Noted: Set working directory with the actual path to the folder where the main.m file is stored.
%% Setup
% Initialize the COBRA Toolbox and set the working directory
initCobraToolbox(false);  % 'false' disables auto-downloading additional datasets

%% Part 1: Reconstruction and Modeling of Thai GMiMs with Average Thai Diet
modPath = [pwd filesep 'models' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];
cutoff = 0.001; 
NumReads = 'rawAbun86.csv';
[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);
dietFilePath='ThaiDiet.txt';
computeProfiles = true;
numWorkers = 4;
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

% After run initMgPipe you will get Thai GMiMs in Results folder
%% Part 2: Target microbial taxon to SCFA production analysis
resPath = [pwd filesep 'Results'];
constrModPath = [resPath filesep 'Diet'];
metList = {'ac', 'but', 'ppa', 'isobut'};
computeProfiles = true;
numWorkers = 4;

%EX_ac[fe]	Exchange of Acetate
%EX_but[fe]	Exchange of Butyric acid
%EX_ppa[fe]	Exchange of Propionate
%EX_isobut[fe]	Isobutyrate exchange

[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);

% After run predictMicrobeContributions you will get secretion flux of SCFAs in Contributions folder

%% Part 3: To simulate prebiotic responses
cd 'prebiotic';
modPath = [pwd filesep '../models' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];
cutoff = 0.001; 
NumReads = 'prebiotic5.xlsx';
[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);
dietFilePath='prebioticflux.txt';
computeProfiles = true;
numWorkers = 4;
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

% After run initMgPipe you will get the GMiMs constrained with prebiotic intervention in Resultsfolder
% Target microbial taxon to MOS uptake analysis
resPath = [pwd filesep 'Results'];
constrModPath = [resPath filesep 'Diet'];
metList = {'mantr'};
computeProfiles = true;
numWorkers = 4;

%EX_mantr[fe]	Mannotriose exchange
[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);

% After run predictMicrobeContributions you will get uptake flux of Mannotriose in Contributions folder

%% End of Script