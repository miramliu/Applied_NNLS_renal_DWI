%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function DiffusionSpec_Voxelwise(varargin)
    PatientNum = varargin{1};
    if nargin == 1 || nargin == 2 && varargin{2} > 10
        %if both left and right
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        if nargin == 2
            ab = varargin{2};
        else
            ab = 14; %assuming 4 slices (i.e. C1 - C4)
        end
    
        %Split into cortical and medul, and left and right
        cortregL = regexp(RoiTypes, '^L.*.C$','match'); cortregL =cortregL(~cellfun('isempty',cortregL)); cortregL = cortregL{:};
        cortregR = regexp(RoiTypes, '^R.*.C$','match'); cortregR =cortregR(~cellfun('isempty',cortregR)); cortregR = cortregR{:};
    
        medulregL = regexp(RoiTypes, '^L.*.M$','match'); medulregL = medulregL(~cellfun('isempty',medulregL)); medulregL = medulregL{:};
        medulregR = regexp(RoiTypes, '^R.*.M$','match'); medulregR = medulregR(~cellfun('isempty',medulregR)); medulregR = medulregR{:};
    
        %% left kidney
        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulregL, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortregL, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'LK_C',SignalInput)
    
        %% right kidney
        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulregR, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortregR, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'RK_C',SignalInput)
    elseif nargin == 2 && varargin{2} ==1
        RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
        medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'C',SignalInput)
%% only L kidney
    elseif nargin == 2 && varargin{2} ==2
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        medulreg = regexp(RoiTypes, '^L.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^L.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'LK_C',SignalInput)
%% only R kidney
    elseif nargin == 2 && varargin{2} ==3
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        medulreg = regexp(RoiTypes, '^R.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^R.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'RK_C',SignalInput)

    elseif nargin == 2 && varargin{2} == 4
        SignalInput = ReadPatientDWIData_Lesion(PatientNum, 'Lesion'); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'Lesion',SignalInput)
    else
        error('incorrect input')
    end
end


