**Overview**   
This repository is for modeling diet–gut microbiome interactions based on Thai adult microbiome profiles.  
The pipeline simulates microbial metabolic activity under Thai dietary and prebiotic conditions.  

The modeling workflow consists of three parts:  
1. Reconstruction and modeling of Thai community-scale metabolic models (CSMMs) using an average Thai diet  
2. Prediction of microbial contributions to SCFA production  
3. Simulation of prebiotic responses and uptake flux analysis  

**Installation**  
Install MATLAB (tested with R2024a).  
Install COBRA Toolbox  

**Usage**  
Run the main pipeline in main.m

**Supplementary folders**
1. ThaiDietData: data in this folder are used for calculating the average Thai diet.
2. Codes: this foldar contains in-house MATLAB scripts developed and used for data preprocessing.
3. AGORAmodels: this folder is used as modPath for reconstructing CSMMs.
   
**Citation**  
If you use this code in your work, please cite: TBA

**Contact**  
For questions, issues, or collaboration requests, please contact: Nachonase (nachon.rae@mahidol.ac.th)
