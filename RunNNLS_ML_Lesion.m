% Input: 

%% output data for lesion diffusion spectrum via NNLS

% ML 2023 aug 21

function [OutputDiffusionSpectrum, Chi, Resid, y_recon, resultsPeaks] = RunNNLS_ML_Lesion(PatientNum,ROItype)

    addpath ../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../Applied_NNLS_renal_DWI/rNNLS

    %list_of_b_values = zeros(length(bvalues),max(bvalues));
    %list_of_b_values(h,1:length(b_values)) = b_values; %make matrix of b-values
    b_values = [0,10,30,50,80,120,200,400,800];

    %% Generate NNLS space of values, not entirely sure about this part, check with TG?
    ADCBasisSteps = 300; %(??)
    ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);
    A = exp( -kron(b_values',1./ADCBasis));

    
    %% create empty arrays to fill
    amplitudes = zeros(ADCBasisSteps,1);
    resnorm = zeros(1);
    resid = zeros(length(b_values),1);
    y_recon = zeros(max(b_values),1);
    resultsPeaks = zeros(6,1); %6 was 9 before? unsure why


    SignalInput = ReadPatientDWIData(PatientNum, ROItype);

    %% try to git them with NNLS
    [TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);
    
    amplitudes(:) = TempAmplitudes';
    resnorm(:) = TempResnorm';
    resid(1:length(TempResid)) = TempResid';
    y_recon(1:size(A,1)) = A * TempAmplitudes;

    %% output renaming, just to stay consistent with the TG&JP code
    OutputDiffusionSpectrum = amplitudes;
    Chi = resnorm;
    Resid = resid;

    plot(OutputDiffusionSpectrum)

    [GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,RegionFraction1,RegionFraction2,RegionFraction3 ] = NNLS_result_mod_ML(OutputDiffusionSpectrum, ADCBasis);
    resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
    resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
    resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
    resultsPeaks(4) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
    resultsPeaks(5) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
    resultsPeaks(6) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;


    pathtodata = '/Users/neuroimaging/Desktop/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_Lesion_DiffusionSpectra.xlsx']; % All results will save in excel file

    Identifying_Info = {PatientNum, ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),OutputDiffusionSpectrum};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append')
    end
end


% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData(PatientNum, ROItype)

    pathtodata = '/Users/neuroimaging/Desktop/ML_PartialNephrectomy_Export';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
    
    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
   

    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)=
    ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype ),:); %so should just be lesion
    % also make sure b-values are in order
    totalslices = nnz(~ROITypeTablesub.Dynamic); %the number of zeros (i.e. slices)
    %ROITypeTablesub.Dynamic(1:7:end)
    
    if ROITypeTablesub.Dynamic(1:totalslices:end) == [0;1;2;3;4;5;6;7;8]
        for slice = 1:totalslices
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean(slice:totalslices:end); %avearge over all slices
            %size(SignalInput)
        end
        SignalInput = SignalInput./SignalInput(1); %normalize to b0
        
    else
        ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
        for slice = 1:totalslices
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean(slice:totalslices:end);
            %size(SignalInput)
        end
        SignalInput = SignalInput./SignalInput(1); %normalize to b0
    end
    
end

