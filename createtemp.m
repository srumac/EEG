function [EEG, template] = createtemp(EEG,N)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
nepochs = size(EEG.emdchan,2);
rndnum = randperm(nepochs);
ind = rndnum(1:N);
subset = EEG.emdchan(:,ind);

% Delete used epochs
EEG.emdchan(:,ind) = [];
lrp = mean(subset,2);
% HOW MANY SECONDS
template = lrp(EEG.srate*2:EEG.srate*4);
% figure('Name','Template output');plot(EEG.times,-lrp,'LineWidth',1);title('EMD filtered template'),xlabel('Time')


EEG.trials = EEG.trials - N;
end

