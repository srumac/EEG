function [output] = findstartLJ(ljack,fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Fpass = 30;             % Passband Frequency
Fstop = 33;               % Stopband Frequency
Dpass = 0.028774368332;  % Passband Ripple
Dstop = 0.031622776602;  % Stopband Attenuation
flag  = 'scale';         % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]/(fs/2), [1 0], [Dstop Dpass]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);

ljack = filtfilt(b,1,-ljack);

ljack = abs(ljack);
plot(ljack)
% thresh = 0.6*max(ljack);
thresh =250;
[~,output] = findpeaks(ljack,fs, 'MinPeakHeight', thresh, 'MinPeakDistance',7);
end
