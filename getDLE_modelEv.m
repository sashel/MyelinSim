parentFolder = 'Simulations_Paper_100_Mid';

% % Do only once, when running the script for the first time:
% mkdir('/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Figures/')
% mkdir('/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Results/')

dipoleMom = [20 6];
maxInd = 30;
SNR = [0, -5, -10, -15, -20];
SNR_label = {'0', '-5', '-10', '-15', '-20'};
setNr = 1;

sourceRecon_Alg = 'MSP'; % can be 'MNE' (Minimum Norm Estimate), 'EBB' (Empirical Bayesian Beamformer), 'MSP' (Multiple Sparse Priors)
Ip = 60;
nmb_patches = Ip;
cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder]);
load(['Ip_' num2str(nmb_patches) '_Homologue'],'Ip')

% collect data across SNRs s, repetitions j and scalings ii
for s = 1:length(SNR)
    SNR_str_fig = num2str(SNR(s));
    if SNR(s)==0
        SNR_str = num2str(abs(SNR(s)));
    else
        SNR_str = ['minus' num2str(abs(SNR(s)))];
    end
    
    simFolderName = sprintf('Datasets_%d_%d_SNR%s_%d_%d_%s',dipoleMom(1),dipoleMom(2),SNR_str,nmb_patches,setNr,sourceRecon_Alg);
    cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/' simFolderName]);
    scale = [1 4/3 3/4 11/10 10/11 21/20 20/21];
    
    for j = 1:maxInd
        load(sprintf('Rep%d_%d_%d_Params.mat',j,dipoleMom(1), dipoleMom(2)))
        load(sprintf('Rep%d_%d_%d_Sim_AB300686_SofieNormative_20151002_02.mat',j,dipoleMom(1), dipoleMom(2)))
        for  ii = 1:7
            maxId(s,j,ii) = find(abs(D.other.inv{ii}.inverse.J{1})==max(abs(D.other.inv{ii}.inverse.J{1})));
            origId(s,j,ii) = vertIdx;
            DLE(s,j,ii) = norm(D.other.inv{ii}.forward.mesh.vert(maxId(s,j,ii),:)-D.other.inv{ii}.forward.mesh.vert(origId(s,j,ii),:));
            R2(s,j,ii) = D.other.inv{ii}.inverse.R2;
            VE(s,j,ii) = D.other.inv{ii}.inverse.VE;
            F(s,j,ii) = D.other.inv{ii}.inverse.F;
        end
    end
end

cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Results'])
save(['DLE_modelEv_' sourceRecon_Alg num2str(setNr)],'maxInd','origId','DLE','R2','VE','F')
save(['DLE_modelEv_' sourceRecon_Alg '_All_' num2str(setNr)])

