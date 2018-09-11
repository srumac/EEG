% % % % laplRP.m % % % %
% Main script to compute and plot the averaged RP, w/ and w/o EMD
% % % % % % % % % % % % 

%% Compute the Laplacian LRP (default Fc3)
answer = inputdlg({'Enter 1 if EMD:','Select Channel'},'Dataset parameter',1,{'1','Fc3'});
emdflag = str2double(answer(1,:));
selchan_name = char(answer(2,:));

%% Select the channel; average over all epochs
EEG_selchan = pop_select(EEG, 'channel', {selchan_name});
chan = squeeze(EEG_selchan.data);
% simple control
nos = [];
stdmean = mean(std(chan,0,2));
for kkk = 1:size(chan,2)
    stdtemp = std(chan(:,kkk));
    if stdtemp > 2*stdmean
        nos = [nos kkk];
    end
end
chan(:,nos) = [];

% compute the averaged signal
lrp_avg = mean(chan,2);

%% Spatial filter
EEG = spatialfilter(EEG);

%% EMD
% eliminate 1 mode
EEG = EMDfiltering(EEG,1);
lrp_emd1 = mean(squeeze(EEG.emdchan),2);

% eliminate 2 modes
EEG = EMDfiltering(EEG,2);
lrp_emd2 = mean(squeeze(EEG.emdchan),2);

% eliminate 3 modes
EEG = EMDfiltering(EEG,3);
lrp_emd3 = mean(squeeze(EEG.emdchan),2);

% eliminate 4 modes
EEG = EMDfiltering(EEG,4);
lrp_emd4 = mean(squeeze(EEG.emdchan),2);

%% Plot a comparison
figure('Name','Readiness Potential');title('Readiness Potential');
subplot(511);plot(EEG.times,-lrp_avg,'LineWidth',.8);title('Averaging');ylabel('microV')
subplot(512);plot(EEG.times,-lrp_emd1,'LineWidth',.8);title('EMD -1');ylabel('microV')
subplot(513);plot(EEG.times,-lrp_emd2,'LineWidth',.8); title('EMD -2');ylabel('microV')
subplot(514);plot(EEG.times,-lrp_emd3,'LineWidth',.8); title('EMD -3');ylabel('microV')
subplot(515);plot(EEG.times,-lrp_emd4,'LineWidth',.8); title('EMD -4');ylabel('microV')
hold off

% Plot 2
figure('Name','Readiness Potential 2');
plot(EEG.times,-lrp_emd3,'LineWidth',.8);hold on;title('Readiness Potential');
plot(EEG.times,-lrp_emd2,'LineWidth',.8);hold on;
plot(EEG.times,-lrp_emd1,'LineWidth',.8);
legend('EMD -3','EMD -2','EMD -1');ylabel('microV')

%Plot 3
hold off
figure('Name','EMD -3 Readiness Potential');
plot(EEG.times,-lrp_emd3,'LineWidth',.8);title('Readiness Potential EMD-3');
ylabel('microV');xlabel('')


% xpoints = 0:1:length(FC3tutti)-1;
% xseconds = (xpoints/EEG.srate)-4;
% h1 = plot(xseconds,-FC3tot,'b');   
% hold on;
% h2 = plot(xseconds,-LRPwoody,'r');
% set(h1,'LineWidth',2);
% set(h2,'LineWidth',2);
% set(gca,'FontSize',16);
% legend('Mean','Woody');
% plot(xseconds,-epochssaved(:,1),'k');
