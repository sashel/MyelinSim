dipoleMom = [20 6];
SNR = [0, -5, -10, -15, -20];
nmb_patches = 60;
setNr = 2;
parentFolder = 'Simulations_Paper_100_Mid';
cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder ''])
load(['Ip_' num2str(nmb_patches) '_Homologue'],'Ip')

for s = 1:length(SNR)
    if SNR(s)==0
        SNR_str = num2str(abs(SNR(s)));
    else
        SNR_str = ['minus' num2str(abs(SNR(s)))];
    end

    if setNr == 1
        Ip_Idx = 1:30;
    elseif setNr == 2
        Ip_Idx = (1:30) + 30;
    end
    
    for i = 1:length(Ip_Idx)
        if setNr == 1
            simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_1',dipoleMom(1),dipoleMom(2),SNR_str,nmb_patches);
        elseif setNr == 2
            simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_2',dipoleMom(1),dipoleMom(2),SNR_str,nmb_patches);
        end
        
        cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder ''])
        mkdir(simFolderName)
        copyfile('Sim_AB300686*',simFolderName)
        copyfile('SPMgain*',simFolderName)
        origData = ['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/' simFolderName '/Sim_AB300686_SofieNormative_20151002_02.mat'];
        D = spm_eeg_load(origData);
        D.inv{1}.gainmat = 'SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1.mat';
        D.save
        Ns = size(D.inv{1}.forward.mesh.vert,1);
        
        Ip_i = Ip(Ip_Idx(i)); % Ip    = ceil((1:Np)*Ns/Np); % from spm_eeg_invert l 605
        vertIdx = Ip_i;
        locMNI = D.inv{1}.mesh.tess_mni.vert(vertIdx,:);
        cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/' simFolderName])
        jobfile = {'/home/raid2/helbling/Work/Code/Normative_Code_CBS/MEG_Simulations/Simulation_Batch_singleDipole_job.m'};
      
        spm('defaults', 'EEG');
        spm_jobman('run', jobfile, {origData}, sprintf('Rep%d_%d_%d_',i, dipoleMom(1), dipoleMom(2)), dipoleMom, locMNI, SNR(s));
        save(sprintf('Rep%d_%d_%d_Params',i, dipoleMom(1), dipoleMom(2)),'dipoleMom', 'locMNI', 'SNR', 'vertIdx')
    end
end
