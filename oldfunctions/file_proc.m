% file_proc() -Processes a GalNT EEG trace
%
% Usage:
%   >> [Data] = file_proc( fileName, sam_freq, epoch_duration);
%
% Inputs:
%  fileName           - Ascii file to be processed
%  sam_freq           - Sampling frequency
%  epoch_duration     - Duration of each epoch
%
% Outputs:
%  DATA      - Data structure containg eeg raw data, electromyography
%  peaks, patient information (intel) , channel locations
%
% Author:  Remo Arena(remo.arena@gmail.com, Politecnico di Torino,
%          Torino, Italy, 2016)
% Copyright (C) 2016 Remo Arena
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function [DATA] = file_proc(fileName, sam_freq, epoch_duration,flaglabjack,flagemg)

fileID = fopen(fileName,'r'); %Opens the file
if(fileID == -1)
    disp('error');
end


info = [];
nextline = fgetl(fileID);
%Reads line until the first empty line
while(~isempty(nextline))
    info = horzcat(info,'//',nextline); %horizontally concatenate
    nextline = fgetl(fileID);
end
fgetl(fileID);
intel = strsplit(info,'//'); %Dataset information


%Extract traces' names from the ASCII file
format = repmat('%q',1,70); %Format of the data to scan (quoted)
%The number of expected traces is overestimated

traces = textscan(fileID, format, 1); %Scan to find traces names
%%%%%

ctraces = cellstr([traces{:}]); % Convert  array of strings into cells
colmn = size(find(~cellfun(@isempty,ctraces)),2); %Counts the number of traces

format = repmat('%f',1,colmn); %Format of the data to scan (quoted)
data = textscan(fileID,format); %Scan to find floating
fclose(fileID);
ctraces = ctraces(1,1:colmn); %Resize to eliminate empty columns
mtraces = cell2mat(ctraces); %Convert cell into a matrix
straces = strsplit(mtraces,','); %Separates the traces by exploiting the commas
validchannel = find(~cellfun(@isempty,regexp(straces,'\w*-RF')));
if flagemg == 0
    emgtracesnumber = strmatch('EMG2',straces)';
else
    emgtracesnumber = strmatch('EMG1',straces)';
end
emg = cell2mat(data(:,emgtracesnumber));

% Find LabJack signal
% Separation of EMG traces from EEG traces
emgtracesnumber = strmatch('EMG',straces)';%Find the traces related to EMG


if flaglabjack == 1
    labjacktracenum = strmatch('LabJack',straces)';
    labjack = cell2mat(data(:,labjacktracenum));
    sounds = findstartLJ(labjack,sam_freq);
    breakpoints = sounds + 7;
    final = setdiff(validchannel,[emgtracesnumber labjacktracenum]);
else
    final = setdiff(validchannel,emgtracesnumber);
    breakpoints = 1:epoch_duration*sam_freq:size(emg,2); 
end

data = cell2mat(data(:,final))';
straces = straces(final);

labels = strrep(straces,'-RF','');
%% Da rifare
secondi = size(emg,1) / sam_freq; % Traces duration
ril_tot = floor(secondi / epoch_duration); % Number of epochs

old_sam_freq = sam_freq;
sam_freq = 128;
emg = resample(emg,sam_freq,old_sam_freq); 
% breakpoints = 1:epoch_duration*sam_freq:size(emg,2);

%% Low Pass Filter
Fs = 128;
Fpass = 9;             % Passband Frequency
Fstop = 10;               % Stopband Frequency
Dpass = 0.028774368332;  % Passband Ripple
Dstop = 0.031622776602;  % Stopband Attenuation
flag  = 'scale';         % Sampling Flag

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]/(Fs/2), [1 0], [Dstop Dpass]);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);


% fvtool(b)

emg = filtfilt(b,1,-emg);
[N,Wn,BETA,TYPE] = kaiserord([2 3]/(Fs/2), [0 1], [Dstop Dpass]);
b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
emg = filtfilt(b,1,-emg);
% [imf,~,~] = emd(emg,'Interpolation','pchip','Display',0);
% emg = emg - (imf(:,1) + imf(:,2) + imf(:,3) );
if flaglabjack == 1
    breakpoints = floor(breakpoints*Fs);
end
emg = detrend(emg','linear',breakpoints)';
% plot(emg)
% Epoch EMG
if flaglabjack == 1
    start = floor(1*Fs);
    ending = floor(9*Fs);
    sounds = floor(sounds*Fs);
    sounds(end) = []; 
    for kk = 1:length(sounds)
        ind = sounds(kk,:);
        emgsplit(kk,:) = emg(ind-start:ind+ending-1);
    end
else 
    emg = emg(1:sam_freq*epoch_duration*ril_tot);
    emgsplit = (reshape(emg,sam_freq*epoch_duration,ril_tot))';
end

save('emgsplit','emgsplit');
emgonset = onEMGultimate(emgsplit);
size(emgonset)
% Find the maximum of the EMG for each epoch (for allignment)
[~, spot] = max(emgsplit, [], 2);
emgpeaks = zeros(ril_tot,2);

for i = 1:1:length(emgonset)
    emgonset(i,1) = emgonset(i);%+ epoch_duration * (i-1);
    emgonset(i,2) = 2;
    emgpeaks(i,1) = spot(i)/sam_freq + epoch_duration * (i-1);
    emgpeaks(i,2) = 1;
end
%% Populate structure
DATA.onset = emgonset;
DATA.emg = emgpeaks;
DATA.data = data;
DATA.sam_freq = sam_freq;
DATA.epoch_duration = epoch_duration;
DATA.intel = intel;
DATA.labels = labels;
end
