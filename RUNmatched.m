%% Input = EMD filtered dataset
% EEG = pop_resample(EEG,20);
% EEG = pop_rmbase(EEG,[]);
emdEEG = EEG;
emdEEG.data = [];
newchannels = zeros(size(EEG.data,1),size(EEG.data,2));

for j = 1:EEG.nbchan
    channel = double(EEG.data(j,:));
    [imf,res,~] = emd(channel,'Interpolation','spline','Display',0); %'spline'
    filt_imf = sgolayfilt(imf,3,15); % 15??????
    newchannels(j,:) = sum(filt_imf,2) + res;
    todrop = filt_imf(:,1) + filt_imf(:,2) + filt_imf(:,3);
    newchannels(j,:) = newchannels(j,:) - todrop';
end

emdEEG.data = newchannels;
% EEG = emdEEG;
% eeglab redraw

EEG_selchan = pop_select(emdEEG, 'channel', {'C3'});
EEG_selchan.data = squeeze(EEG_selchan.data); %1 x n_samples

load('template.mat')

%% MATLAB matched
% wav = getMatchedFilter(template);

%%
template = template(end:-1:1);
template = double(template);
filter1 = phased.MatchedFilter('Coefficients',template);
y = filter1(double(EEG_selchan.data));
result = filter(template,1,EEG_selchan.data);
% % % 
% EEGtemp = pop_select(EEG,'channel',{'C3'});
% EEGtemp.data = squeeze(EEGtemp.data);
% halfdata = EEGtemp.data(128*3:128*4,:);
% template = mean(halfdata,2);
% template = smooth(template,16);
% save('template','template')

EEG.data = [];
EEG.data = abs(y);
EEG = pop_epoch( EEG, {}, [-7 7]);
% EEG = pop_rmbase(EEG,[]);
eeglab redraw

