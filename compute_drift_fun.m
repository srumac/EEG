function [ Drift_out] = compute_drift_fun( mu_nochannel )


% function [ TroughLevel_mu_Drift_Values, TroughLevel_mu_Drift_Locs, TroughLevel_mu_Peak_Values,  TroughLevel_mu_Peak_Locs, TroughLevel_mu_Trough_Values, TroughLevel_mu_Trough_Locs] = compute_drift_fun( mu_nochannel )

% INPUT:
%       >>  mu_nochannel


% OUTPUT:
%       >>  TroughLevel_mu_Peak_Value
%       >>  TroughLevel_mu_Peak_Locs
%       >>  TroughLevel_mu_Trough_Values
%       >>  TroughLevel_mu_Trough_Locs
%       >>  TroughLevel_mu_Drift_Values
%       >>  TroughLevel_mu_Drift_Locs

%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%DESCRIPTION: this function is to cumpute the mu signal with all the
%troughs or all the peaks at the same level.
%We write the code to compute the mu signal with all the troughs at the
%same level.
%To compute the mu signal with all the peaks at the same level
%it will be sufficient pass -mu as input and then change the sign at the
%output of the function This function is to compute also the drift, i.e the
%mean signal between the troughs all at the same level and the peaks. 
%To %compute the drift between the peaks all at the same level and the troughs,
%it will be sufficient pass -mu as input and thrn change the sign at the
%output of the funtion !
close all
clc

%% assegno l'input
% canale:
%         noch=1; %C3
%         noch=2; %C4
%         noch=3; %Fc3
%         noch=4; %Fcz
%         noch=5; %Fc4
%         noch=6; %Cz
%         noch=7; %Pz       
%          ch=channel.no(noch);
%          mu_nochannel=muAlligned(ch,:);
        %% se passo come input -mu devo invertire l'output alla fine!
% %            mu_nochannel=-muAlligned(ch,:);
         
%% iniziatilization
        
%initizalize mu_noch structure
clear mu_noch
mu_noch.mu=[]; %mu original signal
mu_noch.Trough.Values=[]; %Trough values of original mu
mu_noch.Trough.Locs=[]; %Trough positions of original mu
mu_noch.Trough.Ref=[]; % Trough Reference: minimum of the troughs of original mu
mu_noch.Peak.Values=[]; %Peak values of original mu
mu_noch.Peak.Locs=[]; %Peak positions of original mu

%initialize TroughLevel_mu structure
clear TroughLevel_mu
TroughLevel_mu.TroughShift=[]; %Trough shifts requred to pull-down at the same level all the troughs of orignal mu
TroughLevel_mu.Trough.Values=[]; %Trough values of mu with all the troughs at the same level
TroughLevel_mu.Trough.Locs=[]; %Trough positions of mu with all the troughs at the same level
TroughLevel_mu.PeakShift=[]; %Peak shifts requred to pull-down all the peaks of mu with all troughs at the same level
TroughLevel_mu.Peak.Values=[]; %Peak values of mu with all the troughs at the same level
TroughLevel_mu.Peak.Locs=[]; %Peak positions of mu with all the troughs at the same level
TroughLevel_mu.Drift.Values=[]; %Drift values between peak and trough of mu with all the troughs at the same level
TroughLevel_mu.Drift.Locs=[]; %Drift position between peak and trough of mu with all the troughs at the same level

clear DriftStair
DriftStairs=[]; %DriftStair values between peak and trough of mu with all the troughs at the same level


%% pull-down the troughs at the same level: mu_noch.Trough.Ref!

mu_noch.mu=mu_nochannel;      
%To compute the mu signal with all the troughs at the same level it is
%necessary to compute the reference.
%We assume as reference the minimum of the troughs of mu
%we find the trough of mu, i.e the peak of -mu
[ mu_noch.Trough.Values, mu_noch.Trough.Locs]=findpeaks(double(-mu_noch.mu));
mu_noch.Trough.Values = - mu_noch.Trough.Values; % we have to invert the sign for the value! 
mu_noch.Trough.Ref=min(mu_noch.Trough.Values);
% we report the trough at the same level of  mu_noch.Trough.Ref
TroughLevel_mu.TroughShift=zeros(1,length(mu_noch.Trough.Locs));
for ii=1:length(mu_noch.Trough.Locs)
%     trough_loc=mu_noch.Trough.Locs(ii);
    TroughLevel_mu.TroughShift(ii)=mu_noch.Trough.Values(ii)-mu_noch.Trough.Ref; %store the value of shift
    TroughLevel_mu.Trough.Values(ii)=mu_noch.Trough.Values(ii)-TroughLevel_mu.TroughShift(ii);
