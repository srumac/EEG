% function [emgonset] = onsetEMGimproved(yk)
clear all
close all
clc

load('emgsplit')
yk=emgsplit;
% emgsplit=yk;
epoch_duration=10;


W=32;
X=ones(size(yk,2),1);
X=[X (1:size(yk,2))'];

yk=(yk').^2;
yk_inverted=yk(end:-1:1,:);

%%Smoothing
for ii=1:1:size(yk,2)
yk_tilde(:,ii)=(smooth(yk(:,ii),W,'moving'))';
yk_tildeinv(:,ii)=(smooth(yk_inverted(:,ii),W,'moving'))';
yk_tot(:,ii)=(yk_tilde(:,ii)+yk_tildeinv(end:-1:1,ii))/2;
end

% yk=abs(yk); %Rectification
Wstar=1;
Wend=8;

pend=zeros(size(yk));
data=[];
for ii=1:1:size(yk_tot,2) %For every epoch
    
    for Wstar=1:1:size(yk,1)
          %Linear regression
        linreg=X(Wstar:Wend,:)\yk_tot(Wstar:Wend,ii);
        pend(Wstar,ii)= linreg(2);
        if Wend<size(yk,1)
            Wend=Wend+1;
        end
        
    end
    Wend=8;
    data=[data -pend(end:-1:1)];
end
% for ii=1:1:size(pend,2) %For every epoch
%     
%     for Wstar=1:1:size(pend,1)
%           %Linear regression
%         linreg=X(Wstar:Wend,:)\pend(Wstar:Wend,ii);
%         pend(Wstar,ii)= linreg(2);
%         if Wend<size(yk,1)
%             Wend=Wend+1;
%         end
%         
%     end
%     Wend=8;
%     data=[data -pend(end:-1:1)];
% end
%  P = ( length( data(data<0.2 ) )+0.5)/length(data)*100
% 
for ii=1:1:size(pend,2)

    mu0=mean(mean(pend(:,ii)));
    sigma0=mean(std(pend(:,ii)));
%% Normalization
    gk(:,ii)=1/sigma0*(pend(:,ii)-mu0); %
    
    perce=0.96;
    h=quantile(gk(:,ii),perce);
    perceg=0.90;
    g=quantile(-gk(end:-1:1,ii),perceg);
%   if( ii ==22)
%       g
%   end
    ta(ii)=find(gk(:,ii)>=h,1 ,'first');
    
%     tfin(ii)=find(emgsplit(ii,end:-1:1)>0,1 ,'first');
    tfin(ii)=find(-gk(end:-1:1,ii)>h,1 ,'first');
    t0(ii)=(ta(ii))/128;
    emgonset(ii,1)=t0(ii)+ epoch_duration * (ii-1);
    emgoffset(ii,1)=(size(gk,1)-tfin(ii))/128+ epoch_duration * (ii-1);
end

% assignin('base','gk_norm',gk_norm);
assignin('base','emgonset',emgonset);
assignin('base','emgsplit',emgsplit);
assignin('base','slope',gk');
assignin('base','ta',ta);
assignin('base','t0',t0);
assignin('base','emgoffset',emgoffset);
emgshow();

