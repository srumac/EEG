%% Prova con Marco
%% Resampling and detrending
EEG = pop_resample( EEG, 128);

breakpoints=1:epoch_duration*EEG.srate:size(EEG.data,2);
EEG.data = detrend(EEG.data','linear',breakpoints)'; %Detrending

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
% Hd = dfilt.dffir(b);
% fvtool(b)
groupdelay=grpdelay(b);
EEG.data = filter(b,1,EEG.data,[],2);
EEG.data=circshift(EEG.data,-groupdelay(1),2);

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
groupdelay=grpdelay(b);
EEG.data = filter(b,1,EEG.data,[],2);
EEG.data=circshift(EEG.data,-groupdelay(1),2);

%% Extract epoch and averaging 
EEG = pop_epoch( EEG, {  }, [-4 4], 'newname', 'Epoched data', 'epochinfo', 'no');
EEG = eeg_checkset( EEG );
eeglab redraw;
%Retrieve the index of the FC3 channel
FC3nochan = strmatch('C3',char(EEG.chanlocs.labels));
%Average
FC3=EEG.data(FC3nochan,:,:);
FC3tutti=reshape(FC3,size(FC3,2),size(FC3,3)); %Eliminates the 1x

%% Qui bisogna applicare la funzione per calcolare il drift
% qui FC3tutti è una matrice 1024*40
 
% FUNZIONE DI MARCO
Drift=[]; %1024x40
for ee=1:size(FC3tutti,2)
    Drift(:,ee)=compute_drift_fun(FC3tutti(:,ee)'); %passo l'epoca
end

% Qui faccio la media
FC3tutti=mean(Drift,2);

% FUNZIONE DI MARCO

% Qui faccio la media
% FC3tutti=mean(FC3tutti,2);

%% Low pass filter 1.5 Hz
Fpass = 1.5;             % Passband Frequency
Fstop = 2;               % Stopband Frequency
Dpass = 0.028774368332;  % Passband Ripple
Dstop = 0.031622776602;  % Stopband Attenuation
flag  = 'scale';         % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]/(Fs/2), [1 0], [Dstop Dpass]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
%  fvtool(b)
groupdelay=grpdelay(b);
FC3tutti= filter(b,1,FC3tutti);
FC3tutti=circshift(FC3tutti,-groupdelay(1));
FC3tutti=FC3tutti(1:end-groupdelay(1));

%% Plots
figure,
xpoints=0:1:length(FC3tutti)-1;
xseconds=(xpoints/EEG.srate)-4; 
h1=plot(xseconds,-FC3tutti,'b');   
title('Readiness Potential');
set(h1,'LineWidth',2);
set(gca,'FontSize',16);
legend('BP','reverse','Drift');

