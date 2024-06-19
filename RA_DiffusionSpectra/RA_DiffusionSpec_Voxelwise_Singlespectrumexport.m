%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function RA_DiffusionSpec_Voxelwise_Singlespectrumexport(varargin)
    name = varargin{1};
    SignalInput = varargin{2};
    RunAndSave_voxelwise_spectrum(name,SignalInput')

end


%% saving and running on signal input
function RunAndSave_voxelwise_spectrum(name,SignalInput)

    %% saving and running on signal input
    %disp([PatientNum '_' ROItype])
    %% trying tri-exponential!
    
    %bvalues = [0,10,30,50,80,120,200,400,800];
    count = 0;
    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(currcurve);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(currcurve);
        [DiffusionSpec, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks(currcurve); %best results so far regarding Mann-Whitney U & AUC

        SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);
        ffastvalues_sort = SortedresultsPeaks(1);
        fmedvalues_sort = SortedresultsPeaks(2);
        fslowvalues_sort = SortedresultsPeaks(3);
        ffibrovalues_sort = SortedresultsPeaks(4);
        Dfastvalues_sort= SortedresultsPeaks(5);
        Dmedvalues_sort = SortedresultsPeaks(6);
        Dslowvalues_sort = SortedresultsPeaks(7);
        Dfibrovalues_sort = SortedresultsPeaks(8);
       
        resultsPeaks = [ffastvalues_sort, fmedvalues_sort, fslowvalues_sort, ffibrovalues_sort, Dfastvalues_sort, Dmedvalues_sort, Dslowvalues_sort, Dfibrovalues_sort];
    end
    
                

            %% trying tri-exponential!
        %addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
        %bvals = [10,30,50,80,120,200,400,800];
        %[resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(SignalInput,bvals);
    
        %plot(OutputDiffusionSpectrum);
        %pause(1)

    dataarray = {resultsPeaks,rsq, DiffusionSpec};

    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python';
    ExcelFileName=[pathtodata, '/','RA_Spectra.xlsx']; % All results will save in excel file



    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {name};
    disp('saving data in excel')
    Export_Cell = [Identifying_Info,dataarray];
    writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','SpectralPlots')
    %Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','SpectralPlots'); %read only identifying info that already exists
    %MatchFunc = @(A,B)cellfun(@isequal,A,B);
    %idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    %if sum(idx)==0
        %disp('saving data in excel')
        %Export_Cell = [Identifying_Info,dataarray];
        %writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','SpectralPlots')
    %end

end
