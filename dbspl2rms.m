function out_rms= dbspl2rms(in_dBSPL)

pRef= 20e-6;
out_rms= pRef .* 10.^(in_dBSPL/20);