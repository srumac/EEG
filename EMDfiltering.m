function [EEG] = EMDfiltering(EEG,todropnum)
%%%%%%%%%%% EMDfiltering.m
%   Detailed explanation goes here
%%%%%%%%%%%
%% Resample @20Hz
% EEG = pop_resample(EEG, 20);
%% Initializations
dimentions = size(EEG.laplacian);
if length(dimentions) == 2
    nepochs = dimentions(2);
elseif length(dimentions) == 1
    nepochs = 1;
else
    error('EEG.laplacian does not have 1 or 2 dimentions')
end
% lapl can be [number of samples; number of epochs] 
% or [number of samples x 1]
lapl = double(EEG.laplacian);

emdfilt = zeros(size(EEG.laplacian,1),nepochs);
%% EMD filtering
for i = 1:nepochs
    [imf,res,~] = emd(lapl(:,i),'Interpolation','spline','Display',0); %'spline'
    filt_imf = sgolayfilt(imf,3,15); 
    emdfilt(:,i) = sum(filt_imf,2) + res;
    todrop = sum(filt_imf(:,1:todropnum),2);
    emdfilt(:,i) = emdfilt(:,i) - todrop;
end
EEG.emdchan = emdfilt;
end

