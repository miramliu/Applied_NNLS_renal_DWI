%% saving and running on signal input
function RunAndSave_voxelwise(PatientNum, ROItype,SignalInput)

    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    %% trying tri-exponential!
    
    fslowvalues = zeros(size(SignalInput,2),1);
    fmedvalues = zeros(size(SignalInput,2),1);
    ffastvalues = zeros(size(SignalInput,2),1);
    Dslowvalues = zeros(size(SignalInput,2),1);
    Dmedvalues = zeros(size(SignalInput,2),1);
    Dfastvalues = zeros(size(SignalInput,2),1);
    %bvalues = [0,10,30,50,80,120,200,400,800];
    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(currcurve);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(currcurve);
        [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve); %best results so far regarding Mann-Whitney U & AUC
    
        if rsq>0.7
            fslowvalues(voxelj,1) = resultsPeaks(1);
            fmedvalues(voxelj,1) = resultsPeaks(2);
            ffastvalues(voxelj,1) = resultsPeaks(3);
            Dslowvalues(voxelj,1) = resultsPeaks(4);
            Dmedvalues(voxelj,1) = resultsPeaks(5);
            Dfastvalues(voxelj,1) = resultsPeaks(6);
        else
            fslowvalues(voxelj,1) = NaN;
            fmedvalues(voxelj,1) = NaN;
            ffastvalues(voxelj,1) = NaN;
            Dslowvalues(voxelj,1) = NaN;
            Dmedvalues(voxelj,1) = NaN;
            Dfastvalues(voxelj,1) = NaN;
        end
    end

    %remove NaN before doing stats
    fslowvalues=fslowvalues(~isnan(fslowvalues));
    fmedvalues=fmedvalues(~isnan(fmedvalues));
    ffastvalues=ffastvalues(~isnan(ffastvalues));
    Dslowvalues=Dslowvalues(~isnan(Dslowvalues));
    Dmedvalues=Dmedvalues(~isnan(Dmedvalues));
    Dfastvalues=Dfastvalues(~isnan(Dfastvalues));

    dataarray={mean(fslowvalues), median(fslowvalues), std(fslowvalues), kurtosis(fslowvalues), skewness(fslowvalues),...
                        mean(fmedvalues), median(fmedvalues), std(fmedvalues), kurtosis(fmedvalues), skewness(fmedvalues),...
                        mean(ffastvalues), median(ffastvalues), std(ffastvalues), kurtosis(ffastvalues), skewness(ffastvalues),...
                        mean(Dslowvalues), median(Dslowvalues), std(Dslowvalues), kurtosis(Dslowvalues), skewness(Dslowvalues),...
                        mean(Dmedvalues), median(Dmedvalues), std(Dmedvalues), kurtosis(Dmedvalues), skewness(Dmedvalues),...
                        mean(Dfastvalues), median(Dfastvalues), std(Dfastvalues), kurtosis(Dfastvalues), skewness(Dfastvalues),...
                        size(fslowvalues,1),size(SignalInput,2)};
                

            %% trying tri-exponential!
        %addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
        %bvals = [10,30,50,80,120,200,400,800];
        %[resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(SignalInput,bvals);
    
        %plot(OutputDiffusionSpectrum);
        %pause(1)

    

    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

   %{
    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Rigid_Triexp'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'Sheet','Rigid_Triexp','WriteMode','append')
    end

    

    disp('saving test-retest')
    pathtodata = '/Users/miraliu/Desktop/Data/PartialNephrectomy_TestRetest/';
    ExcelFileName=[pathtodata, '/','PN_TestRetesting.xlsx']; % All results will save in excel file
    %}

    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise')
    end

end