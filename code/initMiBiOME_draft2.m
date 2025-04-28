addpath('C:\Users\Lenovo\Documents\GitHub\cobratoolbox');
savepath;
initCobraToolbox(false);

%% prepare modPath
%websave('AGORA-master.zip','https://github.com/VirtualMetabolicHuman/AGORA/archive/master.zip')
%try
%    unzip('AGORA-master')
%end

modPath = [pwd filesep 'models' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];

%% prepare abunFilePath

cutoff = 0.05; %cover > 0.95%
NumReads = 'normCoverage_mos10.csv';
[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);

%% prepare dietFilePath
% First, we will define the simulated dietary regime that will be implemented 
% on the personalized models. Here, we will use an "Average European" diet that 
% is located in the folder
% 
% cobratoolbox/papers/2018_microbiomeModelingToolbox/input
% 
% The folder also contains various other simulated diets, e.g., Vegan, gluten-free.

dietFilePath='ThaiDiet.txt';
%% 
computeProfiles = true;
numWorkers = 4;
%parpool(4, 'IdleTimeout', Inf);
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);



%% prepare abunFilePath

cutoff = 0.05; %cover > 0.95%
NumReads = 'normCoverage_mos10w.csv';
[normalizedCoverage,abunFilePath] = normalizeCoverage(NumReads,cutoff);

%% prepare dietFilePath
% First, we will define the simulated dietary regime that will be implemented 
% on the personalized models. Here, we will use an "Average European" diet that 
% is located in the folder
% 
% cobratoolbox/papers/2018_microbiomeModelingToolbox/input
% 
% The folder also contains various other simulated diets, e.g., Vegan, gluten-free.

dietFilePath='AverageEuropeanDiet.txt';
%% 
computeProfiles = true;
numWorkers = 4;
%parpool(4, 'IdleTimeout', Inf);
infoFilePath='';

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);


%% Statistical analysis and plotting of generated fluxes





infoFilePath='sampInfo.csv'; 
[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

sampleGroupHeaders={'Group'};
resPath = [pwd filesep 'Results'];
analyzeMgPipeResults(infoFilePath,resPath, 'sampleGroupHeaders', sampleGroupHeaders);
%% 
% Afterwards, the results of the statistical analysis will be available in the 
% folder "Statistics". The files ending in "Statistics.txt" contain the calculated 
% p-values and test results. If there are any fluxes or abundances that significantly 
% differed between groups, there will be files ending in "significantFeatures.txt" 
% listing only these instances. Created violin plots will be found in the folder 
% "ViolinPlots". There will be an image in png and pdf format for each predicted 
% metabolite's uptake and secretion potential. There will also be a file ending 
% in "All_plots.pdf" containing all plots.
%% Targeted analysis: Strain-level contributions to metabolites of interest
% For metabolites of particular interest (e.g., for which the community-wide 
% secretion potential was significantly different between disease cases and controls), 
% the strains consuming and secreting the metabolites in each sample may be computed. 
% This will yield insight into the contribution of each strain to each metabolite. 
% Note that for metabolites for which the community wide secretion potential did 
% not differ, the strains contributing to metabolites may still be significantly 
% different.
% 
% The first step for the preparation of targeted analyses is the export of models 
% that had already been constrained with the simulated dietary regime. They can 
% be found in a subfolder called "Diet" in the results folder. Now, will set the 
% input variable modPath to the folder with personalized models constrained with 
% the simulated diet.

constrModPath = [resPath filesep 'Diet'];
%% 
% We will define a list of metabolites to analyze (default: all exchanged metabolites 
% in the models). As an example, we will take acetate and formate. Enter the VMH 
% IDs of target metabolites as a cell array.

metList = {'ac','for'};
%% 
% To run the computation of strain contributions:

[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);
%% 
% The output 'minFluxes' shows the fluxes in the reverse direction through all 
% internal exchange reactions that had nonzero flux for each analyzed metabolite. 
% The output 'maxFluxes' shows the corresponding forward fluxes. 'fluxSpans' shows 
% the distance between minimal and maximal fluxes for each internal exchange reaction 
% with nonzero flux for each metabolite.
% 
% Afterwards, statistical analysis of the strain contributions can also be performed.
% 
% Define the path where strains contributions are located:

contPath = [pwd filesep 'Contributions'];
%% 
% Run the analysis.

analyzeMgPipeResults(infoFilePath,contPath, 'sampleGroupHeaders', sampleGroupHeaders);
%% Targeted analysis: Computation of shadow prices for secreted metabolites of interest
% Shadow prices are routinely retrieved with each flux balance analysis solution. 
% Briefly, the shadow price is a measurement for the value of a metabolite towards 
% the optimized objective function, which indicates whether the flux through the 
% objective function would increase or decrease when the availability of this 
% metabolite would increase by one unit (Palsson B. Systems biology : properties 
% of reconstructed networks). For microbiome community models created through 
% mgPipe, this will enable us to determine which metabolites are bottlenecks for 
% the community's potential to secrete a metabolite of interest. This was performed 
% for bile acids in Heinken et al., Microbiome (2019) 7:75. However, any other 
% reaction in the personalized model (or any other model) can also serve as the 
% input.
% 
% We will compute the shadow prices for acetate and formate as an example.

objectiveList={
    'EX_ac[fe]'
    'EX_for[fe]'
    };
%% 
% Here, we will compute all shadow prices that are nonzero. Thus, this include 
% both metabolites that would increase and decrease the flux through the objective 
% function if their availability was increased. Note that the definition of the 
% shadow price depends on the solver.  To check the shadow price definitions for 
% each solver, run the test script testDualRCostDefinition.

SPDef = 'Nonzero';
%% 
% Run the computation.

[objectives,shadowPrices]=analyseObjectiveShadowPrices(constrModPath, objectiveList, 'SPDef', SPDef, 'numWorkers', numWorkers);
%% 
% Similar to the previous results, we can also perform statistical analysis 
% on the computed shadow prices.
% 
% Define path where computed shadow prices are located:

spPath = [pwd filesep 'ShadowPrices'];
%% 
% Run the analysis.

analyzeMgPipeResults(infoFilePath, spPath,'sampleGroupHeaders', sampleGroupHeaders);
%% 
%