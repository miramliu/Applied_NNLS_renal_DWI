%% saving and running on signal input
function RunAndSave_AnomalousAnisotropySimulation_9bvals_peaknumber(NumberofCompartments, ExportfileName, ExportSheetName_base, lambda)

%% read in data
    pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';

    if strcmp(NumberofCompartments, 'three peak')
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11142024.xlsx']; %for anomalous diffusion, second submission to MR
    elseif strcmp(NumberofCompartments, 'two peak')
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11182024.xlsx']; %for anomalous diffusion, second submission to MRM
    %{
    elseif strcmp(NumberofCompartments, 'slow peak')
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11272024_sub.xlsx']; %for anomalous diffusion, second submission to MRM
    elseif strcmp(NumberofCompartments, 'med peak')
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11272024_med.xlsx']; %for anomalous diffusion, second submission to MRM
    elseif strcmp(NumberofCompartments, 'fast peak')
        pathtoCSV = [pathtodata, '/', 'MultiExpSimulatedCurves_anomalous_11272024_fast.xlsx']; %for anomalous diffusion, second submission to MRM
    %}
    else
        error('please say it is either two peak or three peak')
    end

    
    names = sheetnames( pathtoCSV ) % get all types of simulated data
    test = contains(names,'AN_'); %only those with anisotropic noise
    names = names(test);
    for j=1:length(names) %-1 to avoid the parameters sheet 
        
        DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:M','Sheet', names{j});
        ExportSheetName = [ExportSheetName_base '_' names{j}];

        pathtodata = '/Users/miraliu/Desktop/PostDocCode/Multiexp_Simulations_python/';
        ExcelFileName=[pathtodata, '/',ExportfileName]; % All results will save in excel file
        
        % check if sheet already exists
        if ~ismember(ExportSheetName,sheetnames(ExcelFileName))
    
            %start timers
            disp(['running... ' ExportSheetName])
            disp(['started: '  + string(datetime("now"))])
            started = ['started: '  + string(datetime("now"))];
            t0 = tic(); %start timer
            % create sheet
            
            Header = {'Run Number',	'fast fraction',	'med fraction'	'slow fraction', 'fourth fraction',	'fast diffusion',	'med diffusion',	'slow diffusion',	'fourth diffusion', 'rsq', 'number of peaks'};
            writecell(Header,ExcelFileName,'WriteMode','append','Sheet',[ExportSheetName '_s']) %hanged to s to keep under length of 31 charaacters for excel.
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
            ended = ['Completed: ' + string(datetime("now"))];
    
            dt = toc(t0);
            Export_Cell = [ExportSheetName,started,ended, dt];
            writematrix(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Computational Timing')
        else
            disp(['already processed' ExportSheetName])
        end
    end
end






%% nested function NOW NO PEAK SET. CAN BE FOUR!!!!!!! 
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
            [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks_lambda(currcurve,b_values, lambda); %best results so far regarding Mann-Whitney U & AUC
        end
    
        if rsq>0.7
            rawfracs = resultsPeaks(1:4);
            rawpeaknumber = nnz(rawfracs);
            dataarray={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),resultsPeaks(7),resultsPeaks(8),rsq, rawpeaknumber};
            
%{
            % now also sort it!
            dataarray_sorted={resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq, rawpeaknumber};

            if resultsPeaks(2) < 5
                newfrac = resultsPeaks(3) + resultsPeaks(2);
                newdiff = (resultsPeaks(3)*resultsPeaks(6) + resultsPeaks(2)*resultsPeaks(5))/(resultsPeaks(3) + resultsPeaks(2));

                sortedfracs = [resultsPeaks(1),0,newfrac];
                sortedpeaknumber = nnz(sortedfracs);

                dataarray_sorted={resultsPeaks(1),0,newfrac,resultsPeaks(4),0,newdiff,rsq, sortedpeaknumber};
            end
%}
            dataarray_sorted={0, 0, 0, 0, 0, 0,rsq, 0};
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

    Existing_Data = readcell(ExcelFileName,'Range','A:A','Sheet',[ExportSheetName, '_s']); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
    if sum(idx)==0
        Export_Cell = [Identifying_Info,dataarray_sorted];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet',[ExportSheetName ,'_s'])
    end



    

end