end

TroughLevel_mu.Trough.Locs=mu_noch.Trough.Locs;
  

[ mu_noch.Peak.Values, mu_noch.Peak.Locs]=findpeaks(double(mu_noch.mu));
TroughLevel_mu.Peak.Locs=mu_noch.Peak.Locs;

%% pull-down the peaks:

% we pull down the peak of the quantity equal to the sum of the two shift
% to pull down at the same level the previous and next trough, divided by 2

% we can have 4 cases:
%                     >> mu starts with a peak:
%                                               - #peaks > #troughs : 
%                                                 mu ends necessarily with a peak !
%                                               - #peaks = # troughs : 
%                                                  mu ends necessarily with a trough!                                            troughs
%                                               
%                     >> mu starts with a trough:
%                                               - #troughs > #peaks : 
%                                                 mu ends necessarily with a trough                                           trough
%                                               - #peaks = # troughs : 
%                                                 mu ends necessarily with a peak

% check if mu starts with a peak or a trough
if mu_noch.Peak.Locs(1) < mu_noch.Trough.Locs(1)
    
    % mu starts with a peak, 1st peak:
    TroughLevel_mu.PeakShift(1)=TroughLevel_mu.TroughShift(1); 
    TroughLevel_mu.Peak.Values(1)=mu_noch.Peak.Values(1)-TroughLevel_mu.PeakShift(1);
    
    if length(mu_noch.Peak.Locs) > length(mu_noch.Trough.Locs)
        % #peaks > #troughs, then mu ends necessarily with a peak
        % mu ends with a peak, last peak:
        last_peak_index=length(mu_noch.Peak.Locs); % last_peak_index > no_iters
        TroughLevel_mu.PeakShift(last_peak_index)=TroughLevel_mu.TroughShift(end);  % / 2;
        TroughLevel_mu.Peak.Values(last_peak_index)=mu_noch.Peak.Values(end)-TroughLevel_mu.PeakShift(ii+1);
        % mu intermediate peaks
        no_iters=length(mu_noch.Trough.Locs); % #iters = #troughs , #peaks > #troughs
        for ii=2:1:no_iters
            TroughLevel_mu.PeakShift(ii) = ( TroughLevel_mu.TroughShift(ii-1) + TroughLevel_mu.TroughShift(ii) ) / 2 ;
            TroughLevel_mu.Peak.Values(ii) = mu_noch.Peak.Values(ii) - TroughLevel_mu.PeakShift(ii);
        end
    elseif length(mu_noch.Peak.Locs) == length(mu_noch.Trough.Locs)
        % #peaks = #troughs, then mu ends necessarily with a trough
        % mu intermediate peaks and last peak
        no_iters=length(mu_noch.Trough.Locs); % #iters = #troughs , #peaks = #troughs
        for ii=2:1:no_iters
            TroughLevel_mu.PeakShift(ii) = ( TroughLevel_mu.TroughShift(ii-1) + TroughLevel_mu.TroughShift(ii) ) / 2 ;
            TroughLevel_mu.Peak.Values(ii) = mu_noch.Peak.Values(ii) - TroughLevel_mu.PeakShift(ii);
        end
    else
        disp('error: if mu starts with a peak we can not have #peaks < #troughs'); 
    end        
    
