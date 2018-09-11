function emgout = myfilterEMG(emg,oldfs)
% % % % % myfilterEMG.m % % % %
%  INPUT and OUTPUT: EEG structure
% % % % % % % % % % % % % % % %

%% Save original fs, Nyquist f && resample @128Hz
newfs = 128;
fNy = newfs/2;
emgout = resample(emg,128,oldfs);
%% Detrending
emgout = emgout - mean(emgout);
emgout = detrend(emgout);
%% Notch Filter
% wo = 50/(fNy);  bw = wo/35;
% [b,a] = iirnotch(wo,bw);
% emgout = filtfilt(b,a,emgout);
% %% 15th order band-pass Butterworth Filter [30-300Hz]
% n = 15;
% Wn = 40/(fNy);
% [b,a] = butter(n,Wn,'low');
% emgout = filtfilt(b,a,emgout);

%% Apply TKEO operator (UNUSED RIGHT NOW)
% [~,ex] = energyop(emgout,0);
% [emgout,~] = envelope(ex,33,'analytic');

% apply SG filter to smooth data
emgout = smooth(emgout,47);
end

