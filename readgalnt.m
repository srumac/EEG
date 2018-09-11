function [DATA] = readgalnt(file,fs,epoch_duration,flaglabjack,emgtrace)
% % % % readgalnt.m % % % %
% This function does: - load the .asc file;
%                     - read the traces from all channels;
%                     - separate the EMG trace for further analysis as '.emg' attribute;
%                     - delete unused traces.
% % % % % % % % % % % % % % % % 
%% Open the text file
fileID = fopen(file,'r'); 
if(fileID == -1)
    disp('error');
end

%% Reads line until the first empty line
info = [];
nextline = fgetl(fileID);
while(~isempty(nextline))
    % Horizontally concatenate
    info = horzcat(info,'//',nextline); 
    nextline = fgetl(fileID);
end
fgetl(fileID);

% Dataset information
DATA.intel = strsplit(info,'//'); 

%% Extract traces' names from the ASCII file

% Format of the data to scan (quoted)
format = repmat('%q',1,70); % 70 --> overestimated number of traces
traces = textscan(fileID, format, 1); 

% Convert array of strings into cells
ctraces = cellstr([traces{:}]);
% Save the number of traces
colmn = size(find(~cellfun(@isempty,ctraces)),2); 
% Remove empty columns
ctraces = ctraces(1,1:colmn); 
% Convert cell into a matrix
mtraces = cell2mat(ctraces);
% Separate traces using commas
straces = strsplit(mtraces,','); 
validchannel = find(~cellfun(@isempty,regexp(straces,'\w*-RF')));

% Format of the data to scan (quoted) --> %f: float
format = repmat('%f',1,colmn); 
data = textscan(fileID,format); 

% Close file
fclose(fileID);

%% Find the EMG trace position, save it as Data.emg, and delete it from data
if emgtrace == 2
    emgtracesnumber = strmatch('EMG2',straces)';
elseif emgtrace == 1
    emgtracesnumber = strmatch('EMG1',straces)';
else
    disp('error');
end

% Save the EMG trace
DATA.emg = cell2mat(data(:,emgtracesnumber));
% Convert to mV
DATA.emg = DATA.emg/1000;

% Delete all EMG containing traces
allEMGtraces = strmatch('EMG',straces)';
validchannel = setdiff(validchannel,allEMGtraces);

% Delete Pulsante
pulstrace = strmatch('Pulsante',straces)';
validchannel = setdiff(validchannel,pulstrace);
% Delete MK
MKtrace = strmatch('MK',straces)';
validchannel = setdiff(validchannel,MKtrace);
% Delete AR
ARtrace = strmatch('AR',straces)';
validchannel = setdiff(validchannel,ARtrace);
% Delete TM
TMtrace = strmatch('TM',straces)';
validchannel = setdiff(validchannel,TMtrace);
% Delete EOG
EOGtrace = strmatch('EOG',straces)';
validchannel = setdiff(validchannel,EOGtrace);

%% Find the Labjack trace position, save it as Data.labjack, and delete it from data
if flaglabjack == 1
    labjacktracenum = strmatch('LabJack',straces)';
    % Save also EOG channels
%     EOGsx_trace= strmatch('EOGsx',straces)';
%     EOGdx_trace = strmatch('EOGdx',straces)';
    DATA.labjack = cell2mat(data(:,labjacktracenum));
%     DATA.eogsx = cell2mat(data(:,EOGsx_trace));
%     DATA.eogdx = cell2mat(data(:,EOGdx_trace));
    % Delete from data
    validchannel = setdiff(validchannel,labjacktracenum);
end

% Save EEG traces (data) and traces, w/o labjack and EMG
data = cell2mat(data(:,validchannel))';
straces = straces(validchannel);

% Delete -RF from traces' names
DATA.labels = strrep(straces,'-RF','');

%% Populate the structure
DATA.data = data;
DATA.sfreq = fs;
DATA.epoch_duration = epoch_duration;
DATA.flaglabjack = flaglabjack;

end

