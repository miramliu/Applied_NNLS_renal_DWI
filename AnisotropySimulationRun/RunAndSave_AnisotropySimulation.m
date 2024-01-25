%% saving and running on signal input
function RunAndSave_AnisotropySimulation(ImportSheetName)

%% read in data
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    pathtoCSV=[pathtodata, '/','Test.xlsx']; % All results will save in excel file


    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:M','Sheet', ImportSheetName);    


%% fit and export data
    for j = 1:size(DataFrame,1)
        RunNum = DataFrame(j,'Run Number');
        DataCurve_j = DataFrame(j,["b0","b10","b30","b50","b80","b120","b200","b400","b800","b1100","b1380"]);
        SignalInput = zeros(11,1);
        SignalInput = SignalInput + table2array(DataCurve_j)';
        Run_SpectralFit(RunNum, SignalInput, ImportSheetName) % export and import sheet arae same name... 
    end
end






%% nested function
function Run_SpectralFit(RunNum, SignalInput, ExportSheetName)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    addpath ../../Applied_NNLS_renal_DWI/PN_DiffusionSpectra/

    
    b_values = [0,10,30,50,80,120,200,400,800, 1100, 1380]; % simulated b values
    %% saving and running on signal input

    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);

        [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve,b_values); %best results so far regarding Mann-Whitney U & AUC
    
        if rsq>0.7
            dataarray={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};

        else
            dataarray={NaN, NaN, NaN, NaN, NaN, NaN,rsq};
        end
    end


    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits.xlsx']; % All results will save in excel file

    % i hate matlab. so ineffficient my god. 
    why = table2array(RunNum);
    Identifying_Info = {why{1}};
    disp(Identifying_Info)
    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',ExportSheetName); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',ExportSheetName)
    end

end