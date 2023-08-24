%% bulky code to recomparmentalize multi-exponential
% the original sheet is just the standard output
% will then sort into the 3 components based on limits/compartmentalization
% based on the diffusion coefficient

function RecompartmentalizeExcel()
    pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    Table = readcell(ExcelFileName, 'Sheet','Original');

    for j = 1:size(Table,1)
        Identifying_Info = {j,1:2};

        resultsPeaks = Identifying_Info = {j,3:8};
        if nnz(~resultsPeaks) > 0 
            dummyresultspeaks = resultsPeaks;
            idx = find(resultsPeaks);
            correctthese = idx(idx>3); %get the diffusion coefficients that are not zero
            for k =1:numel(correctthese) %for the diffusion coefficients that need to be shuffed appropriately
                j = correctthese(k);
                n = DetermineComponent(resultsPeaks(j)); %see the speed of this peak
                if n ~= j-3 %if it needs to be moved to a different speed fraction
                    %move to the correct fraction
                    dummyresultspeaks(n) = resultsPeaks(j-3);
                    dummyresultspeaks(n+3) = resultsPeaks(j);
                    %make the one it was moved from zero now
                    if dummyresultspeaks(j-3) == resultsPeaks(j-3) %if it has NOT been replaced by a prevoius move 
                        dummyresultspeaks(j-3) = 0; %set to zero
                        dummyresultspeaks(j) = 0;
                    end
                    
                end
                %pause()
            end
            resultsPeaks = dummyresultspeaks;
        end
    end
    end


end