initCobraToolbox(false)

%% prepare modPath
%websave('AGORA-master.zip','https://github.com/VirtualMetabolicHuman/AGORA/archive/master.zip')
%try
%    unzip('AGORA-master')
%end

modPath = [pwd filesep 'AGORA-master' filesep 'CurrentVersion' filesep 'AGORA_1_03' filesep' 'AGORA_1_03_mat'];

%% prepare abunFilePath

cutoff = 0.1;
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
infoFilePath = '';
numWorkers = 4;

%% 
[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary] = initMgPipe(modPath, ...
    abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);

%% Computed outputs
%% 
% # *Metabolic diversity* The number of mapped organisms for each individual 
% compared to the total number of unique reactions (extrapolated by the number 
% of reactions of each organism).Please, note that bigger circles with a number 
% inside represent overlapping individuals for metabolic diversity. 
% # *Classical multidimensional scaling of each individual reactions repertoire* 
% in the Y output variable
% # *Personalized model sizes:* reaction and metabolites numbers for all created 
% models in the modelStats output and averages, median, minimal, and maximal values 
% in the summary output.
%% 
% *If flux variability analysis is performed and net uptake and secretion potential 
% are computed:*
% 
% Flux Variability analysis for all the exchange reactions of the diet and fecal 
% compartment are performed and temporarily saved in a file called "simRes". Specifically 
% what is temporarily saved is:
%% 
% # *fvaCt* a cell array containing min flux through uptake and max through 
% secretion exchanges
% # *nsCt* a cell array containing max flux through uptake and min trough secretion 
% exchanges
% # *presol* an array containing the value of objectives for each microbiota 
% model with rich and selected diet
% # *inFesMat* cell array containing the names of the microbiota models that 
% reported an infeasible status when solved for their objective 
%% 
% Finally, the net uptake and secretion potential are computed in a metabolite 
% resolved manner and saved in the output variables 'netSecretionFluxes' and netUptakeFluxes, 
% and the files 'netSecretionFluxes.csv' and 'netUptakeFluxes.csv' in the results 
% folder. They indicate the maximal uptake and production, respectively, of each 
% metabolite and are computed as the absolute value of the sum of the maximal 
% secretion flux with the maximal uptake flux. The similarity of metabolic secretion 
% profiles (using the net secretion potential as features) between individuals 
% is also evaluated with classical multidimensional scaling. 
% 
% The output file "ReactionAbundance.csv" in the Results folder contains the 
% relative abundance of each reaction in each sample. A description of each reaction 
% can be found by searching for the reaction ID in the file cobratoolbox/papers/2021_demeter/input/ReactionDatabase.txt 
% or on the Virtual Metabolic Human website (https://www.vmh.life/). For a more 
% convenient overview of pathways altered in their relative abundances across 
% samples, the relative abundances on the subsystem level are also computed and 
% saved as the file SubsystemAbundance.txt. A plot of the relative subsystem abundances 
% is also generated.
% 
% In the export of models with dietary constraints is desired, they will be 
% found in the folder constrModelsPath.
%% Correlation between computed fluxes and abundances and different taxon levels
% For an overview of metabolite-taxa relationships, the computed uptake and 
% secretion profiles for each metabolite can be correlated with taxon abundances 
% on different levels (species, genus, etc.). Note that a correlation may not 
% neccessarily imply that the metabolite is synthesized by a given taxon. To exactly 
% determine the relationships between metabolites and taxa in the models, organism-level 
% contributions to metabolites can be computed (see below). However, these computations 
% are much more computationally intensive than the calculation of correlations.
% 
% To calculate the Spearman correlation (alternatively: 'Pearson', 'Kendall'),  
% between net secretion fluxes and abundances on different taxon levels, run the 
% code:
% 
% taxonomy info for AGORA

taxInfo = 'AGORA_infoFile.xlsx';
%% 
% Path to fluxes that should be correlated

fluxPath = [pwd filesep 'Results' filesep 'inputDiet_net_secretion_fluxes.csv'];
corrMethod = 'Spearman';
[FluxCorrelations, PValues, TaxonomyInfo] = correlateFluxWithTaxonAbundance(abunFilePath, fluxPath, taxInfo, corrMethod);
%% 
% The output variable TaxonomyInfo will have the list of annotations for each 
% entry on each taxon level. This can be used to plot the correlations as a heatmap 
% with annotations, e.g., in R.
%% Metabolite-resolved plots of metabolite-strain correlations
% For a more detailed view of the relationships between metabolites and abundances, 
% the fluxes can also be directly plotted against organism abundances. This may 
% reveal microbes that are bottlenecks for the production of metabolites of interest.
% 
% We will define the metabolites to analyze (default: all exchanged metabolites 
% in the models). As an example, we will take only one metabolite, acetate. Enter 
% the VMH IDs of target metabolites as a cell array.

metList = {'ac'};
%% 
% Define the path to net secretion fluxes.

fluxPath = [pwd filesep 'Results' filesep 'inputDiet_net_secretion_fluxes.csv'];
%% 
% To plot microbe-metabolite relationships for these metabolites, execute the 
% code

plotFluxesAgainstOrganismAbundances(abunFilePath,fluxPath,metList);
%% 
% Afterwards, the plots will be in the subfolder Metabolite_plots.
%% Stratification of samples
% If metadata for the analyzed samples is available (e.g., disease state), the 
% samples can be stratified based on this classification. To provide metadata, 
% prepare an input file as in the example 'sampInfo.csv'. The path to the file 
% with sample information needs to be provided as the variable infoFilePath. Note 
% that the group classification into groups in sampInfo.csv is arbitrary and not 
% biological meaningful.
% 
% Run the pipeline again, this time with sample stratification into groups provided. 
% The PCoAs will now be labelled with sample stratification into groups.



infoFilePath='sampInfo10.csv'; 

[init, netSecretionFluxes, netUptakeFluxes, Y, modelStats, summary, statistics] = initMgPipe(modPath, abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'infoFilePath', infoFilePath, 'numWorkers', numWorkers);
%% Statistical analysis and plotting of generated fluxes
% If sample information as in sampInfo.csv is provided (e.g., healthy vs. disease 
% state), statistical analysis can be performed to identify whether net secretion 
% fluxes, net uptake fluxes, and reaction abundances can be performed. If the 
% analyzed samples can be divided into two groups, Wilcoxon rank sum test will 
% be used. If there are three or more groups, Kruskal-Wallis test will be performed. 
% Note that no statistically significant differences will be found in the tutorial 
% example due to the small sample sizes. Moreover, violin plots that show the 
% computed fluxes separate by group will be generated.
% 
% Define the input variables. Path to file with sample information (required)

infoFilePath='sampInfo10.csv';

%% 
% Header in the file with sample information with the stratification to  analyze 
% (if not provided, the second column will be chosen by default)

sampleGroupHeaders={'Group'};
%% 
% sampleGroupHeaders can contain more than one entry if multiple columns  with 
% sample information (e.g., disease state, age group) should be analyzed.
% 
% Define the path with results of mgPipe that will be analyzed.

resPath = [pwd filesep 'Results'];
%% 
% To perform the statistical analysis and save the results, enter the code

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