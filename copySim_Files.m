% Just a handy script to copy the simulated MEG files into different
% folders for the source reconstruction

dipoleMom = [20 6];
dipoleMom_1 = dipoleMom(1);
dipoleMom_2 = dipoleMom(2);
SNR = [0, -5, -10, -15, -20];
nmb_patches = 60;
sourceRecon_Alg = {'MNE','EBB','MSP'};

cd('/data/pt_user-helbling_ticket017439/helbling/Simulations_Paper_100_Mid')
origScale = 1:7;
Coreg_err = 2;
setNr = 2;

for a =  1:length(sourceRecon_Alg)
    sourceRecon_Alg_a = sourceRecon_Alg{a};
    parfor s =  1:length(SNR)
        SNR_str_fig = num2str(SNR(s));
        if SNR(s)==0
            SNR_str = num2str(SNR(s));
        else
            SNR_str = ['minus' num2str(abs(SNR(s)))];
        end
        simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_%d',dipoleMom_1,dipoleMom_2,SNR_str,nmb_patches,setNr);
        for f = 1:5
            fname = sprintf('Rep%d_*',f);
            copyfile([simFolderName '/' fname],[simFolderName(1:end) '_' sourceRecon_Alg_a '/'],'f')
        end
        copyfile([simFolderName '/S*'],[simFolderName(1:end) '_' sourceRecon_Alg_a '/'],'f')
        % copyfile([simFolderName '/*S*'],[simFolderName(1:end) '_' sourceRecon_Alg_a '_Coreg' num2str(Coreg_err) '/'],'f')
    end
end
