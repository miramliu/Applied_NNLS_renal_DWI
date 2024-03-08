function PlotSortedPeaks(ii, OutputSpectrum, SortedresultsPeaks)
ADCBasisSteps = 300; %(??)
ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);
semilogx((1./ADCBasis)*1000, OutputSpectrum)
hold on
xline(.8)
xline(5)
xline(50)
title(string(ii))
y = max(OutputSpectrum)/3;
%disp(SortedresultsPeaks)
peakNames = {'blood', 'tubule', 'tissue', 'fibro','blood', 'tubule', 'tissue', 'fibro'};
for j = length(SortedresultsPeaks)/2+1:length(SortedresultsPeaks) 
    peakNumber = j; %get second half of the indices (to get diffusion coefficients)
    if SortedresultsPeaks(peakNumber) > 0 % for diffusion of the nonzero peaks
        %disp(SortedresultsPeaks(peakNumber))
        %disp(peakNames(peakNumber))
        text(SortedresultsPeaks(peakNumber), y, peakNames(peakNumber), 'FontSize',16)
    end
end

pause(0.01)

hold off
end