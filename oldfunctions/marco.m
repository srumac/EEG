%% Resampling and detrendins
Fresample=128;
EEG = pop_resample( EEG, Fresample);

breakpoints=1:epoch_duration*EEG.srate:size(EEG.data,2);
EEG.data = detrend(EEG.data','linear',breakpoints)';

% 7 canali ed epoca da 8s (adesso, dopo resample, 1280 campioni)
% mu = detrend + HPF_7_5 + LPF_12_5 dim = 7x51200 le 40 epoche in fila
% raw = detrend + LPF_12_5 dim = 7x51200 le 40 epoche in fila
% e allinearli  tenendo conto dei ritardi dei filtri

%% Low Pass Filter 12.5 HZ
Fs = 128;  % Sampling Frequency

Fpass = 12.5;            % Passband Frequency
Fstop = 13.5;            % Stopband Frequency
Dpass = 0.028774368332;  % Passband Ripple
Dstop = 0.031622776602;  % Stopband Attenuation
flag  = 'scale';         % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]/(Fs/2), [1 0], [Dstop Dpass]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
%  fvtool(b)
gd12p5=grpdelay(b); %grup delay of 12.5 LP filter
raw=filter(b,1,double(EEG.data),[],2);
mu=filter(b,1,double(EEG.data),[],2);
% EEG.data=filter(b,1,double(EEG.data));

%% High pass filter 7.5 Hz
% FIR Window Highpass filter designed using the FIR1 function.
% All frequency values are in Hz.
Fs = 128;  % Sampling Frequency

Fstop = 6.5;              % Stopband Frequency
Fpass = 7.5;              % Passband Frequency
Dstop = 0.031622776602;   % Stopband Attenuation
Dpass = 0.0028782234183;  % Passband Ripple
flag  = 'scale';          % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fstop Fpass]/(Fs/2), [0 1], [Dpass Dstop]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
Hd = dfilt.dffir(b);
% fvtool(b)
gd7p5=grpdelay(b); %grup delay of 7.5 HP filter
mu=filter(b,1,mu,[],2);
% EEG.data=filter(b,1,double(EEG.data));

%% Allineamento
rawAlligned=circshift(raw,-gd12p5(1),2);
muAlligned=circshift(mu,-gd12p5(1)-gd7p5(1),2);


%%
%Extract epoch
% EEG = pop_epoch( EEG, {  }, [-4 4], 'newname', 'Epoched data', 'epochinfo', 'no');
% EEG = eeg_checkset( EEG );
% eeglab redraw;
% %Retrieve the index of the FC3 channel
% FC3nochan = strmatch('Fc3',char(EEG.chanlocs.labels));
% %Average
% FC3=EEG.data(FC3nochan,:,:);
% FC3tutti=reshape(FC3,size(FC3,2),size(FC3,3)); %Eliminates the 1x
% FC3tutti=mean(FC3tutti,2);
EEG.data = rawAlligned;

%Extract epoch
EEG = pop_epoch( EEG, {  }, [-4 4], 'newname', 'Epoched data', 'epochinfo', 'no');
EEG = eeg_checkset( EEG );
eeglab redraw;
%Retrieve the index of the FC3 channel
FC3nochan = strmatch('Fc3',char(EEG.chanlocs.labels));
%Average
FC3=EEG.data(FC3nochan,:,:);
FC3tutti=reshape(FC3,size(FC3,2),size(FC3,3)); %Eliminates the 1x
rawFC3tutti=FC3tutti;


EEG.data = muAlligned;

%Extract epoch
EEG = pop_epoch( EEG, {  }, [-4 4], 'newname', 'Epoched data', 'epochinfo', 'no');
EEG = eeg_checkset( EEG );
eeglab redraw;
%Retrieve the index of the FC3 channel
FC3nochan = strmatch('Fc3',char(EEG.chanlocs.labels));
%Average
FC3=EEG.data(FC3nochan,:,:);
FC3tutti=reshape(FC3,size(FC3,2),size(FC3,3)); %Eliminates the 1x
muFC3tutti=FC3tutti;


%% Plots
figure,
xpoints=0:1:length(FC3tutti)-1;
xseconds=(xpoints/EEG.srate)-4;
h1=plot(xseconds,rawFC3tutti(:,1),'r');   
title('rawFC3tutti VS muFC3tutti ');
set(h1,'LineWidth',2);
set(gca,'FontSize',16);
hold on
h2=plot(xseconds,muFC3tutti(:,1),'b--');   
set(h2,'LineWidth',2);
set(gca,'FontSize',16);
legend('rawFC3tutti','muFC3tutti')

figure;pwelch(muFC3tutti)
figure;pwelch(rawFC3tutti)