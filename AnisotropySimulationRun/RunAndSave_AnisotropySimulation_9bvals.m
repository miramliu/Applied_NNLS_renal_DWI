%% saving and running on signal input
function RunAndSave_AnisotropySimulation_9bvals(ImportSheetName)

%% read in data
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240529.xlsx']; % All results will save in excel file
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240611.xlsx']; % All results will save in excel file
    pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240624.xlsx'];

    if contains(ImportSheetName, 'sorted')
        DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:M','Sheet', ImportSheetName(1:end-7));
    else
        DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:M','Sheet', ImportSheetName);
    end


%% fit and export data
    for j = 1:size(DataFrame,1)
        RunNum = DataFrame(j,'Run Number');
        DataCurve_j = DataFrame(j,["b0","b10","b30","b50","b80","b120","b200","b400","b800","b1100","b1380"]);

        %% now cut the data, remove the last two
        DataCurve_j=DataCurve_j(:,1:end-2);
        
        SignalInput = zeros(9,1);
        SignalInput = SignalInput + table2array(DataCurve_j)';

        Run_SpectralFit(RunNum, SignalInput, ImportSheetName) % export and import sheet arae same name... 
    end
end






%% nested function
function Run_SpectralFit(RunNum, SignalInput, ExportSheetName)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    addpath ../../Applied_NNLS_renal_DWI/PN_DiffusionSpectra/

    
    b_values = [0,10,30,50,80,120,200,400,800];%, 1100, 1380]; % simulated b values
    %% saving and running on signal input

    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);

        lambda=2
        [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve,b_values, lambda); %best results so far regarding Mann-Whitney U & AUC
    
        if rsq>0.7
            dataarray={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
            % now also sort it!
            dataarray_sorted={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};

            if resultsPeaks(2) < 5
                newfrac = resultsPeaks(3) + resultsPeaks(2);
                newdiff = (resultsPeaks(3)*resultsPeaks(6) + resultsPeaks(2)*resultsPeaks(5))/(resultsPeaks(3) + resultsPeaks(2));

                dataarray_sorted={resultsPeaks(1),0,newfrac,resultsPeaks(4),0,newdiff,rsq};
            end
            
        else
            dataarray={0, 0, 0, 0, 0, 0,rsq};
            dataarray_sorted={0, 0, 0, 0, 0, 0,rsq};
        end
    end


    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    %ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits.xlsx']; % All results will save in excel file
    %ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits_20240529.xlsx']; % All results will save in excel file
    ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits_20240722_9bvals.xlsx']; % All results will save in excel file

    % i hate matlab. so ineffficient my god. 
    why = table2array(RunNum);
    Identifying_Info = {why{1}};
    disp(Identifying_Info)
    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',string(ExportSheetName)+'_regdNNLS_2'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        if contains(ExportSheetName, 'sorted')
            Export_Cell = [Identifying_Info,dataarray_sorted];
        else
            Export_Cell = [Identifying_Info,dataarray];
        end
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',string(ExportSheetName)+'_regdNNLS_2')

    end

end