elseif mu_noch.Trough.Locs(1) < mu_noch.Peak.Locs(1)
    
    % mu starts with a trough
    
    if length(mu_noch.Trough.Locs) > length(mu_noch.Peak.Locs)
        % #trough > #peaks, then mu ends necessarily with a trough
        % mu 1st peak, intermediate peaks and last peak
        no_iters=length(mu_noch.Peak.Locs); % #iters = #troughs , #troughs > #peaks
        for ii=1:1:no_iters
            TroughLevel_mu.PeakShift(ii) = ( TroughLevel_mu.TroughShift(ii) + TroughLevel_mu.TroughShift(ii+1) ) / 2 ;
            TroughLevel_mu.Peak.Values(ii) = mu_noch.Peak.Values(ii) - TroughLevel_mu.PeakShift(ii);
        end
    elseif length(mu_noch.Peak.Locs) == length(mu_noch.Trough.Locs)
        % #peaks = # troughs, then mu ends necessarily with a peak
        % mu ends with a peak, last peak:
        last_peak_index=length(mu_noch.Peak.Locs); % last_peak_index > no_iters
        TroughLevel_mu.PeakShift(last_peak_index)=TroughLevel_mu.TroughShift(end);  % / 2;
        TroughLevel_mu.Peak.Values(last_peak_index)=mu_noch.Peak.Values(end)-TroughLevel_mu.PeakShift(last_peak_index);   
        % mu 1st peak and intermediate peaks 
        no_iters=length(mu_noch.Peak.Locs)-1; % #iters = #troughs-1 , #troughs = #peaks
        for ii=1:1:no_iters
            TroughLevel_mu.PeakShift(ii) = ( TroughLevel_mu.TroughShift(ii) + TroughLevel_mu.TroughShift(ii+1) ) / 2 ;
            TroughLevel_mu.Peak.Values(ii) = mu_noch.Peak.Values(ii) - TroughLevel_mu.PeakShift(ii);
        end        
    else
        disp('error: if mu starts with a trough we can not have #troughs< #peaks');
    end
    
else
    disp('error: Peak_locs(1)=Trough_Locs(1)');
    
end



%% plot peak and trough of mu after pull-down 
% figure(44); 
%     
%     mu_nochannel_plot=plot(mu_nochannel,'k'); set(mu_nochannel_plot,'LineWidth',2); set(gca,'FontSize',16);
%     
%     hold on; grid on;
% 
%     mu_noch_Trough_plot=plot(mu_noch.Trough.Locs,mu_noch.Trough.Values,'vm');
%     set(mu_noch_Trough_plot,'LineWidth',2); set(gca,'FontSize',16);
%      
%     mu_noch_Peak_plot=plot(mu_noch.Peak.Locs,mu_noch.Peak.Values,'c^');
%     set(mu_noch_Peak_plot,'LineWidth',2); set(gca,'FontSize',16);
%     
%     TroughLevel_mu_Trough_plot=plot(TroughLevel_mu.Trough.Locs,TroughLevel_mu.Trough.Values,'vr');
%     set(TroughLevel_mu_Trough_plot,'LineWidth',2); set(gca,'FontSize',16);
%     
%     TroughLevel_mu_Peak_plot=plot(TroughLevel_mu.Peak.Locs,TroughLevel_mu.Peak.Values,'b^');
%     set( TroughLevel_mu_Peak_plot,'LineWidth',2); set(gca,'FontSize',16);
%      
%     TroughLevel_mu_Drift_plot=plot(TroughLevel_mu.Drift.Locs,TroughLevel_mu.Drift.Values,'--og');
%     set( TroughLevel_mu_Drift_plot,'LineWidth',2); set(gca,'FontSize',16);
% 
% %     xlim([1280*19 1280*20])
% %     xlim([1280*39.8 1280*40])
%     legend('mu nochannel', 'mu noch Trough','mu noch Peak', 'TroughLevel mu Trough','TroughLevel mu Peak');
%     title(['mu nochannel, mu noch Trough, mu noch Peak, TroughLevel mu Trough, TroughLevel mu Peak', '@ ', channel.name{noch}])






%% compute drift

%The drift betrween peak and trough i computed as follow:
% - in peak positions: the drift is equal to the sum of peak value (after
%   pulling-down) and the refrence level of trough (mu_noch.Trough.Ref), all
%   divevd by 2
% -in trough positions: the drift is equal to the sum of ( the sum of
% previous peak value and the refernce level of trough diveded by 2) and
% (the sum of the follow peak value and the refernce level of trough
% divided by 2), all divided by 2

% TroughLevel_mu.Drift.Locs contain the position of peaks and troughs
% sorted in ascending order
[TroughLevel_mu.Drift.Locs,indeces_sorted]=sort( [TroughLevel_mu.Peak.Locs   TroughLevel_mu.Trough.Locs]);

% Peaks_and_Troughs_Values_Sorted contain the values of peaks and troughs
% sorted in ascending order of position
Peaks_and_Troughs_Values = [TroughLevel_mu.Peak.Values   TroughLevel_mu.Trough.Values];
Peaks_and_Troughs_Values_Sorted = Peaks_and_Troughs_Values(indeces_sorted) ;


