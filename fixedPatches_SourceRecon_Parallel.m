dipoleMom = [20 6];
SNR = [0, -5, -10, -15, -20];
Ndips = 1;
nmb_patches = 60;
setNr = 2; % setNr 1 are the first 30 locations, set 2 its homologue locations at the opposing hemisphere

sourceRecon_Alg = {'MNE','EBB','MSP'};
sourceRecon_Alg_SPM = {'IID','EBB','GS'};
parentFolder = 'Simulations_Paper_100_Mid';
Coreg_err = 0;
origScale = 1:7;

if exist(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Scaling'], 'file')
    load('Scaling','scale')
else
    scale = [1 4/3 3/4 11/10 10/11 21/20 20/21];
    save('Scaling','scale')
end

rep_idx = 1:5;
source_recon_idx = 3;

for i = 1:length(scale)
    invIdx = i;
    for j = rep_idx
        
        cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Datasets_20_6_SNR0_60_' num2str(setNr)])
        cd(sprintf('simprior_Rep%d_%d_%d_Sim_AB300686_SofieNormative_20151002_02',j,dipoleMom(1), dipoleMom(2)))
        fname = dir('prior*');
        load(fname(1).name)
        x = find(Qp{1,1}.q);
        weighted_x = Qp{1,1}.q(x)/dipoleMom(1);
        cd ..
        load(sprintf('Rep%d_%d_%d_Params.mat',j,dipoleMom(1), dipoleMom(2))')
        
        cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/'])
        
        load('SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1.mat')
        G(:,x) = G(:,x)+G(:,x).*(scale(i)-scale(1)).*repmat(full(weighted_x)',size(G,1),1)*length(x);
        save(sprintf('Adapted_SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1_Rep%d_Sc%d.mat',j,i),'G','label')
    end
end

dipoleMom_1 = dipoleMom(1);
dipoleMom_2 = dipoleMom(2);

for a = source_recon_idx
    sourceRecon_Alg_a = sourceRecon_Alg{a};
    parfor s = 1:length(SNR)
        
        if SNR(s)==0
            SNR_str = num2str(abs(SNR(s)));
        else
            SNR_str = ['minus' num2str(abs(SNR(s)))];
        end
        
        simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_%d_%s',dipoleMom_1,dipoleMom_2,SNR_str,nmb_patches,setNr,sourceRecon_Alg_a);
        copyfile('Adapted_SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1_Rep*',simFolderName(1:end),'f')
    end
end

for i = 1:length(scale)
    invIdx = i;
    for j = rep_idx
        cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder])
        load(['Ip_' num2str(nmb_patches) '_Homologue'],'Ip')
        for a = source_recon_idx
            sourceRecon_Alg_a = sourceRecon_Alg{a};
            sourceRecon_Alg_SPM_a = sourceRecon_Alg_SPM{a};
            parfor s =  1:length(SNR)
                idx = 1;
                if SNR(s)==0
                    SNR_str = num2str(abs(SNR(s)));
                else
                    SNR_str = ['minus' num2str(abs(SNR(s)))];
                end
                
                simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_%d_%s',dipoleMom_1,dipoleMom_2,SNR_str,nmb_patches,setNr,sourceRecon_Alg_a);
                cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/' simFolderName])
                
                D = spm_eeg_load(sprintf('Rep%d_%d_%d_Sim_AB300686_SofieNormative_20151002_02.mat',j,dipoleMom_1, dipoleMom_2));
                D.inv{invIdx} = D.inv{1};
                D.inv{invIdx}.gainmat = sprintf('Adapted_SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1_Rep%d_Sc%d.mat',j,i);
                D.save
                
                jobfile = {['/home/raid2/helbling/Work/Code/Normative_Code_CBS/MEG_Simulations/Adapted_Simulations_SourceRecon_' sourceRecon_Alg_a '_job.m']};
                
                spm('defaults', 'EEG');
                spm_jobman('run', jobfile, {sprintf('Rep%d_%d_%d_Sim_AB300686_SofieNormative_20151002_02.mat',j,dipoleMom_1, dipoleMom_2)},invIdx,{['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/fixedPatches_All.mat']});
               
            end
        end
    end
end