cd(['/data/pt_user-helbling_ticket017439/helbling/' parentFolder '/Figures/'])
figure, b = bar(squeeze(mean(mean(DLE(:,:,:),3),2))*1000); % SNR
title(sourceRecon_Alg,'FontSize',16,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
set(gca,'XTickLabel',SNR_label)
xlabel('SNR in dB')
ylabel('DLE in mm')
% ylim([0 18])
set(b,'facecolor',[42 41 112]./255,'FaceAlpha',0.6,'linewidth',1)
hold on
errorbar(1:s,squeeze(mean(mean(DLE(:,:,:),3),2))*1000,std(mean(DLE(:,:,:),3)')*1000./sqrt(size(DLE,2)),'color', [0 0 0],'LineStyle', 'none')
set(gcf,'color','w')
print('-depsc2', '-tiff', sprintf('DLE_acrossSNRs_Barplot_100_%s_%d', sourceRecon_Alg, setNr))

figure, b = bar(squeeze(mean(mean(DLE(:,:,:),2),1))*1000); % SNR
title(sprintf('DLEs across scalings: %s at random locations', sourceRecon_Alg),'FontSize',11,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
set(gca,'XTickLabel',{'100','133','75','110','91','105','95'})
xlabel('Scaling in %')
ylabel('DLE in mm')
% ylim([0 16])
set(b,'facecolor',[42 41 112]./255,'FaceAlpha',0.6,'linewidth',1)
set(gcf,'color','w')
print('-depsc2', '-tiff', sprintf('DLE_acrossScalings_Barplot_100_%s_%d', sourceRecon_Alg, setNr))


figure, b = bar((squeeze(mean(mean(DLE(:,:,2:end),2),1))-squeeze(mean(mean(DLE(:,:,1),2),1)))*1000); % SNR;
title(sourceRecon_Alg,'FontSize',16,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
set(gca,'XTickLabel',{'133','75','110','91','105','95'})
xlabel('Scaling in %')
ylabel('DLE in mm')
% ylim([-6 6])
hold on
errorbar(1:length(scale)-1,squeeze(mean(mean(DLE(:,:,2:end),2),1))*1000-squeeze(mean(mean(DLE(:,:,1),2),1))*1000,...
    std((squeeze(mean(DLE(:,:,2:end),1)))*1000-squeeze(mean(mean(DLE(:,:,1),2),1)))./sqrt(size(DLE,2)),'color', [0 0 0],'LineStyle', 'none')

set(b,'facecolor',[42 41 112]./255,'FaceAlpha',0.6,'linewidth',1)
set(gcf,'color','w')
print('-depsc2', '-tiff', sprintf('DLE_acrossScalings_Barplot_100_%s_Rel_%d', sourceRecon_Alg, setNr))


figure, b3 = bar3(squeeze(mean(DLE(:,:,:),2))*1000);
set(gca,'XTickLabel',{'100','133','75','110','91','105','95'})
set(gca,'YTickLabel',SNR_label)
for k = 1:length(b3)
    b3(k).FaceAlpha = 0.6;
end
set(gcf,'color','w')
xlabel('Scaling in %')
ylabel('SNR in dB')
set(gca,'YDir', 'normal')
zlabel('DLE in mm')
% zlim([0 16])
title(sprintf('Dipole localisation errors: %s at random locations', sourceRecon_Alg),'FontSize',11,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
print('-depsc2', '-tiff', sprintf('DLE_Barplot_100_%s_Homo_%d', sourceRecon_Alg, setNr))

figure, b3 = bar3((squeeze(mean(DLE(:,:,2:7),2))-squeeze(mean(DLE(:,:,1),2)))*1000);
set(gca,'XTickLabel',{'133','75','110','91','105','95'})
set(gca,'YTickLabel',SNR_label)
for k = 1:length(b3)
    b3(k).FaceAlpha = 0.6;
end
set(gcf,'color','w')
xlabel('Scaling in %')
ylabel('SNR in dB')
set(gca,'YDir', 'normal')
zlabel('DLE in mm')
% zlim([-8 8])
title(sourceRecon_Alg,'FontSize',16,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
print('-depsc2', '-tiff', sprintf('DLE_Barplot_100_%s_against100_%d', sourceRecon_Alg, setNr))


SNR_Scale_F = squeeze(mean(F(1:s,:,:),2))';

figure, b3 = bar3([-1*[abs(SNR_Scale_F(2,:)); abs(SNR_Scale_F(3,:)); abs(SNR_Scale_F(4,:)); abs(SNR_Scale_F(5,:));...
    abs(SNR_Scale_F(6,:)); abs(SNR_Scale_F(7,:))]+abs(SNR_Scale_F(1,:))]');
set(gca,'XTickLabel',{'133','75','110','91','105','95'})
set(gca,'YTickLabel',SNR_label(1:end))
for k = 1:length(b3)
    b3(k).FaceAlpha = 0.6;
end

% zlim([-16,16])
set(gcf,'color','w')
xlabel('Scaling in %')
ylabel('SNR in dB')
zlabel('\Delta F')
title(sourceRecon_Alg,'FontSize',16,'FontName','Helvetica','FontWeight', 'bold','FontAngle','italic','Interpreter','none')
print('-depsc2', '-tiff', sprintf('Fvalues_Barplot_100_%s_%d', sourceRecon_Alg, setNr))


