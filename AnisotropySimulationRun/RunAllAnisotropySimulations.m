disp("true data")
RunAndSave_AnisotropySimulation('TrueData')

disp('true w noise')
RunAndSave_AnisotropySimulation('TrueNoise')

disp('single direction w noise')
RunAndSave_AnisotropySimulation('SingleNoise')

disp('3 averaged directions w noise')
RunAndSave_AnisotropySimulation('AveragedNoise')