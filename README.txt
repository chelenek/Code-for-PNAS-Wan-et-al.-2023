This zip files contains the codes utilized in the manuscript "Mechanisms and Countermeasures of Mammalian Drug Resistance Acquired During Long-Term Evolution".
All MATLAB codes were run using R2022a, and all Dizzy codes were run using Java 8.0.361

File descriptions:

Dizzy Files:

NF_Original.cmdl: This contains the original model for the NF circuit, as described in Nevozhay, D. et al. "Negative Autoregulation Linearizes the Dose-Response and Suppresses the Heterogeneity of Gene Expression".

NF_CHO.cmdl: This contains the model updated to reflect the biological system as described in the main text of the manuscript


MATLAB Files:

NF_Fit.mlapp: This GUI simulates the model in "NF_Original.cmdl" with different parameter adjustments to see how it affected the dose response. Note that the file "NF_Original.cmdl" is needed for this app to run.

CHO_Model_Sim.m: This simulates the biological system as described in the main text of the manuscript. Note that the files "SimpDiz.m", "dizzy2matlab2.m", "createMobj.m", and "NF_CHO.cmdl" are needed for this script to run.

CHO_Model_DNA_loop.m: This repeats the model as described in "CHO_Model_Sim.m", but at different DNA copy numbers. Note that the files "SimpDiz.m", "dizzy2matlab2.m", "createMobj.m", and "NF_CHO.cmdl" are needed for this script to run.

CHO_Model_Experimental.n: This extracts and plots the experimental data from Farquhar, K. S. et al "Role of network-mediated stochasticity in mammalian drug resistance" and compares it to the simulation in "CHO_Model_Sim.m". Note that the files "CHO_Model_Sim.m" and the folder "mNF-PuroR" are needed for this script to run.

SimpDiz.m: This converts the raw Dizzy script into text compatable with the function "dizzy2matlab2.m".

dizzy2matlab2.m: This converts the reactions in the Dizzy script into the format needed for MATLAB's simulator

createMobj.m: This converts the reactions from the Dizzy script into the format needed for MATLAB's simulator

Zip Files:

mNF-PuroR: This zip file contains .mat files for the gated flow data from the public data repository for Farquhar, K. S. et al "Role of network-mediated stochasticity in mammalian drug resistance". Please refer to this depository for more information: https://openwetware.org/wiki/CHIP:Data
