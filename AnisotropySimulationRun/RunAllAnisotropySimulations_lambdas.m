

% running these will run two or three peak, save it to a given file with specific names and lambdas
% it assumes averaged noise
%{
%% with two peak
% RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_0.1', 0.1)
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_2', 2)
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_8', 8)


%% with three peak
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_0.1', 0.1)
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_2', 2)
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_8', 8)
%}

%% and now with cross validation (again) just for timing and consistency
RunAndSave_AnisotropySimulation_9bvals_lambdas('two peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','two_peak_lambda_CV', 'Cross Validation')
RunAndSave_AnisotropySimulation_9bvals_lambdas('three peak', 'SimulatedDiffusionSpectra_Fits_lambdas.xlsx','three_peak_lambda_CV', 'Cross Validation')
