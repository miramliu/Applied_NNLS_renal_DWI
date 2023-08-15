# Applied_NNLS_renal_DWI
Forked from https://github.com/JoaoPeriquito/NNLS_computation_of_renal_DWI 

Continued by ML as of august 9th 2023 to work on applying NNLS to kidney allograft IVIM
Done with the help of Thomas Gladytz

RunNNLS_ML uses the code provided to do NNLS of data collected from partial nephrectomy cases

an example of a run would be 
    >> [OutputDiffusionSpectrum, Chi, Resid,y_recon,Peaks] = RunNNLS_ML('P007','P007_LK_LP_C');