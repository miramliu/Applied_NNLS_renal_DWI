%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

function DiffusionSpec_Anatomic(PatientNum)

%if both left and right
RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
%if only right or left
%RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};

%for 3mo, when there's only left or right: 
% If only left
%RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
% If only right
%RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};


for i = 1:length(RoiTypes)
    ROItype = RoiTypes{i}

    %% change line 27 in runnnls_ml to ReadpatientDWIData_3mo
    [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(PatientNum,ROItype);

    %plot(OutputDiffusionSpectrum);
    %pause(1)

    % for 3mo
    pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export_3mo';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra_3mo.xlsx']; % All results will save in excel file

    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'Sheet','Original','WriteMode','append')
    end

end

end