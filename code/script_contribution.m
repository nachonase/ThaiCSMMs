%% Statistical analysis and plotting of generated fluxes
resPath = [pwd filesep 'Results'];
constrModPath = [resPath filesep 'Diet_run'];
metList = {'ac', 'but', 'ppa', 'isobut'};
computeProfiles = true;
numWorkers = 4;

%EX_ac[fe]	Exchange of Acetate
%EX_but[fe]	Exchange of Butyric acid
%EX_ppa[fe]	Exchange of Propionate
%EX_isobut[fe]	Isobutyrate exchange

[minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(constrModPath, 'metList', metList, 'numWorkers', numWorkers);
