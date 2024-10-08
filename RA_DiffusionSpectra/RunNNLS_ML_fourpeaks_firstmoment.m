%give signal input, will fit and output the peaks
% can also give pt number and ROI type

% now does it with up to four peaks! (rather than the assumed max of 3)
function [OutputDiffusionSpectrum, rsq, Resid, y_recon, resultsPeaks, firstmoments] = RunNNLS_ML_fourpeaks_firstmoment(varargin)

    %addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    %addpath ../../Applied_NNLS_renal_DWI/rNNLS
%    disp(PatientNum)

    b_values = [0,10,30,50,80,120,200,400,800]; %if original 9 

    if nargin == 2
        if ischar(varargin{2})
            PatientNum = varargin{1};
            ROItype = varargin{2};
            ROItype = [PatientNum '_' ROItype];
            %% CHANGE HERE FOR BASELINE, 3M0 OR 12MO
            SignalInput = ReadPatientDWIData(PatientNum, ROItype);
            %SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype);
        
            %to match bi-exp, normalizing to b0
            SignalInput = varargin{1};
            SignalInput = SignalInput(:)/SignalInput(1);
        else
            SignalInput = varargin{1};
            b_values = varargin{2};
            SignalInput = SignalInput(:)/SignalInput(1);
        end

        % assume lambda = 8
        lambda = 1;
    elseif nargin == 3 %have lambda as an input as well
        if ischar(varargin{2})
            PatientNum = varargin{1};
            ROItype = varargin{2};
            ROItype = [PatientNum '_' ROItype];
            %% CHANGE HERE FOR BASELINE, 3M0 OR 12MO
            SignalInput = ReadPatientDWIData(PatientNum, ROItype);
            %SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype);
        
            %to match bi-exp, normalizing to b0
            SignalInput = varargin{1};
            SignalInput = SignalInput(:)/SignalInput(1);

            lambda = varargin{3};
        else
            SignalInput = varargin{1};
            b_values = varargin{2};
            SignalInput = SignalInput(:)/SignalInput(1);
            lambda = varargin{3};
        end
    else
        SignalInput = varargin{1};
        lambda = 8;
    end

    %list_of_b_values = zeros(length(bvalues),max(bvalues));
    %list_of_b_values(h,1:length(b_values)) = b_values; %make matrix of b-values

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

    
    %% try to fit them with NNLS
    %[TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);

    %% try to fit them with simple NNLS with assumed regularization factor of lanbda = #b/SNR 
    %lambda = 8;
    %[TempAmplitudes, TempResnorm, TempResid ] = simpleCVNNLS(A, SignalInput, lambda);

    %% with L2 norm
    %[TempAmplitudes, TempResnorm, TempResid ] = NNLS_L2andCurvReg(A, SignalInput, lambda);

    %% with forced regularization of curve
    lambda = 0.1;
    [TempAmplitudes, TempResnorm, TempResid ] = simpleCVNNLS_curveregularized(A, SignalInput, lambda);
    
    
    amplitudes(:) = TempAmplitudes';
    resnorm(:) = TempResnorm';
    resid(1:length(TempResid)) = TempResid';
    y_recon(1:size(A,1)) = A * TempAmplitudes;

    % to match r^2 from bi-exp, check w/ octavia about meaning of this 
    SSResid = sum(resid.^2);
    SStotal = (length(b_values)-1) * var(SignalInput);
    rsq = 1 - SSResid/SStotal; 

    


    %% output renaming, just to stay consistent with the TG&JP code
    OutputDiffusionSpectrum = amplitudes;
    %plot(OutputDiffusionSpectrum);
    %pause(1)
    Chi = resnorm;
    Resid = resid;

    %attempt with TG version? prior to TG meeting Sept 14th. 
    % assumed ADC thresh from 2_Simulation...
    ADCThresh = 1./sqrt([0.180*0.0058 0.0058*0.0015]);
    %[GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,RegionFraction1,RegionFraction2,RegionFraction3 ] = NNLS_resultTG(OutputDiffusionSpectrum, ADCBasis, ADCThresh);

    [GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,GeoMeanRegionADC_4,RegionFraction1,RegionFraction2,RegionFraction3,RegionFraction4, firstmoments] = NNLS_result_mod_ML_fourpeaks_firstmoment(OutputDiffusionSpectrum, ADCBasis);
    resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
    resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
    resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
    resultsPeaks(4) = RegionFraction4; %(frac_fibro - )./frac_slow.*100;
    resultsPeaks(5) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
    resultsPeaks(6) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
    resultsPeaks(7) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;
    resultsPeaks(8) = GeoMeanRegionADC_4; %(diff_fibro - GeoMeanRegionADC_3./1000)./diff_slow.*100;

end

%{
% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData(PatientNum, ROItype)


%% original
%{
    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export/';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
%}

%% ICC with Swathi ROIs
%{
    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export/';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
%}

    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');    
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
    for k = 1:4 %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
        ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype + string(k)),:); %so for example you want LK_LP_C, will check LK_LP_C1, LK_LP_C2 etc.
        
        % also make sure b-values are in order
        if ROITypeTablesub.Dynamic == [0;1;2;3;4;5;6;7;8]
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
            %size(SignalInput)
        else
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
        end
    end
    SignalInput = SignalInput./SignalInput(1); %normalize to b0

end

% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype)

    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export_3mo';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan2.csv'];
    
    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');    
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
    for k = 1:4 %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
        ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype + string(k)),:); %so for example you want LK_LP_C, will check LK_LP_C1, LK_LP_C2 etc.
        
        % also make sure b-values are in order
        if ROITypeTablesub.Dynamic == [0;1;2;3;4;5;6;7;8]
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
            %size(SignalInput)
        else
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
        end
    end
    SignalInput = SignalInput./SignalInput(1); %normalize to b0

end
%}