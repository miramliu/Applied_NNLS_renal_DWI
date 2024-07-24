%% saving and running on signal input
function RunAndSave_AnisotropySimulation_9bvals_firstmoments(ImportSheetName)

%% read in data
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240529.xlsx']; % All results will save in excel file
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240611.xlsx']; % All results will save in excel file


    %% this one is two peak
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240624.xlsx']; %this one is??? two peak??

    %% this one is three peakMultiExpSimulatedCurves_20240611
    pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240611.xlsx']; %this one is??? two peak??


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

        Run_SpectralFit_firstmoments(RunNum, SignalInput, ImportSheetName) % export and import sheet arae same name... 
    end
end






%% nested function
function Run_SpectralFit_firstmoments(RunNum, SignalInput, ExportSheetName)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    addpath ../../Applied_NNLS_renal_DWI/PN_DiffusionSpectra/

    
    b_values = [0,10,30,50,80,120,200,400,800];%, 1100, 1380]; % simulated b values
    %% saving and running on signal input

    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);

        lambda=8;
        [~, rsq, ~, ~, resultsPeaks, firstmoments] = RunNNLS_ML_fourpeaks_firstmoment(currcurve,b_values, lambda); 

        [SortedresultsPeaks, Sortedmoments] = ReSort_fourpeaks_firstmoments(resultsPeaks, firstmoments);

        if rsq>0.7
            dataarray={SortedresultsPeaks(1),SortedresultsPeaks(2),SortedresultsPeaks(3),SortedresultsPeaks(4),SortedresultsPeaks(5),SortedresultsPeaks(6),rsq};
            % now also sort it!
            dataarray_sorted={SortedresultsPeaks(1),SortedresultsPeaks(2),SortedresultsPeaks(3),SortedresultsPeaks(4),SortedresultsPeaks(5),SortedresultsPeaks(6),rsq};
            dataarray_fd_sorted = {Sortedmoments(1:3)};

            if SortedresultsPeaks(2) < 5
                newfrac = SortedresultsPeaks(3) + SortedresultsPeaks(2);
                newdiff = (SortedresultsPeaks(3)*SortedresultsPeaks(6) + SortedresultsPeaks(2)*SortedresultsPeaks(5))/(SortedresultsPeaks(3) + SortedresultsPeaks(2));

                dataarray_sorted={SortedresultsPeaks(1),0,newfrac,SortedresultsPeaks(4),0,newdiff,rsq};

                dataarray_fd_sorted={Sortedmoments(1), 0, Sortedmoments(2)+Sortedmoments(3)};
            end
            
        else
            dataarray={0, 0, 0, 0, 0, 0,rsq};
            dataarray_sorted={0, 0, 0, 0, 0, 0,rsq};
            dataarray_fd_sorted = {0,0,0};
        end
    end


    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    %ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits.xlsx']; % All results will save in excel file
    %ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits_20240529.xlsx']; % All results will save in excel file
    ExcelFileName=[pathtodata, '/','SimulatedDiffusionSpectra_Fits_20240722_3pk_9bvals_lambda8.xlsx']; % All results will save in excel file

    % i hate matlab. so ineffficient my god. 
    why = table2array(RunNum);
    Identifying_Info = {why{1}};
    %disp(Identifying_Info)
    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',string(ExportSheetName)); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        %disp('saving data in excel')
        if contains(ExportSheetName, 'sorted')
            Export_Cell = [Identifying_Info,dataarray_sorted,dataarray_fd_sorted];
        else
            Export_Cell = [Identifying_Info,dataarray];
        end
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',string(ExportSheetName))

    end

end