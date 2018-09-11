function [emgonset] = onEMGultimate(yk)

emgsplit = yk;
epoch_duration = 10;

% W=32;
W = 16;
X = ones(size(yk,2),1);
X = [X (1:size(yk,2))'];

yk = abs(hilbert((yk'))).^2;
yk_inverted = yk(end:-1:1,:);

%% Smoothing
for ii = 1:1:size(yk,2)
    yk_tilde(:,ii) = (smooth(yk(:,ii),W,'moving'))';
    yk_tildeinv(:,ii) = (smooth(yk_inverted(:,ii),W,'moving'))';
    yk_tot(:,ii) = (yk_tilde(:,ii)+yk_tildeinv(end:-1:1,ii))/2;
end

% yk=abs(yk); %Rectification
Wstar = 1;
Wend = 8;
%%
pend = zeros(size(yk));
[~,massimi] = max(yk_tot);
for ii = 1:1:size(yk_tot,2) %For every epoch
    for Wstar = 1:1:size(yk,1)
        %Linear regression
        linreg = X(Wstar:Wend,:)\yk_tot(Wstar:Wend,ii);
        pend(Wstar,ii) = linreg(2);
        if Wend < size(yk,1)
            Wend = Wend + 1;
        end
    end
    Wend = 8;
end
%%
perce = 0.96; perceg = 0.80; %74 worked well, not well enough
for ii = 1:1:size(pend,2)
    mu0 = mean(mean(pend(:,ii)));
    sigma0 = mean(std(pend(:,ii)));
    %% Normalization
    gk(:,ii) = 1/sigma0*(pend(:,ii) - mu0); %    
    h = quantile(gk(1:massimi(ii),ii),perce);    
    g = quantile(-gk(end:-1:massimi(ii),ii),perceg);
    ta(ii) = find(gk(:,ii) >= h,1 ,'first');
    tfin(ii) = find(-gk(end:-1:1,ii) > g,1 ,'first');
    t0(ii) = (ta(ii))/128;
    epochonset(ii) = ta(ii);
    emgonset(ii,1) = t0(ii)+ epoch_duration*(ii-1);
    emgoffset(ii,1) = (size(gk,1) - tfin(ii))/128 + epoch_duration*(ii-1);
end



sigmaemg = mean(std(emgsplit,[],2));
peakness = max(emgsplit,[],2)./(emgoffset-emgonset); % First Feature
outpower = mean([emgsplit(:,1:ta), emgsplit(:,tfin:end)].^2,2);
secondmax = max([emgsplit(:,1:ta), emgsplit(:,tfin:end)],[],2)/sigmaemg;
peakpowernorm = (max(emgsplit,[],2).^2)/sigmaemg;
peakpower = max(emgsplit,[],2).^2;
PAPR = peakpower./outpower; % Second feature

%% Preparing my dataset
nsamples = size(emgsplit,2);
testset = emgsplit;
load('MdlLinear');
load('coeff');
result = zeros(size(testset,1),1);
for index = 1:size(emgsplit,1)
    %% Normalization
    mu = repmat(mean(testset(index,:)),nsamples,1)';
    sigma = repmat(std(testset(index,:)),nsamples,1)';
    test = (testset(index,:)- mu)./sigma;
    
    %% Principal components
    score = test * coeff(:,1:5) ;
    
    %% Classification
    xdata = [score peakness(index) PAPR(index)]; % good one
    label = predict(MdlLinear,xdata);
    %% Mapping  ( bad ==> 0 ; good ==>1)
    if  strcmp(cell2mat(label) ,'good')
        result(index) = 1;
    else
        result(index) = 0;
    end
end
size(find(result),1)
%% Construct a questdlg with three options
discarded = num2str((size(emgonset,1)-size(find(result),1)));
total =  num2str((size(emgonset,1)));
title = strcat('Due to non proper movements,',' ',discarded,' out of ',' ',total,...
    ' will be discarded','. How do you want to proceed?');
choice = questdlg(title, ...
    'Discard epochs', ...
    'Discard bad epoch','Do not discard','Allign on peaks','Discard bad epoch');
% Handle response
switch choice
    case 'Discard bad epoch '
        emgonset = emgonset(find(result));
    case 'Do not discard'
        
    case 'Allign on peaks'
        assignin('base','FlagOnset',2);
end

assignin('base','result',result);
assignin('base','emgonset',emgonset);
assignin('base','emgsplit',emgsplit);
assignin('base','slope',gk');
assignin('base','ta',ta);
assignin('base','t0',t0);
assignin('base','emgoffset',emgoffset);

emgshow();
end

