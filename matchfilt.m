function [EEG] = matchfilt(EEG,template)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
template = template(end:-1:1);
b = double(template);
filter1 = phased.MatchedFilter('Coefficients',b);
for i = 1:EEG.trials
    x = EEG.emdchan(:,i);
    EEG.matched(:,i) = abs(filter1(x));
    EEG.matched(:,i) = filter(b,1,x);
end

end
