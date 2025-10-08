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
3. AGORAmodels: This folder serves as the modPath for reconstructing CSMMs. Because the full model set is large, I have uploaded only some AGORA models used in my study as examples. Please download the remaining AGORA models from Google Drive: https://shorturl.at/7hySD . After downloading, place the AGORA .mat files into the AGORA_1_03_mat folder.
4. BackupThaiCSMMs: This folder contains all 86 Thai CSMM .mat files generated in this study (Step 1 results).
   
**Citation**  
If you use this code in your work, please cite: TBA

**Contact**  
For questions, issues, or collaboration requests, please contact: Nachonase (nachon.rae@mahidol.ac.th)
