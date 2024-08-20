%% saving and running on signal input
function RunAndSave_voxelwise_ReSortedFourpeak(PatientNum, ROItype,SignalInput)

    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    %% trying tri-exponential!
    
    % sorted
    ffastvalues_sort = zeros(size(SignalInput,2),1);
    fmedvalues_sort = zeros(size(SignalInput,2),1);
    fslowvalues_sort = zeros(size(SignalInput,2),1);
    %ffibrovalues_sort = zeros(size(SignalInput,2),1);
    Dfastvalues_sort = zeros(size(SignalInput,2),1);
    Dmedvalues_sort = zeros(size(SignalInput,2),1);
    Dslowvalues_sort = zeros(size(SignalInput,2),1);
    %Dfibrovalues_sort = zeros(size(SignalInput,2),1);
    rsqvalues = zeros(size(SignalInput,2),1);

    rawpeaknumber = zeros(size(SignalInput,2),1);
    sortedpeaknumber = zeros(size(SignalInput,2),1);

    %bvalues = [0,10,30,50,80,120,200,400,800];
    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(currcurve);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(currcurve);

        %% original
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve); %best results so far regarding Mann-Whitney U & AUC

        %% faster
        b_values = [0,10,30,50,80,120,200,400,800]; %if original 9 
        lambda = 0.1;
        [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks_lambda(currcurve, b_values, lambda);

    
        if rsq>0.7
            if resultsPeaks(1)<1000 %it's set to 10000 if no peaks found, see line 32 of NNLS_result_mod

                % now  try to sort them... 
                %SortedresultsPeaks = ReSort_SpectralPN(resultsPeaks);

                % changed July 2024 to try fourpeak sorting
                % note: ignoring the fourth peak! 

                SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);

                ffastvalues_sort(voxelj,1) = SortedresultsPeaks(1);
                fmedvalues_sort(voxelj,1) = SortedresultsPeaks(2);
                fslowvalues_sort(voxelj,1) = SortedresultsPeaks(3);
                %ffibrovalues_sort(voxelj,1) = SortedresultsPeaks(4);
                Dfastvalues_sort(voxelj,1) = SortedresultsPeaks(5);
                Dmedvalues_sort(voxelj,1) = SortedresultsPeaks(6);
                Dslowvalues_sort(voxelj,1) = SortedresultsPeaks(7);
                %Dfibrovalues_sort(voxelj,1) = SortedresultsPeaks(8);
                rsqvalues(voxelj,1) = rsq;


                % number of peaks
                rawfracs = resultsPeaks(1:4);
                rawpeaknumber(voxelj,1) = nnz(rawfracs);
                sortedfracs = SortedresultsPeaks(1:3);
                sortedpeaknumber(voxelj,1) = nnz(sortedfracs);

                
            end
        else
    
            ffastvalues_sort(voxelj,1) = NaN;
            fmedvalues_sort(voxelj,1) = NaN;
            fslowvalues_sort(voxelj,1) = NaN;
            Dfastvalues_sort(voxelj,1) = NaN;
            Dmedvalues_sort(voxelj,1) = NaN;
            Dslowvalues_sort(voxelj,1) = NaN;
            rsqvalues(voxelj,1) = NaN;
            rawpeaknumber(voxelj,1) = NaN;
            sortedpeaknumber(voxelj,1) = NaN;
        end
    end

    ffastvalues_sort=ffastvalues_sort(~isnan(ffastvalues_sort));
    fmedvalues_sort=fmedvalues_sort(~isnan(fmedvalues_sort));
    fslowvalues_sort=fslowvalues_sort(~isnan(fslowvalues_sort));
    Dfastvalues_sort=Dfastvalues_sort(~isnan(Dfastvalues_sort));
    Dmedvalues_sort=Dmedvalues_sort(~isnan(Dmedvalues_sort));
    Dslowvalues_sort=Dslowvalues_sort(~isnan(Dslowvalues_sort));

    dataarray_sort={mean(ffastvalues_sort,"omitnan"), median(ffastvalues_sort,"omitnan"), std(ffastvalues_sort,"omitnan"), kurtosis(ffastvalues_sort), skewness(ffastvalues_sort),...
                        mean(fmedvalues_sort,"omitnan"), median(fmedvalues_sort,"omitnan"), std(fmedvalues_sort,"omitnan"), kurtosis(fmedvalues_sort), skewness(fmedvalues_sort),...
                        mean(fslowvalues_sort,"omitnan"), median(fslowvalues_sort,"omitnan"), std(fslowvalues_sort,"omitnan"), kurtosis(fslowvalues_sort), skewness(fslowvalues_sort),...
                        mean(Dfastvalues_sort,"omitnan"), median(Dfastvalues_sort,"omitnan"), std(Dfastvalues_sort,"omitnan"), kurtosis(Dfastvalues_sort), skewness(Dfastvalues_sort),...
                        mean(Dmedvalues_sort,"omitnan"), median(Dmedvalues_sort,"omitnan"), std(Dmedvalues_sort,"omitnan"), kurtosis(Dmedvalues_sort), skewness(Dmedvalues_sort),...
                        mean(Dslowvalues_sort,"omitnan"), median(Dslowvalues_sort,"omitnan"), std(Dslowvalues_sort,"omitnan"), kurtosis(Dslowvalues_sort), skewness(Dslowvalues_sort),...
                        size(ffastvalues_sort,1),size(SignalInput,2),...
                        mean(rsqvalues,"omitnan"), std(rsqvalues,"omitnan")};


    dataarray_peaknumbers = {sum(rawpeaknumber(:) == 0),  sum(rawpeaknumber(:) == 1),  sum(rawpeaknumber(:) == 2),  sum(rawpeaknumber(:) == 3),...
                             sum(sortedpeaknumber(:) == 0),  sum(sortedpeaknumber(:) == 1),  sum(sortedpeaknumber(:) == 2),  sum(sortedpeaknumber(:) == 3),...
                             size(SignalInput,2)};

    %% for normal baseline
    
    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    Identifying_Info = {['PN_' PatientNum], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise_fourpeak_lambdapt1'); %read only identifying info that already exists
    %% Resort voxelwise take 2 is with boundary of 50, Resort voxelwise is with boundary of 10!
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray_sort,dataarray_peaknumbers];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise_fourpeak_lambdapt1')
    end

    %}

    %% for test-retest
    %{
    pathtodata = '/Users/miraliu/Desktop/Data/PN/PartialNephrectomy_TestRetest';
    ExcelFileName=[pathtodata, '/','PN_TestRetesting.xlsx']; % All results will save in excel file

    Identifying_Info = {['PN_' PatientNum], [PatientNum, '_retest'], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:C','Sheet','Voxelwise Sorted Spectral'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray_sort];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise Sorted Spectral')
    end
    %}
    %% for interobserver
    %{
    pathtodata = '/Users/miraliu/Desktop/Data/PN/Arthi test ROIs';
    ExcelFileName=[pathtodata, '/','PN_Arthi_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file
    Identifying_Info = {['PN_' PatientNum], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise Sorted Spectral JONAS'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray_sort];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise Sorted Spectral JONAS')
    end
    %}
end