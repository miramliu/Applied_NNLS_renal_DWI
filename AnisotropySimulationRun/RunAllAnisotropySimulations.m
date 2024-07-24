%{
disp("true data")
RunAndSave_AnisotropySimulation('TrueData')

%disp('true w noise')
%RunAndSave_AnisotropySimulation('TrueNoise')

%disp('single direction w noise')
%RunAndSave_AnisotropySimulation('SingleNoise')

disp('3 averaged directions w noise')
RunAndSave_AnisotropySimulation('AveragedNoise')
%}


disp("true data")
RunAndSave_AnisotropySimulation_9bvals_firstmoments('TrueData')
RunAndSave_AnisotropySimulation_9bvals_firstmoments('TrueData_sorted')
%disp('true w noise')
%RunAndSave_AnisotropySimulation('TrueNoise')

%disp('single direction w noise')
%RunAndSave_AnisotropySimulation('SingleNoise')

disp('3 averaged directions w noise')
RunAndSave_AnisotropySimulation_9bvals_firstmoments('AveragedNoise')
RunAndSave_AnisotropySimulation_9bvals_firstmoments('AveragedNoise_sorted')