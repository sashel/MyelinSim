% Generate Simulations folder (e.g. mkdir('/data/pt_user-helbling_ticket017439/helbling/Simulations_Paper_100_Mid'))
% and copy Sim_* MEG spm datafiles and the original gainmatrix into the folder before running this script

cd('/data/pt_user-helbling_ticket017439/helbling/Simulations_Paper_100_Mid') 
load('SPMgainmatrix_Sim_AB300686_SofieNormative_20151002_02_1.mat') % contains leadfield matrix G

Ip    = ceil((1:50)*size(G,2)/50);

origData = '/data/pt_user-helbling_ticket017439/helbling/Simulations_Paper_100_Mid/Sim_AB300686_SofieNormative_20151002_02.mat';

D = spm_eeg_load(origData);
dist = zeros(length(Ip),size(G,2));
mnidist = zeros(1,length(Ip));
meshsourceind = zeros(1,length(Ip));

for jj = 1:length(Ip)
    locMNI = D.inv{1}.mesh.tess_mni.vert(Ip(jj),:);
    vdist = D.inv{1}.mesh.tess_mni.vert-repmat([locMNI(1)*-1 locMNI(2:3)],size(D.inv{1}.mesh.tess_mni.vert,1),1);
    dist(jj,:) = sqrt(dot(vdist',vdist'));
    [mnidist(jj),meshsourceind(jj)] = min(dist(jj,:));
end

cd('/data/pt_user-helbling_ticket017439/helbling/Simulations_Paper_100_Mid/')
Ip = [Ip meshsourceind];
save('fixedPatches_All','Ip')
Ip = [Ip(1:30) Ip(51:80)];
save(sprintf('Ip_%d_Homologue',length(Ip)),'Ip')

