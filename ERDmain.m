function [] = ERDmain(EEG,channelname,flow,fhigh)
% % % % ERDmain.m % % % %
% This function computed and plots the ERD/ERS on an epoched EEG structure.
% ERD/ERS is computed using two methods:
% - standard method (Pfurtscheller, 1997) --> calling findERD.m;
% - more recent method using morlet wavelet --> calling morletCWT.m;
% % % % % % % % % % % % % 
if nargin == 1
    %% Ask for band limits
    answer = inputdlg({'Channel name:','Low frequency:','High frequency:'},'Dataset parameter',1,{'C3','8','12'});

    % the default channel is 'C3'
    channelname = answer(1,:);
    flow = str2double(answer(2,:));
    fhigh = str2double(answer(3,:));
else 
    channelname = channelname(1,:);
end
%% Normal Method 
erd1 = findERD(EEG,channelname, flow, fhigh);

%% Wavelet Method
erd2 = morletCWT(EEG,channelname,flow,fhigh);

%% Plot the results without first and last second
onesecond = EEG.srate*1.5;
figure('Name','ERD/ERS Figure')
plot(EEG.times(onesecond:end-onesecond)/1000,100*smooth(erd1(onesecond:end-onesecond),32));hold on;
plot(EEG.times(onesecond:end-onesecond)/1000,100*smooth(erd2(onesecond:end-onesecond),32));
legend('Band Power', 'Morlet Wavelet'); title([num2str(flow) '-' num2str(fhigh) 'Hz']); axis tight; ylabel('Power percentage'); xlabel('Seconds')
end