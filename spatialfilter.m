function [EEG] = spatialfilter(EEG)
% % % % spatialfilter.m % % % %
% INPUTS:  - EEG eeglab structure: it works both with epoched signals and
%            continuous data       
% OUTPUTS: - EEG structure with the laplacian surrogate channels saved as
%            "EEG.laplacian" attribute
% % % % % % % % % % % % % % % % 

%% Initializations
coeff = (-1)/(4-1);
dimentions = size(EEG.data);
% dimentions = [number of channels; number of samples (per epoch); number of epochs]
if length(dimentions) == 3
    nepochs = dimentions(3);
elseif length(dimentions) == 2
    nepochs = 1;
else
    error('EEG.data problem.')
end
% initialize the laplacian surrogate channel
lapl = zeros(dimentions(2),nepochs);

%% Select the correct channels to compute the laplacian
% Verify the number of channel (old = 7, new = 34)
if dimentions(1) == 7
    EEGcentral = pop_select(EEG, 'channel', {'Cz'});
    EEGin = pop_select(EEG, 'channel', {'Pz','C4','Fcz','C3'});
    centralchan = squeeze(EEGcentral.data);
else
    EEGcentral = pop_select(EEG, 'channel', {'Fc3'});
    EEGin = pop_select(EEG, 'channel', {'Fc5','Fc1','C3','F3'});
    centralchan = squeeze(EEGcentral.data);
end

% Select the other channels
ch1 = squeeze(EEGin.data(1,:,:));
ch2 = squeeze(EEGin.data(2,:,:));
ch3 = squeeze(EEGin.data(3,:,:)); 
ch4 = squeeze(EEGin.data(4,:,:));
% if the data is not epoched
if nepochs == 1
    ch1 = ch1'; ch2 = ch2'; ch3 = ch3'; ch4 = ch4';
end
%% Laplacian Filter
for i = 1:nepochs
    lapl(:,i) = centralchan(:,i) - coeff*(ch1(:,i) + ch2(:,i) + ch3(:,i) + ch4(:,i));
end
% Save the laplacian surrogate channel as "EEG.laplacian" attribute
EEG.laplacian = lapl;
EEG = eeg_checkset( EEG );
end

