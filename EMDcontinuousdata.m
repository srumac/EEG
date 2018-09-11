%% Input = EMD filtered dataset
% EEG = pop_resample(EEG,20);
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
    newchannels(j,:) = smooth(newchannels(j,:),16);
end

emdEEG.data = newchannels;
EEG = emdEEG;
eeglab redraw
