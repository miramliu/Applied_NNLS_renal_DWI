

%% Run all SWATHI renal allograft IVIM cases




% MAKE SURE THE EXCEL FILE IN THE CODE IS THE CORRECT EXPORT FILE. MUST BE SWATHI EXPORT!
%{
RA_DiffusionSpec_Voxelwise_fourpeaks('P001')
RA_DiffusionSpec_Voxelwise_fourpeaks('P002')
RA_DiffusionSpec_Voxelwise_fourpeaks('P003')


RA_DiffusionSpec_Voxelwise_fourpeaks('P006')

RA_DiffusionSpec_Voxelwise_fourpeaks('P007') % got april 10th 2024
RA_DiffusionSpec_Voxelwise_fourpeaks('P008') 
%RA_DiffusionSpec_Voxelwise_fourpeaks('P009') %weird ROIs

RA_DiffusionSpec_Voxelwise_fourpeaks('P024') % got april 10th 2024

RA_DiffusionSpec_Voxelwise_fourpeaks('P026')
RA_DiffusionSpec_Voxelwise_fourpeaks('P027')
RA_DiffusionSpec_Voxelwise_fourpeaks('P028')

RA_DiffusionSpec_Voxelwise_fourpeaks('P029')
RA_DiffusionSpec_Voxelwise_fourpeaks('P030')
RA_DiffusionSpec_Voxelwise_fourpeaks('P031')

RA_DiffusionSpec_Voxelwise_fourpeaks('P041')

%}

%% site 2 (cornell)
%for center 2, change PatientNumb to RA_02 rather than RA_01 in
%RA_DiffusionSpec_Voxelwise_fourpeaks, line 17 or 18


RA_DiffusionSpec_Voxelwise_fourpeaks('P007',2)
RA_DiffusionSpec_Voxelwise_fourpeaks('P008',2)
RA_DiffusionSpec_Voxelwise_fourpeaks('P009',2)
RA_DiffusionSpec_Voxelwise_fourpeaks('P010',2)
RA_DiffusionSpec_Voxelwise_fourpeaks('P011',2)
%}


%% healthy volunteers (thank you!!)
%must change 
%{
RA_DiffusionSpec_Voxelwise_fourpeaks('V004') %change line 16/17 to RA_01
RA_DiffusionSpec_Voxelwise_fourpeaks('V001') %change line 16/17 to RA_02
RA_DiffusionSpec_Voxelwise_fourpeaks('V005') %change line 16/17 to RA_01




%}