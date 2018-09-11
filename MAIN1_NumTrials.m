%% Load Data
% filepath = 'C:\Users\Utente\Desktop\EEGLAB_LRPLAB_recent\plugins\lrplab1.0';
clear variables; close all;
eeglab
filepath = 'C:\Users\Utente\Desktop\RISULTATI';
filename = 'oldprotocolmerged.set';
EEG = pop_loadset( filename, filepath);

%% compute spatial filter and emd channels
EEG = spatialfilter(EEG);
EEG = EMDfiltering(EEG,3);

%% Find Optimal Training size
% for i = 1:30
%     N(i) = findtrainsize(EEG,20); %(26)
% end
% trainsize = max(N); % with difference <4% --> 31 samples needed w/IMFs (1 case), 26 w/ laplacian
% histogram(N); %the most common value in N is 16

%% Create the template and delete unused epochs

[EEGnew, template] = createtemp(EEG, 65);

%% Create positive and negative training set
filtEEG = matchfilt(EEGnew, template);
figure('Name','Mathced filter output');plot(EEG.times,mean(filtEEG.matched,2),'LineWidth',1);title('Matched Filter Averaged Output'),xlabel('Time')

[Mdl,features, class] = findfeatures(filtEEG,100);
% [posEEG,negEEG] = findwindows(filtEEG,30);

%% Matched Filter
% [features, class, thresh] = extractfeat(posEEG,negEEG, template);
% T = findthreshold(features, class);


%% Use the classifier
% filepath = 'C:\Users\Utente\Desktop\Epoched\Labate Alessandra\';
% filename = 'alessandralabate_epoched_128.set';
% EEG = pop_loadset( filename, filepath);
% 
% EEG = myfilt1(EEG);
% % resample
% EEG = pop_resample(EEG,20);

% EEG = spatialfilter(EEG,1);
% EEG_selchan = pop_select(EEG, 'channel', {'C3'});
% EEG.data = squeeze(EEG_selchan.data);
% EEG.data = double(EEG.data);
% times = findLRP_matched(EEG, template,T);
%%
% rndnum = randperm(size(features,2));
% ind = rndnum(1:300);
% trainf = features(:,ind);
% traincl = class(ind);
% features(:,ind) = [];
% class(ind) = [];
%% LDA
% Mdl = fitclinear(trainf',traincl');
% 'DiscrimType', 'Linear'
%'OptimizeHyperparameters','auto'
FN = 0; VP = 0; FP = 0; VN = 0;
for i = 1:size(features,1)
    meanclass2(i) = predict(Mdl,features(i,:));
    if (meanclass2(i) == 1) && (class(i) == 1)
        VP = VP + 1;
    end
    if (meanclass2(i) == 1) && (class(i) == 0)
        FP = FP + 1;
    end
    if (meanclass2(i) == 0) && (class(i) == 0)
        VN = VN + 1;
    end
    if (meanclass2(i) == 0) && (class(i) == 1)
        FN = FN + 1;
    end
end
[c,cm,ind,per] = confusion(class,meanclass2');
plotconfusion(categorical(class),categorical(meanclass2)')
sens = VP/(VP+FN)
spec = VN/(VN+FP)
%% Random epoch
jj = 1;p=1;
clear y
epochfeatures = filtEEG.matched(:,104)';
epochEMD = filtEEG.emdchan(:,104);
for j = 1:16:length(epochfeatures)-4*64
    feat = epochfeatures(j:64:j+4*64);
    y(jj) = predict(Mdl,feat);
    if y(jj)==1
        time1(p) = j+2*64;
        time2(p) = j+4*64;
        p = p + 1;
    end
    jj = jj+1;
end
pp=1;
for k = 1:length(y)-2
    if y(k)==1 && y(k+1)==1 && y(k+2)==1 
        time3(pp) = k*16+3*64;
        pp = pp + 1;
    end
end
figure('Name','epoca');
plot(EEG.times,-epochEMD,'LineWidth',.7);title('Random epoch single-trial');xlabel('Time');ylabel('microV'); hold on
% plot(EEG.times(time1),epochEMD(time1)','o','LineWidth',.5);hold on
% plot(EEG.times(time2),epochEMD(time2)','x','LineWidth',.5);hold on
plot(EEG.times(time3),-epochEMD(time3)','d','Linewidth',3);
legend('Single-trial','3 consecutive RPs');

