
params = struct();

params.SimOpt.saveSim         = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
params.SimOpt.takingSnapshots = true;
params.SimOpt.T = 0.1;

params.Stim.Amplitude = 10;

params.Conn.filename = '2019-07-08-130322_asn_nw_00488_nj_01898_seed_002_avl_100.00_disp_10.00_gns_05.00_cdisp_300.00.mat';

a = multiRun(params);



%{
params.SimOpt.saveFolder = 'out';
params.importAll = true;
s = multiImport(params);
%}
