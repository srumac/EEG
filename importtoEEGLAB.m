% % % % importtoEEGLAB.m % % % %
% This script does: - load the .asc file --> readgalnt.m;
%                     - extract the EMG trace and find its onset --> findevents.m;
%                     - imports data and events to the EEGLAB structure.
% % % % % % % % % % % % % % % % 

%% Load file
[fileName,pathname] = uigetfile('*.asc','Select the file to import');
fileName = [pathname fileName];

%% Load sampling frequency and epoch duration
answer = inputdlg({'Enter sampling frequency:','Enter epoch duration:','Enter 1 if LabJack:','Enter 1 for EMG1'},'Dataset parameter',1,{'512','10','1','1'});

% Save sampling frequency, epoch duration (old), labjack flag and number of
% EMG trace to analyze (EMG1 or EMG2)
sam_freq = str2double(answer(1,:));
epoch_duration = str2double(answer(2,:));
flaglabjack = str2double(answer(3,:));
emgtrace = str2double(answer(4,:));

%% File processing: 1. Read the file, save it to RawData structure
RawData = readgalnt(fileName,sam_freq,epoch_duration,flaglabjack,emgtrace);

%% File processing: 2. Find the EMG onset --> Rawdata.events
RawData = findevents(RawData);

%% Import data to EEGLAB data structure
eegtraces = RawData.data;
EEG = pop_importdata('subject',fileName,'dataformat','array','nbchan',0,'data','eegtraces','setname','Continuous EEG Data','srate',sam_freq,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG.filename = fileName;
%% Import channel locations
EEG.chanlocs = struct('labels', RawData.labels);
EEG = pop_chanedit(EEG, 'lookup','C:\Users\Utente\Documents\Eeglab_LRPLab - originale\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp','plotrad',1);

%% Save and import the events
eventlist = RawData.events;
eventtype = 'EmgOnset';

% import the events to the EEG structure
EEG = pop_importevent( EEG, 'append','no','event',eventlist ,'fields',{'latency' 'type'},'timeunit',1);

% save the labjackflag as an EEG structure attribute
EEG.flaglabjack = flaglabjack;
%% Import the patient's information
EEG.comments = pop_comments('', '', RawData.intel);
EEG = eeg_checkset( EEG );
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_resample(EEG, 128);

eeglab redraw