% we can have 2 cases:
%                     >> mu starts with a peak:
%                       Then the first element is a peak
%                       The peaks happen before the troughs;
%                       thus the peaks are indicized by odd indeces,
%                       while the troughs are indicized by even indeces.
%                       Moreover, at the last iter we check if:
%                       - the last elements is a peak, then mu ends with a peak                           
%                       - the last element is a trough, the mu ends with a trough
%                                         
%                     >> mu starts with a trough:
%                       Then the first element is a trough
%                       The troughs happen before the peaks;
%                       thus the troughs are indicized by odd indeces,
%                       while the peaks are indicized by even indeces.
%                       Moreover, at the last iter we check if:
%                       - the last elements is a peak, then mu ends with a peak                            
%                       - the last element is a trough, the mu ends with a trough


% check if the first element is a peak or a trough

if TroughLevel_mu.Drift.Locs(1) == TroughLevel_mu.Peak.Locs(1)
    
    % the 1st element is a peak. The peaks happen before the troughs
    % Thus the peaks are indicized by odd indeces
    % while the troughs are indicized by even indeces
    
    %check the last element
    if TroughLevel_mu.Drift.Locs(end)== TroughLevel_mu.Peak.Locs(end)
       %the last element is a peak
       last_peak_index=length(TroughLevel_mu.Drift.Locs);
       TroughLevel_mu.Drift.Values(last_peak_index)=(Peaks_and_Troughs_Values_Sorted(last_peak_index)+mu_noch.Trough.Ref)/2;
    elseif  TroughLevel_mu.Drift.Locs(end)==TroughLevel_mu.Trough.Locs(end)
       %the last element is a trough
       last_trough_index=length(TroughLevel_mu.Drift.Locs);      
       TroughLevel_mu.Drift.Values(last_trough_index)= (Peaks_and_Troughs_Values_Sorted(last_trough_index-1)+ mu_noch.Trough.Ref)/2  ;
    else
       %the last element is not the last peak or the last trough
       disp('Errror: laset element of drift is wrong ');        
    end

     %since the last element is already computed :
    for dd=1:length(TroughLevel_mu.Drift.Locs)-1
          
           if rem(dd,2)==0 %check the index if si even or odd
                %index is even, the the element indicize is a trough
                TroughLevel_mu.Drift.Values(dd)= (   (Peaks_and_Troughs_Values_Sorted(dd-1)+ mu_noch.Trough.Ref)/2  + (Peaks_and_Troughs_Values_Sorted(dd+1)+mu_noch.Trough.Ref)/2    ) / 2 ;
           else
                %index is odd, then the element indicized is a peak
                TroughLevel_mu.Drift.Values(dd)=(Peaks_and_Troughs_Values_Sorted(dd)+mu_noch.Trough.Ref)/2;
           end       
    end
    
elseif TroughLevel_mu.Drift.Locs(1) == TroughLevel_mu.Trough.Locs(1)
    
    % the 1st element is a trough. The troughs happen before peaks
    % Thus the troughs are indicized by odd indeces
    % while the peaks are indicized by even indeces
    
    %the 1st element is a trough and then a peak follows
    TroughLevel_mu.Drift.Values(1)=(Peaks_and_Troughs_Values_Sorted(1+1)+ mu_noch.Trough.Ref) / 2  ;

    %check the last element
    if TroughLevel_mu.Drift.Locs(end)== TroughLevel_mu.Peak.Locs(end)
        %the last element is a peak
        last_peak_index=length(TroughLevel_mu.Drift.Locs);
        TroughLevel_mu.Drift.Values(last_peak_index)=(Peaks_and_Troughs_Values_Sorted(last_peak_index)+mu_noch.Trough.Ref)/2;
     elseif  TroughLevel_mu.Drift.Locs(end)== TroughLevel_mu.Trough.Locs(end)
         %the last element is a trough
         last_trough_index=length(TroughLevel_mu.Drift.Locs);
         TroughLevel_mu.Drift.Values(last_trough_index)= (Peaks_and_Troughs_Values_Sorted(last_trough_index-1)+ mu_noch.Trough.Ref)/2  ;
    else
         %the last element is not the last peak or the first trough
         disp('Errror: laset element of drift is wrong ');        
    end
    
    %since the firs and the last element are already computed :
    for dd=2:length(TroughLevel_mu.Drift.Locs)-1
        

        if rem(dd,2)==0 %check the index if si even or odd
            %index is even, then the element indicized is a peak
            TroughLevel_mu.Drift.Values(dd)= (Peaks_and_Troughs_Values_Sorted(dd) + mu_noch.Trough.Ref)/2 ;
        else
            %index is odd, then the element indicized is a trough
            TroughLevel_mu.Drift.Values(dd)= (   (Peaks_and_Troughs_Values_Sorted(dd-1)+ mu_noch.Trough.Ref)/2  + (Peaks_and_Troughs_Values_Sorted(dd+1)+mu_noch.Trough.Ref)/2    ) / 2 ;
        end
    end
        
