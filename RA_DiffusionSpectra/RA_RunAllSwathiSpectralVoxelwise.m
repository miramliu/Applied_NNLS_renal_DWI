

%% Run all SWATHI renal allograft IVIM cases




% MAKE SURE THE EXCEL FILE IN THE CODE IS THE CORRECT EXPORT FILE. MUST BE SWATHI EXPORT!

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P001')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P002')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P003')


RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P006')

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P007') % got april 10th 2024
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P008') 
%RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P009') %weird ROIs

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P024') % got april 10th 2024

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P026')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P027')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P028')

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P029')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P030')
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P031')

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P041')

%}

%% site 2 (cornell)
%for center 2, change PatientNumb to RA_02 rather than RA_01 in
%RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment, line 17 or 18


RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P007',2)
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P008',2)
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P009',2)
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P010',2)
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('P011',2)
%}


%% healthy volunteers (thank you!!)
%must change 

RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('V004') %change line 16/17 to RA_01
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('V001') %change line 16/17 to RA_02
RA_DiffusionSpec_Voxelwise_fourpeaks_firstmoment('V005') %change line 16/17 to RA_01




%}