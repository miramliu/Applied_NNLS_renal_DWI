

% running these will run two or three peak, save it to a given file with specific names and lambdas
% it assumes averaged noise
%{
%% with two peak
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_0.1', 0.1)
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_2', 2)
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_8', 8)


%% with three peak
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_0.1', 0.1)
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_2', 2)
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_8', 8)


%% and now with cross validation (again) just for timing and consistency

RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_CV', 'Cross Validation')
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedAnomalousDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_CV', 'Cross Validation')
%}


%% now for resubmission, with the corrected anisotropy and anomalous
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('two peak', 'Simulated_2peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_01', 0.1)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('two peak', 'Simulated_2peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_2', 2)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('two peak', 'Simulated_2peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_8', 8)


%% with three peak
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('three peak', 'Simulated_3peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_01', 0.1)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('three peak', 'Simulated_3peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_2', 2)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('three peak', 'Simulated_3peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_8', 8)


%% and now with cross validation (again) just for timing and consistency

RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('two peak', 'Simulated_2peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_CV', 'Cross Validation')
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('three peak', 'Simulated_3peak_AnomalousDiffusionSpectra_Fits_lambdas.xlsx','lmd_CV', 'Cross Validation')
%}


% for the single compartment anomalous test
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('slow peak', 'Simulated_1peak_AnomalousDiffusionSpectra_Fits_slow.xlsx','lmd_01', 0.1)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('med peak', 'Simulated_1peak_AnomalousDiffusionSpectra_Fits_med.xlsx','lmd_01', 0.1)
RunAndSave_AnomalousAnisotropySimulation_9bvals_lambdas('fast peak', 'Simulated_1peak_AnomalousDiffusionSpectra_Fits_med.xlsx','lmd_01', 0.1)
