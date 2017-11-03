% calculate forward model 
subj.id          = 'AB300686';
subj.subID       = 'AB300686';
subj.mri         = 'MP00650';
subj.scandate1   = '20151002';
subj.x1          = 2;
inputs              = [];
inputs{1, 1}        = {['/data/pt_user-helbling_ticket017439/helbling/Simulation_Paper_Test/Sim_' subj.id '_SofieNormative_' subj.scandate1 '_0' num2str(subj.x1) '.mat']};
inputs{1, 2}        = {'/data/pt_user-helbling_ticket017439/NormativeMEG/Data/hcT1s/AB300686/s2014-09-09_16-05-160736-00001-00192-1.nii,1'};
inputs{1, 3}        = {['/data/pt_user-helbling_ticket017439/NormativeMEG/Data/Freesurfer6.0.0_Recons/' subj.subID(1:2) '-1mm/surf/new_ds_mid.hc_PDw2.surf.gii']};
inputs{1, 4}        = [-78.4850   43.3607  -31.1240];
inputs{1, 5}        = [-14.0410  126.9697    6.3180];
inputs{1, 6}        = [65.3960   45.2347  -17.4760];
jobfile     = {'/home/raid2/helbling/Work/Code/Normative_Code_CBS/MEG/specifyCustomMesh_job.m'};
spm_jobman('run', jobfile, inputs{:});
