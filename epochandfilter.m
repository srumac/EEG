% % % % epochandfilter.m % % % %
% This function does: - resample the data at 128 Hz;
%                     - run myfilterEEG.m to remove slow drifts;
%                     - epochs the signal between -4s and +4s from the
%                     events;
%                     - removes the baseline between -4s and -2.8s
% % % % % % % % % % % % % % % % 

%% Resample at 128Hz and filter the EEG [0.01Hz - 30Hz]
if EEG.srate ~= 128
    EEG = pop_resample(EEG, 128);
end
EEG = myfilterEEG(EEG);

%% Epoch from -4s to +4s
EEG = pop_epoch( EEG, {}, [-4 4]);

%% Remove the baseline between -4000ms and -2800ms
timerange = [-4000 -2800];
EEG = pop_rmbase( EEG, timerange);

%% Update EEGLAB
[ALLEEG, EEG,CURRENTSET] = eeg_store(ALLEEG, EEG);
EEG = eeg_checkset( EEG );
eeglab redraw