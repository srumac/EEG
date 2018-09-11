function [onsetpoints] = EMGonset(emg,fs,plotflag)
% % % % EMGonset.m % % % %
%  INPUTS: - emg: the EMG trace;
%          - fs: sampling frequency;
%          - plotflag: 1 to plot the EMG with onset and peak points.
% OUTPUTS: - onsetpoints: the EMG onset times (or peaks, if selected)
% % % % % % % % % % % % % % % %

%% If peaks are negative, flip the signal
if abs(max(emg)) < abs(min(emg))
    emg = -emg;
end

% Length of the baseline window
baselinewindow = 65; % 500 ms

% Length of the sliding window
winsize = 13; % 101 ms

% Samples corresponding to 7 seconds of signal
sevensec = 7*fs;

%% Find the EMG peaks, distanced of more than 5s
t = std(emg);
[peaks, peakloc] = findpeaks(emg,'MinPeakDistance', sevensec, 'MinPeakHeight', t);

%% Delete peaks too close to the beginning/eng of the signal
elim = [];
for i = 1:length(peaks)
    if (peakloc(i) < sevensec) || (peakloc(i) > (length(emg)-sevensec))
        elim = [elim i];
    end
end

% Save the final number of peaks
peakloc(elim) = []; peaks(elim) = [];
npeaks = length(peaks);

%% Divide the signal in [-2,+0]s epochs, w/ peaks as reference (i.e. t = 0s)

% Divide in windows and save their starting point
emgwin = zeros(npeaks,fs*2+1); emgwinstart = zeros(npeaks,1);
for j = 1:npeaks
    p = peakloc(j);
    emgwin(j,:) = emg(p-fs*2:p);
    emgwinstart(j) = p-fs*2;
end

%% Find the onset, for every peak window
JJ = 1.5; onsetemgwin = zeros(npeaks,1); onset = zeros(npeaks,1);

for k = 1:npeaks % for every peak
    window = emgwin(k,:);
    window = [window 0];
    
    baseline = emgwin(k,1:baselinewindow);
    threshold = mean(baseline) + JJ*std(baseline);
    dif_window = diff(window);
    candidates = [];
    % % %     UNUSED PART
    for ii = 1:(size(emgwin,2)-winsize) % for every 101ms window
        slidew = window(ii:ii+winsize);
        
        if mean(slidew) < threshold
            candidates = [candidates ii+winsize];
        end
    end
    
    % Find abrupt changes
    pp = findchangepts(window,'Statistic','std');
    onset(k) = pp(1) + emgwinstart(k);
end

% onset = findchangepts(emg,'MaxNumChanges',40,'MinDistance',fs*2,'Statistic','mean');
%% If plotflag = 1, plot the data
if plotflag == 1
    plot(emg,'LineWidth',.3);hold on
    plot(onset,emg(onset),'x','LineWidth',.3);hold on
    plot(peakloc,emg(peakloc),'d','LineWidth',.3);
    legend('EMG trace','Onset point','Peak point');ylabel('EMG amplitude (mV)'); xlabel('Samples')
end

%% Align on peaks: uncomment to ask the user to align on peaks or onsets
% ans = inputdlg({'Press 1 to align on peaks:'});
% peakflag = str2num(ans{1});
% if peakflag == 1
%     onset = peakloc;
% end

%% Convert onset to seconds
onsetpoints = onset/fs;
end

