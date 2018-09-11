function [erd] = findERD(EEG,channel, flow, fhigh)
% % % % findERD.m % % % %
% INPUTS:   - EEG epoched structure
%           - channel name string: es. 'C3'
%           - flow,fhigh: band limits frequencies
% % % % % % % % % % % % % 
%% Extract the selected channel and prepare for filtering
EEGin = pop_select(EEG, 'channel', channel);

%% Convert to double and subtract mean
X = double(squeeze(EEGin.data));
X = X - mean(X,2);

EEGin.data = X;
%% Band pass filter
cutoff = [flow-0.1 fhigh+0.1]; tbw = .1;
m = pop_firwsord('blackman', EEG.srate, tbw);
b = firws(m, cutoff / (EEGin.srate / 2), windows('blackman', m + 1)); 

% Filter the EEG and compensate for linear delay
EEGin = firfilt(EEGin,b,EEGin.srate*10);

%% Compute ERD/ERS
% square the signal to obtain instant power samples
X = squeeze(EEGin.data);
X = X.^2;
%% Compute the mean and smooth to eliminate variability
y = mean(X,2);
y = smooth(y,128);
% reference interval: from 0.5s to 2s
delta = EEGin.srate*1.5:EEGin.srate*2.5;
% compute the average power on the reference interval
R = mean(y(delta));

% compute erd
erd = (y - R)/R;
end 

