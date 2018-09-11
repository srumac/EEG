emdEEG = EEG;
emdEEG.data = [];
for j = 1:EEG.nbchan
    channel = squeeze(EEG.data(j,:,:));
    newchannel = zeros(size(channel,1),size(channel,2));
    channel = double(channel);
    for i = 1:EEG.trials
        singleepoch = channel(:,i);
        [imf,res,~] = emd(singleepoch,'Interpolation','spline','Display',0); %'spline'
        filt_imf = sgolayfilt(imf,3,15); % 15??????
        newchannel(:,i) = sum(filt_imf,2) + res;
        todrop = filt_imf(:,1) + filt_imf(:,2) + filt_imf(:,3);
        newchannel(:,i) = newchannel(:,i) - todrop;
    end
    emdEEG.data(j,:,:) = smooth(newchannel,16);
end
EEG = emdEEG;
EEG = eeg_checkset(EEG);
eeglab redraw

%% Select C3 channel for averaging
EEG_selchan = pop_select(EEG, 'channel', {'C3'});
c3 = squeeze(EEG_selchan.data);

emdc3template = mean(c3,2);
plot(EEG.times,emdc3template);