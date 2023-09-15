%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function DiffusionSpec_Anatomic_Averaged(varargin)
    PatientNum = varargin{1};
    if nargin == 1 || nargin == 2 && varargin{2} ~= 1
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
    
        medulregL = regexp(RoiTypes, '^R.*.M$','match'); medulregL = medulregL(~cellfun('isempty',medulregL)); medulregL = medulregL{:};
        medulregR = regexp(RoiTypes, '^R.*.M$','match'); medulregR = medulregR(~cellfun('isempty',medulregR)); medulregR = medulregR{:};
    
        %% left kidney
        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulregL, ab); 
        %fit that and save it
        RunAndSave(PatientNum,'L_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortregL, ab); 
        %fit that and save it
        RunAndSave(PatientNum,'L_C',SignalInput)
    
        %% right kidney
        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulregR, ab); 
        %fit that and save it
        RunAndSave(PatientNum,'R_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortregR, ab); 
        %fit that and save it
        RunAndSave(PatientNum,'R_C',SignalInput)
    elseif nargin == 2 && varargin{2} ==1
            RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
            medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
            cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};
    
            ab = 14;
    
            % get average medullar ROI
            SignalInput = AverageOverROIs(PatientNum, medulreg, ab); 
            %fit that and save it
            RunAndSave(PatientNum,'_M',SignalInput)
            % get average cortical ROI
            SignalInput = AverageOverROIs(PatientNum, cortreg, ab); 
            %fit that and save it
            RunAndSave(PatientNum,'_C',SignalInput)
    else
        error('incorrect input')
    end
end

function SignalInput = AverageOverROIs(PatientNum, ROItypenames, ab) 

    for j = 1:length(ROItypenames)
        ROItypename = [PatientNum '_' ROItypenames{j}];
        %% CHANGE HERE FOR BASELINE, 3M0 OR 12MO
        if j == 1
            SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
            %SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype);
    
            %to match bi-exp, normalizing to b0
            SignalInput_av = SignalInput(:)/SignalInput(1);
        else
            SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
            SignalInput_av = SignalInput_av + SignalInput;
        end
        SignalInput = SignalInput_av/length(ROItypenames);
    end
end

function RunAndSave(PatientNum, ROItype,SignalInput)
    disp(PatientNum)
    disp(ROItype)
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(SignalInput);
    [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(SignalInput);

    %plot(OutputDiffusionSpectrum);
    %pause(1)


    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra_TG.xlsx']; % All results will save in excel file

   
    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','TG_DTissueDblood_AV'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'Sheet','TG_DTissueDblood_AV','WriteMode','append')
    end

end