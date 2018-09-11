function [numtrial] = findtrainsize(EEG,numvalid)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%% Initializations
nepochs = size(EEG.emdchan,2);
pos = 1:5:(nepochs);
for ii = 1:length(pos)
    numtemp = pos(ii);
    template = zeros(size(EEG.emdchan,1),numvalid);
    for kk = 1:numvalid
        rndnum = randperm(nepochs);
        ind = rndnum(1:numtemp);
        subset = EEG.emdchan(:,ind);
        template(:,kk) = mean(subset,2);
    end
    %
    D = pdist(template');
    Z = squareform(D);
    f(ii) = sum(Z(1,:));
    fitness(ii) = (f(ii)/f(1))*100;
    % xcorr?
end
% figure(1); plot(pos,fitness,'o')
%% Find first time fitness doesn't change of more than 4%
jj = 1;
for j = 1:length(fitness)-1
    if (fitness(j)-fitness(j+1)) < 0.1
        n(jj) = pos(j);
        jj = jj + 1;
    end
end
numtrial = n(1);
end