else
    %the first element is not the first peak or the first trough
    disp('Errror: 1st element of drift is wrong');

end


%% compute drift new DriftStair:
%considering the first near peak and trough, keep the value unitl we find
%another peak and trough. This value is the sum of peak and trugh, all
%divided by 2

% %inizialize DriftStair
% DriftStair=zeros(size(mu_noch.mu))+mu_noch.Trough.Ref ;


% TroughLevel_mu.Drift.Locs contain the position of peaks and troughs
% sorted in ascending order
[Peaks_and_Troughs_Locs_Sorted,indeces_sorted]=sort( [TroughLevel_mu.Peak.Locs   TroughLevel_mu.Trough.Locs]);

% Peaks_and_Troughs_Values_Sorted contain the values of peaks and troughs
% sorted in ascending order of position
Peaks_and_Troughs_Values = [TroughLevel_mu.Peak.Values   TroughLevel_mu.Trough.Values];
Peaks_and_Troughs_Values_Sorted = Peaks_and_Troughs_Values(indeces_sorted) ;
        
% %plot  Peaks_and_Troughs_Values_Sorted
% figure(77);   
% Peaks_and_Troughs_plot=plot(Peaks_and_Troughs_Locs_Sorted,Peaks_and_Troughs_Values_Sorted,'o');
% set(Peaks_and_Troughs_plot,'LineWidth',2); set(gca,'FontSize',16);

% we can have 2 cases:
%                     >> mu starts with a peak:
%                       Then the first element is a peak
%                       The peaks happen before the troughs;
%                       thus the peaks are indicized by odd indeces,
%                       while the troughs are indicized by even indeces.
%                       Moreover, at the last iter we check if:
%                       - the last elements is a peak, then mu ends with a peak                           
%                       - the last element is a trough, the mu ends with a trough
%                                         
%                     >> mu starts with a trough:
%                       Then the first element is a trough
%                       The troughs happen before the peaks;
%                       thus the troughs are indicized by odd indeces,
%                       while the peaks are indicized by even indeces.
%                       Moreover, at the last iter we check if:
%                       - the last elements is a peak, then mu ends with a peak                            
%                       - the last element is a trough, the mu ends with a trough

    
    %The 1st element could be a peak or a trough.
    %The DriftStair will assume, from its starts (1) to the 1st element
    %index, the 1st element value divided by 2 !
    
    DriftStair( 1 : Peaks_and_Troughs_Locs_Sorted(1) ) = ( Peaks_and_Troughs_Values_Sorted(1) + mu_noch.Trough.Ref ) / 2 ;
    
     %since the first element is already computed and the last element will be computed apart:
    for dd=2:length(Peaks_and_Troughs_Locs_Sorted)
        win = ( Peaks_and_Troughs_Locs_Sorted(dd-1) : Peaks_and_Troughs_Locs_Sorted(dd) );  
        win_value = ( Peaks_and_Troughs_Values_Sorted(dd) + Peaks_and_Troughs_Values_Sorted(dd-1) ) / 2 ;  
        DriftStair(win)=win_value;           
    end
    
        
    %The last element could be a peak or a trough.
    %The DriftStair will assume, from last element index to its end, the
    %last element value divided by 2!
    last_element_loc=Peaks_and_Troughs_Locs_Sorted(end);
    DriftStair( last_element_loc : length(mu_noch.mu) ) = ( Peaks_and_Troughs_Values_Sorted(end) + mu_noch.Trough.Ref ) / 2 ;
    


