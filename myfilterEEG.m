function EEG = myfilterEEG(EEG)
% % % % myfilterEEG.m % % % %
% INPUTS:  - EEG eeglab structure: it works both with epoched signals and
%            continuous data       
% OUTPUTS: - EEG structure with filtered channels between 0.01Hz and 30Hz
% % % % % % % % % % % % % % % % % 

%% High pass filter @0.01Hz
cutoff = 0.01; tbw = 1.5;
m = pop_firwsord('blackman', EEG.srate, tbw);
b = firws(m, cutoff / (EEG.srate / 2), 'high', windows('blackman', m + 1)); 

% Filter the EEG and compensate for linear delay
EEG = firfilt(EEG,b,EEG.srate*10);

%% Low Pass @30 Hz
cutoff = 30; tbw = 1.5;
m = pop_firwsord('hamming', EEG.srate, tbw);
b = firws(m, cutoff / (EEG.srate / 2), 'low', windows('hamming', m + 1)); 

% Filter the EEG and compensate for linear delay
EEG = firfilt(EEG,b,EEG.srate*10);
end