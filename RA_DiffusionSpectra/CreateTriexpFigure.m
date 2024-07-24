%% to create image of kidney!

function parameter_map = CreateTriexpFigure(b_values, ImageStack)


    [N_Bvalues, nx, ny] = size(ImageStack);
    parameter_map = zeros(nx,ny,6);
    for i=1:nx
        for j=1:ny
            if (ImageStack(1,i,j) > 100 ) 

                % for normal b values
                SignalInput = squeeze(double(ImageStack(1:N_Bvalues,i,j)/ImageStack(1,i,j))); 
                %disp([j k]);\
                [SortedresultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(currcurve,b_values);
                if rsq> 0.7
                    parameter_map(j, k,1) = SortedresultsPeaks(1); % f vasc
                    parameter_map(j, k,2) = SortedresultsPeaks(2); % f tubule
                    parameter_map(j, k,3) = SortedresultsPeaks(3); % f tissue
                    parameter_map(j, k,4) = SortedresultsPeaks(4); % D vasc
                    parameter_map(j, k,5) = SortedresultsPeaks(5); % D tubule
                    parameter_map(j, k,6) = SortedresultsPeaks(6); % D tissue
                    parameter_map(j, k,7) = rsq; % rsq
                else
                    parameter_map(j,k,1) = 0;
                    parameter_map(j,k,2) = 0;
                    parameter_map(j,k,3) = 0;
                    parameter_map(j,k,4) = 0;
                    parameter_map(j,k,5) = 0;
                    parameter_map(j,k,6) = 0;
                    parameter_map(j,k,7) = rsq;
                end
            end
        end
    end

end