%% assign the output
% % % % DriftStair is the 1st output !
% % % TroughLevel_mu_Peak_Values=TroughLevel_mu.Peak.Values;
% % % TroughLevel_mu_Peak_Locs=TroughLevel_mu.Peak.Locs;
% % % TroughLevel_mu_Trough_Values=TroughLevel_mu.Trough.Values;
% % % TroughLevel_mu_Trough_Locs=TroughLevel_mu.Trough.Locs;
% % % TroughLevel_mu_Drift_Values=TroughLevel_mu.Drift.Locs;
% % % TroughLevel_mu_Drift_Locs=TroughLevel_mu.Drift.Values;
Drift_out=DriftStair;



%% se passo come input -mu devo invertire l'output e i picchi e le valli calcolati
% % % Inoltre i picchi diventano le valli
% % mu_noch.mu=-mu_noch.mu; %per ottenere mu originale
% % mu_noch.Trough.Values=-mu_noch.Trough.Values; %per ottenere lle valli di mu
% % mu_noch.Peak.Values=-mu_noch.Peak.Values; %per ottenere i picchi di mu
% % TroughLevel_mu.TroughShift=-TroughLevel_mu.TroughShift;
% % TroughLevel_mu.Trough.Values=-TroughLevel_mu.Trough.Values;
% % TroughLevel_mu.PeakShift=-TroughLevel_mu.PeakShift;
% % TroughLevel_mu.Peak.Values=-TroughLevel_mu.Peak.Values;
% % TroughLevel_mu.Drift.Values=-TroughLevel_mu.Drift.Values;



%% plotto i risultati in seconds /128
% % % % figure(91); 
% % %     
% % % %     x=1:size(mu_noch.mu,2); %abscissa
% % % %     
% % % %     mu_noch_mu_plot=plot(x/128,mu_noch.mu,'k'); set(mu_noch_mu_plot,'LineWidth',2); set(gca,'FontSize',16);
% % % %     
% % % %     hold on; grid on;
% % % % 
% % % %     mu_noch_Trough_plot=plot(mu_noch.Trough.Locs/128,mu_noch.Trough.Values,'vm');
% % % %     set(mu_noch_Trough_plot,'LineWidth',2); set(gca,'FontSize',16);
% % % %     
% % % %     hold on; grid on;
% % % %    
% % % %     mu_noch_Peak_plot=plot(mu_noch.Peak.Locs/128,mu_noch.Peak.Values,'c^');
% % % %     set(mu_noch_Peak_plot,'LineWidth',2); set(gca,'FontSize',16);
% % % % 
% % % %     hold on; grid on;
    
% % % figure(91); 
% % % 
% % %     x=1:size(mu_noch.mu,2); %abscissa
% % %     
% % %     TroughLevel_mu_Trough_plot=plot(TroughLevel_mu.Trough.Locs/128,TroughLevel_mu.Trough.Values,'vr');
% % %     set(TroughLevel_mu_Trough_plot,'LineWidth',2); set(gca,'FontSize',16);
% % % 
% % %     hold on; grid on;
% % %        
% % %     TroughLevel_mu_Peak_plot=plot(TroughLevel_mu.Peak.Locs/128,TroughLevel_mu.Peak.Values,'b^');
% % %     set( TroughLevel_mu_Peak_plot,'LineWidth',2); set(gca,'FontSize',16);
% % %     
% % %     hold on; grid on;
% % %     
% % %     TroughLevel_mu_Drift_plot=plot(TroughLevel_mu.Drift.Locs/128,TroughLevel_mu.Drift.Values,'--og');
% % %     set( TroughLevel_mu_Drift_plot,'LineWidth',2); set(gca,'FontSize',16);
% % % 
% % %     hold on; grid on;
% % %     
% % %     DriftStair_plot=plot(x/128,DriftStair,'--xk');
% % %     set( DriftStair_plot,'LineWidth',2); set(gca,'FontSize',16);
% % %     
% % %     xlabel('seconds');
% % %     legend('TroughLevel mu Trough','TroughLevel mu Peak','Drift','DriftStair');
% % %     title(['TroughLevel mu Trough, TroughLevel mu Peak, Drift, DriftStair', '@ ', channel.name{noch}])
% % %     
    
    
% % % %     legend('mu nochannel', 'mu noch Trough','mu noch Peak', 'TroughLevel mu Trough','TroughLevel mu Peak','Drift','DriftStair');
% % % %     title(['mu nochannel, mu noch Trough, mu noch Peak, TroughLevel mu Trough, TroughLevel mu Peak, Drift, DriftStair', '@ ', channel.name{noch}])

end

