%% Modeling Diet-Gut Microbiome Interactions in Thai Adults
% Author: Nachonase
% Date: Apr 28, 2025
% Updated: Oct 7, 2025
% 
% This script models diet-gut microbiome interactions using Thai community-scale metabolic models (CSMMs).
% It consists of three major parts:
%   1. Reconstruction and modeling of Thai CSMMs with an average Thai diet
%   2. Analysis of microbial contributions to SCFA production
%   3. Simulation of prebiotic responses
% Noted: Set working directory with the actual path to the folder where the main.m file is stored.
%% Setup
% Initialize the COBRA Toolbox and set the working directory
initCobraToolbox(false);  % 'false' disables auto-downloading additional datasets

%% Part 1: Reconstruction and Modeling of Thai GMiMs with Average Thai Diet
modPath = [pwd filesep 'AGORAmodels' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat']; % modPath is very important input GSMMs
cutoff = 0.001; 

NumReads = 'rawAbun86.csv';
% NumReads = 'testAbun.csv'; this file is used for test the modeling
% instalation

[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);
dietFilePath='ThaiDiet.txt'; %This is Thai diet constraints
computeProfiles = true;
numWorkers = 4;
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

% After run initMgPipe you will get Thai CSMMs in Results folder
%% Part 2: Target microbial taxon to SCFA production analysis
resPath = [pwd filesep 'Results'];
constrModPath = [resPath filesep 'Diet']; %Diet folder contains CSMMs constrainted with Thai diet
metList = {'ac', 'but', 'ppa', 'isobut'}; %input the list of target metabolites
computeProfiles = true;
numWorkers = 4;

%EX_ac[fe]	Exchange of Acetate
%EX_but[fe]	Exchange of Butyric acid
%EX_ppa[fe]	Exchange of Propionate
%EX_isobut[fe]	Isobutyrate exchange

[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);

% After run predictMicrobeContributions you will get secretion flux of SCFAs in Contributions folder

%% Part 3: To simulate prebiotic responses
cd 'prebiotic'; %change working directory, This is in order to avoid overwriting in Results and Contributions folders of ThaiCSMMs
modPath = [pwd filesep '../AGORAmodels' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];
cutoff = 0.001; 
NumReads = 'prebiotic5.xlsx'; %abundance of microbes in the studies samples (MOS group)
[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);
dietFilePath='prebioticflux.txt'; %This is Thai diet with MOS constraints
computeProfiles = true;
numWorkers = 4;
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

% After run initMgPipe you will get the CSMMs constrained with prebiotic intervention in Results folder inside prebiotic folder
% Target microbial taxon to MOS uptake analysis
resPath = [pwd filesep 'Results'];
constrModPath = [resPath filesep 'Diet'];
metList = {'mantr'};
computeProfiles = true;
numWorkers = 4;

%EX_mantr[fe]	MOS exchange
[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);

% After run predictMicrobeContributions you will get uptake flux of MOS in
% Contributions folder inside prebiotic folder

%% End of Script