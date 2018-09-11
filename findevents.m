function DATA = findevents(DATA)
% % % % findevents.m % % % %
% INPUT: - our data structure 'DATA'
% This function does: - call myfilterEMG.m to filter the EMG;
%                     - save the EMG onsets + event type in DATA.events;
% % % % % % % % % % % % % % % % 

%% Filter the EMG signal
DATA.emg = myfilterEMG(DATA.emg,DATA.sfreq);

%% Find the EMG onsets, using LabJack where possible
% % % THE LABJACK FLAG IS NOT USED RIGHT NOW
if DATA.flaglabjack == 1
%     s = findstartLJ(DATA.labjack,DATA.fs);
    events = EMGonset(DATA.emg,128,1);
elseif DATA.flaglabjack == 0
    events = EMGonset(DATA.emg,128,1);
end

%% Add a second row w/ the type of event (i.e. '1')
temp = ones(2,length(events));
temp(1,:) = events;

% Save the events into the structure
DATA.events = temp;
end

