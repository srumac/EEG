%% IMPORT
FlagOnset = 1;

%% Load file
[fileName,pathname] = uigetfile('*.asc','Select the file to import');
name = fileName;
fileName = [pathname fileName];

%% Load sampling frequency and epoch duration
answer = inputdlg({'Enter sampling frequency:','Enter epoch duration:','Enter 1 if LabJack:','Enter 1 for EMG1'},'Dataset parameter',1,{'512','10','1','1'});
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

%% Import events
if FlagOnset == 1
    eventlist = RawData.events;
    eventtype = 'EmgOnset';
else
    % unused right now
    eventlist = RawData.emg;
    eventtype = 'EmgPeak';
end

EEG = pop_importevent( EEG, 'append','no','event',eventlist ,'fields',{'latency' 'type'},'timeunit',1);
EEG.flaglabjack = flaglabjack;
%% Import patient's information
EEG.comments = pop_comments('', '', RawData.intel);
EEG = eeg_checkset( EEG );
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
%% EPOCH AND FILTER
% Resample @128Hz 
EEG = pop_resample(EEG, 128);
% Filter the EEG
EEG = myfilterEEG(EEG);
% Epoch
EEG = pop_epoch( EEG, {}, [-4 4]);

% %% Detrend
[ALLEEG, EEG,CURRENTSET] = eeg_store(ALLEEG, EEG);
eeglab redraw
% Remove the baseline between -4000ms and -2000ms
timerange = [-4000 -3200];
EEG = pop_rmbase( EEG, timerange);
%% Update EEGLAB
EEG = eeg_checkset( EEG );
eeglab redraw

%% SAVE
% pop_saveset(EEG)
