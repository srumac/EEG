function [output] = morletCWT(EEG,channel,flow,fhigh)
% % % % morletCWT.m % % % %
% INPUTS:   - EEG epoched structure
%           - channel name string: es. 'C3'
%           - flow,fhigh: band limits frequencies
% % % % % % % % % % % % % % 
%% Extract the selected channel and prepare for filtering
EEGin = pop_select(EEG, 'channel', channel);
X = squeeze(EEGin.data);

% save the number of epochs and samples to initialize matrices
nepochs = size(X,2);
nsamples = size(X,1);

% Convert to double, subtract mean
X = double(X);
X = X - mean(X,2);

%% Morlet CWT
M = zeros(nsamples,nepochs);
for i = 1:nepochs
    % select each epoch
    one_epoch = X(:,i);

    % perform the Continuous Wavelet Transform, with Morlet function
    [wt,f] = cwt(one_epoch,'amor',EEG.srate);

    % extract the wanted frequency reange 
    bandlim = f > flow & f < fhigh;

    % convert to power samples
    band = abs(wt(bandlim,:)).^2;
    
    % save power mean per each epoch
    M(:,i) = mean(band,1);
end
%% Compute ERD/ERS
% mean over all epochs
y = mean(M,2); 
y = smooth(y,128);

% reference interval: from 0.5s to 2s
delta = EEGin.srate*1.5:EEGin.srate*2.5;

% compute the average power on the reference interval
R = mean(y(delta));

% compute erd
output = (y - R)/R;
end

