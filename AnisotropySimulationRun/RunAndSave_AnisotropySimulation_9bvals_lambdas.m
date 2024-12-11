%% saving and running on signal input
function RunAndSave_AnisotropySimulation_9bvals_lambdas(NumberofCompartments, ExportfileName, ExportSheetName, lambda)

%% read in data
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240529.xlsx']; % All results will save in excel file
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240611.xlsx']; % All results will save in excel file
    %pathtoCSV=[pathtodata, '/','MultiExpSimulatedCurves_20240624.xlsx']; % 

    if strcmp(NumberofCompartments, 'three peak')
        %pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_20240624.xlsx']; for all Gaussian, first submission to MRM september 2024
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11142024.xlsx']; %for anomalous diffusion, second submission to MRM
    elseif strcmp(NumberofCompartments, 'two peak')
        %pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_20240611.xlsx']; % for all Gaussian, first submission to MRM September 2024
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11182024.xlsx']; %for anomalous diffusion, second submission to MRM

    else
        error('please say it is either two peak or three peak')
    end

    

    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:M','Sheet', 'AveragedNoise');
    disp(['running... ' ExportSheetName])
    disp(['started: '  + string(datetime("now"))])

    % create sheet
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    ExcelFileName=[pathtodata, '/',ExportfileName]; % All results will save in excel file
    Header = {'Run Number',	'fast fraction',	'med fraction'	'slow fraction',	'fast diffusion',	'med diffusion',	'slow diffusion',	'rsq', 'number of peaks'};
    writecell(Header,ExcelFileName,'WriteMode','append','Sheet',[ExportSheetName '_sorted'])
    writecell(Header,ExcelFileName,'WriteMode','append','Sheet',ExportSheetName)


%% fit and export data
    for j = 1:size(DataFrame,1)
        RunNum = DataFrame(j,'Run Number');
        %% for first submission, which has 11 b-values
        %{
        DataCurve_j = DataFrame(j,["b0","b10","b30","b50","b80","b120","b200","b400","b800","b1100","b1380"]);
        %% now cut the data, remove the last two
        DataCurve_j=DataCurve_j(:,1:end-2);
        %}

        %% for second submission, which only used 9 b-values
        DataCurve_j = DataFrame(j,["b0","b10","b30","b50","b80","b120","b200","b400","b800"]);

        SignalInput = zeros(9,1);
        SignalInput = SignalInput + table2array(DataCurve_j)';

        Run_SpectralFit(RunNum, SignalInput, ExportfileName, ExportSheetName, lambda) % export and import sheet arae same name... 
    end
    disp(['Completed: ' + string(datetime("now"))])
end






%% nested function
function Run_SpectralFit(RunNum, SignalInput, ExportfileName, ExportSheetName, lambda)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    addpath ../../Applied_NNLS_renal_DWI/PN_DiffusionSpectra/

    
    b_values = [0,10,30,50,80,120,200,400,800];%, 1100, 1380]; % simulated b values
    %% saving and running on signal input

    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);

        %lambda=2
        if strcmp(lambda, 'Cross Validation')
            [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve,b_values);
        else
            [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_lambda(currcurve,b_values, lambda); %best results so far regarding Mann-Whitney U & AUC
        end
    
        if rsq>0.7
            rawfracs = resultsPeaks(1:3);
            rawpeaknumber = nnz(rawfracs);
            dataarray={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq, rawpeaknumber};
            

            % now also sort it!
            dataarray_sorted={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq, rawpeaknumber};

            if resultsPeaks(2) < 5
                newfrac = resultsPeaks(3) + resultsPeaks(2);
                newdiff = (resultsPeaks(3)*resultsPeaks(6) + resultsPeaks(2)*resultsPeaks(5))/(resultsPeaks(3) + resultsPeaks(2));

                sortedfracs = [resultsPeaks(1),0,newfrac];
                sortedpeaknumber = nnz(sortedfracs);

                dataarray_sorted={resultsPeaks(1),0,newfrac,resultsPeaks(4),0,newdiff,rsq, sortedpeaknumber};
            end
            
        else
            dataarray={0, 0, 0, 0, 0, 0,rsq, 0};
            dataarray_sorted={0, 0, 0, 0, 0, 0,rsq, 0};
        end
    end


    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
    ExcelFileName=[pathtodata, '/',ExportfileName]; % All results will save in excel file


    % i hate matlab. so ineffficient my god. 
    why = table2array(RunNum);
    Identifying_Info = {why{1}};
    %disp(Identifying_Info)

    
    
    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',ExportSheetName ); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
    if sum(idx)==0
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',ExportSheetName)
    end

    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',[ExportSheetName, '_sorted']); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
    if sum(idx)==0
        Export_Cell = [Identifying_Info,dataarray_sorted];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',[ExportSheetName ,'_sorted'])
    end



    

end