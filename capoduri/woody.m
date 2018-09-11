function [ LRPwoody, epochssaved,epochssavedlag,epochssavedindices,epochsfolded,epochsfoldedlag,epochsfoldedindices] ...
         = woody( FC3tutti_filtered,interval,perctilevalue,Nforced )
%% PROCEDURA DI WOODY
%INPUT:  >>    'FC3tutti_filtered' = matrice delle epoche filtrata. Ogni
%               riga contiene un epoca. Obbligatoria!!!
%        >>    'interval' =  intervallo (n° campioni) in cui cercare il massimo
%              della cross-correlazione. Opzionale, se non settato viene impostato di
%              default a 'interval=512'.
%        >>    'perctilevalue' = percentile per il calcolo del perctilewoody utilizzato al 1°controllo
%              (1°controllo = ad ogni iter, se il il 'prctile95', della cross-correlazione
%              tra la stima e l'epoca, è inferiore a 'perctilewoody' calcolato con
%              la funzione 'prctilewoodyfun', scarta l'epoco e non aggiorna la
%              stima). Opzionale, se non settato viene impostato di default
%              a 'perctilevalue=95'.
%        >>    'Nforced' = Forza quante epoche prendere indipendentemente
%               dai controlli. Opzionale, se non settato prendo tutte le
%               epoche!

%OUTPUT: >>    'LRPwoody' = LRP dopo aver applicato la procedura di woody
%        >>    'epochssaved' =  contiene tutte le epoche selezionate per il calcolo
%               di LRPwoody (è un vettore che si aggiorna ad ogni iter, prima dello shift
%               per allineare epoca corrente e stima, e aggiornare la stima !)
%               All'inizio epochsstored contiene la epoca che si  correla meglio 
%               con tutte le altre.
%        >>     'epochssavedlag' = memorizza ad ogni iter il lag, i.e lo shift richiesto,
%               per le epoche selezionate, prima di operare lo shift e allinearle !
%               %Inizializzato con 0 perchè all'inizio della procedura si ha solo un
%               epoca.
%        >>     'epochssavedindices' = contiene gli indici delle posizioni temporali
%               originali delle epoche selezionate per il calcol di LRPwoody
%        >>    'epochsfolded' = contiene tutte le epoche scarate e non
%               coinvolte nel calcolo di LRPwoody (è un vettore che si aggiorna 
%               ad ogni iter e memorizza l'epoche sia scartate al
%               1°controllo che al 2°controllo. 2°controllo = ad ogni iter,
%               se nessun massimo locale ma solo l'estremo inferiore sx o
%               l'estremo superiore dx della cross-correlazione (calcolata
%               tra la stima e l'epoca) supera il 'prctile95' della
%               medesima, allora l'epoca viene scarta !
%         >>    'epochsfoldedlag' = memorizza ad ogni iter il lag corrispondente alle epoche scartate.
%               Per le epoche scartate al 1°controllo tale lag corrisponde al max 
%               brutale (assoluto) della cross-correlazione, calcolata tra la stima e l'epoca corrente,
%               Per le epoche scartate al 2°controllo tale lag corrisponde all'estremo
%               inferiore sx o all'estremo superiode dx della
%               cross-correlazione, calcolata tra stima e epoca corrente,
%               che supera il 'prctile95' calcolato!
%         >>    'epochfoldedindices' = contiene gli indici delle posizioni temporali
%               originali delle epoche scartate e non coinvolte nel calcolo di LRPwoody

% Author:  Marco Capoduri(marco.capoduri1@gmail.com, Politecnico di Torino, 
%          Torino, Italy, 2017)
% Copyright (C) 2017 Marco Capoduri
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


%controllo sui parametri di input !
if  nargin<1
     error('Not enough parameters');
     return
elseif nargin==1 %imposto solo 'FC3tutti_filtered'
    interval=512; % default
    perctilevalue=95;  % default
   [Nepochs,Nsamples]=size(FC3tutti_filtered); % FC3tutti_filtered = 40x4096
elseif nargin==2 %imposto solo 'FC3tutti_filtered' e 'interval'
    perctilevalue=95;  % default
   [Nepochs,Nsamples]=size(FC3tutti_filtered); % FC3tutti_filtered = 40x4096
elseif nargin==3 %imposto solo 'FC3tutti_filtered' , 'interval' e 'perctilevalue'
    [Nepochs,Nsamples]=size(FC3tutti_filtered); % FC3tutti_filtered = 40x4096
elseif nargin==4 % imposto tutto, quindi la procedura di woody sarà eseguita per le 
    % migliori (i.e che hanno correlazione più alta) Nforced epoche
    [Nepochs,Nsamples]=size(FC3tutti_filtered); % FC3tutti_filtered = 40x4096
    % controllo sul numero di epoche selezionate
    if Nforced>Nepochs 
        error('Too many epochs selected');
        return
    elseif Nforced==0
         error('Not enough epochs selected');
         return
    else
        Nepochs=Nforced;
    end
else %se nargin > 5
    error('Too many parameters');
    return
end      

CorMatrix=corrcoef(FC3tutti_filtered'); %Calcolo matrice di correlazione
MeanCorMatrix=mean(CorMatrix); %Calcolo la media per ogni riga della matrice di correlazione
[CorVectorValue,CorVectorIndex]=sort(MeanCorMatrix,'descend'); %Ordino
%le epoche dalla epoca con media di correlazione più alta alla più bassa
FC3tuttiFilteredSort=FC3tutti_filtered(CorVectorIndex,:)'; %matrice 1°step 

%calcolo  perctilewoody per il 1°controllo: ad ogni iter, se il il 'prctile95', della cross-correlazione
%tra la stima e l'epoca, è inferiore a 'perctilewoody' calcolato con
%la funzione 'prctilewoodyfun', scarta l'epoco e non aggiorna la stima.
[perctilewoody] = prctilewoodyfun( FC3tutti_filtered,interval,perctilevalue );% calcolo 95esimo
%percentile di tutte le cross-correlazioni della procedura di woody, senza
%scartae epoche, che servirà come riferimento per il 1°controllo ne calcolo
%dello shift ottimo: scarto le epoche per cui il 95esimo percentile della
%cross-correlazione con la stima,all'iterazione attuale, perctile95 è 
%inferiore a perctile95woody calcolato con la suddette funzione

%inizializzo la matrice delle epoche MM
MM=FC3tutti_filtered';
%calcolato la stima, e serve per memorizzare le epoche ad ogni iter e

epochsstored= FC3tuttiFilteredSort(:,1); %epocheselected 
% è un vettore che si aggiorna ad ogni iter, dopo aver calcolare 
%poi la stima ! All'inizio epochsstored contiene la epoca che si 
%correla meglio con tutte le altre

epochssaved=FC3tuttiFilteredSort(:,1); %contiene tutte le epoche selezionate
%per il calcolo %di LRPwoody (è un vettore che si aggiorna ad ogni iter, 
%prima dello shift % per allineare epoca corrente e stima, 
%e aggiornare la stima ! ) 
% All'inizio epochsstored contiene la epoca che si  correla meglio 
%con tutte le altre

epochssavedindices = [];%contiene gli indici delle posizioni temporali
%originali delle epoche selezionate per il calcol di LRPwoody
epochssavedlag =0; % memorizza ad ogni iter il lag, i.e lo shift richiesto,
%per le epoche selezionate, prima di operare lo shift e allinearle !
%Inizializzato con 0 perchè per all'inizio della procedura si ha solo un
%epoca.

epochsfolded1check=[]; % epochsfolded1check contiene le epoche scartate al 
%1°controllo perchè il 95esimo percentile della cross-correlazione all'iter
%attule perctile95 è inferiore al 95esimo percentile perctile95woody
%calcolato con la funzione prctile95woodyfun
epochsfolded1checkiter=[]; %epochsfolded1checkiter memoriza l'iterazione 
%nella quale  le epoche sono scartate al 1° controllo

epochsfolded2check=[]; %epochsfolded contiene le epoche scartate al 
%2°controllo scartate perchè %l'allineamento con la stima richiede 
% uno shift pari a +interval o -interval (i.e il massimo della 
% correlazione superiore al 95esimo percentile risulterebbe l'estremo sx o
% dx della cross-correlazione)
epochsfolded2checkiter=[]; %epochsfolded2checkiter memoriza l'iterazione 
%nella quale le epoche sono scartate al 2° controllo

epochsfolded=[]; %contiene tutte le epoche scartate
epochsfoldedlag =[]; % memorizza ad ogni iter il lag corrispondente alle epoche scartate.
%Per le epoche scartate al 1°controllo tale lag corrisponde al max 
%brutale (assoluto) della cross-correlazione, calcolata tra la stima e l'epoca corrente,
%Per le epoche scartate al 2°controllo tale lag corrisponde all'estremo
%inferiore sx o all'estremo superiode dx della cross-correlazione,
%calcolata tra stima e epoca corrente, che supera il 'prctile95' calcolato!
epochsfoldedindices=[]; %contiene gli indici delle posizioni temporali
%originali delle epoche scartate e non coinvolte nel calcolo di LRPwoody

%Implemento procedura di Woody !
for ee=1:Nepochs-1
    %Ad ogni iter calcolo la matrice di correlazione
    CorMatrixIter=corrcoef(MM);
    %Ad ogni iter ordino le epoche dalla epoca con media di correlazione 
    %più alta alla più bassa
    MeanCorMatrixIter=mean(CorMatrixIter);
    [CorVectorIterValue,CorVectorIterIndex]=sort(MeanCorMatrixIter,'descend'); 
    MM=MM(:,CorVectorIterIndex); %matrice 1°step 
    if ee==1 %alla prima iterazione
        %la stima è l'epoca più correlata
        stima=MM(:,1);
        %la seconda epoca è la sconda epoca correlata
        epoca2=MM(:,2);    
        %Questo serve per calcolare la stima alla 1°iter tra le 2 epoche
        %più correlate (la stima è calcolata tra: le epoche precenti e
        %l'epoca attuale shiftata e allineata con la stima !
    else %per tutte le iter successive alla prima 
        %la seconda epoca è sempre il 1°elemento della matrice delle
        %epoche, ricalcolata ad ogni iter eliminando le epoca utilizzata
        %per calcolare la stima, ordinata dalla epoca con media di
        %correlazione più alta alla più bassa.
        epoca2=MM(:,1);    
    end
    
    %ad ogni iter calcolo la cross-correlazione tra la epoca più correlata della matrice
    %delle epoche MM con la stima: r è la correlazione e lag è in termini
    %di campioni !
    [r,lags] = xcorr(epoca2,stima,interval,'coeff');

    %Calcolo lo shift ottimo, cercando i massimi locali della
    %cross-correlazione, cercando quelli maggiori del 95esimo percentile
    %e tra questi seleziono quello che ha il lag minore (in valore assoluto)!
    %Tale lag (con segno) rappresenterà lo shift
    %Nel vettore dei massimi locali inserisco anche gli etsremi sx
    %(inferiore) e dx (superiore) della cross-correlazione!
    %Se il 95esimo percentile calcolato perctile95 è inferiore al 95esimo
    %percentile perctile95woody calcolato con la funzione
    %prctile95woodyfun, l'epoca viene scartata e non entra nel calcolo
    %dellla stima!
    %Se il massimo della cross-correlazione coincide con l'estremo
    %inferiore (sx) o superiore (dx) della medesima, i.e lo shift
    %richiesto pe l'allineamento risulta pari a -interval o +interval,
    %allora l'epoca in gioco non entra nel calcolo della stima e viene
    %scartata!
    %epochsfolded è un vettore che memorizza le epoche scartate
    %epochsfoldediter è un vettore che memorizza le iter in cui sono
    %scartate le epoche
    %una volta calcolalto lo shift ottimo, opero lo shift e aggiorno il
    %valore della stima
    perctile95=prctile(r,95); %calocolo il 95esimo percentile
    if perctile95<perctilewoody %1st check!
        epochsfolded1checkiter=[epochsfolded1checkiter ee]; % salvo epoca scartata
        epochsfolded1check=[epochsfolded1check epoca2]; %salvo iter
        epochsfolded=[epochsfolded epoca2];
        [maxvalue,maxindex]=max(r); %calcolo il massimo brutale (assoluto) della cross-correlazione
        maxlag = lags(maxindex); %calcolo il lag corrispondente al suddetto massimo
        epochsfoldedlag = [epochsfoldedlag maxlag];
        %il valore della stima non viene aggiornato e lepoca viene scartata
    else %perctile95>=perctile95woody
        [localmaxvalues,localmaxindeces] = findpeaks(double(r)); %faccio cast, vuole double!
        localmaxvalues=[r(1) ; localmaxvalues; r(length(r))] ;%aggiungo valori degli estremi sx e dx
        localmaxindeces=[1 ; localmaxindeces ; length(r)]; %aggiungo indici degli estremi sx e dx
        %trovo gli indici dei massimi locali maggiori del 95esimo percentile
        localmaxup95indeces=localmaxindeces(find(localmaxvalues>=perctile95));
        %trovo i lags dei massimi locali maggiori del 95esimo percetile
        localmaxup95lags=lags(localmaxup95indeces); 
        %di tutti i max locali maggiori del 95esimi percentile, cerco e trovo
        %quello con minore lag (in valore assoluto)! 
        %tale lag sarà lo shift
        [shiftabsvalue,shiftindex]=min(abs(localmaxup95lags));
        shiftvalue=localmaxup95lags(shiftindex);
        if (shiftvalue==-interval) || (shiftvalue==+interval) %2nd check !
            epochsfolded2checkiter=[epochsfolded2checkiter ee]; % salvo epoca scartata
            epochsfolded2check=[epochsfolded2check epoca2]; %salvo iter
            epochsfolded=[epochsfolded epoca2];
            epochsfoldedlag = [epochsfoldedlag shift];
            %il valore della stima non viene aggiornato e lepoca viene scartata
        else %-interval<shiftvalue<+interval
            shift=shiftvalue;
            %opero lo shift
            if shift==0 %se lo shift è 0 allora le epoche sono già allineate
            elseif shift>0 %altrimenti se lo shift è positivo, ovvero l'epoca2 è in ritardo rispetto la stima
                    %shifto verso sx e mantengo a dx il valore dell'ulimo campione di epoca2
                    epoca2shifted=[epoca2(abs(shift)+1:Nsamples) ; ones(abs(shift),1).*epoca2(Nsamples)];
            else %altrimenti se lo shift è positivo, ovvero l'epoca2 è in anticipo rispetto la stima
                    %shifto verso dx e mantengo a sx il valore del primo campione di epoca2
                    epoca2shifted=[ones(abs(shift),1).*epoca2(1) ; epoca2(1:Nsamples-abs(shift))  ];
            end
            %aggiorno il valore della stima, calcoland la media tra le epoche
            %precedentemente selezionata per la stima e la epoca attuale allineata con la stima
            stima=mean([epochsstored epoca2shifted],2); %size(epochsdeleted)
            %salvo l'epoca attuale allineata con la stima e coinvolta nel calcolo della nuova stima
            epochsstored=[epochsstored epoca2shifted]; 
            epochssaved=[epochssaved epoca2];
            epochssavedlag = [epochssavedlag shift];
        end
    end

    %aggiorno la matrice delle epoche, eliminando quella/e coinvolte nel
    %calcolo della stima!
    if ee==1 %alla prima iterazione
        %Le epoche coinvolte nel calcolo della stima sono le prime due
        %epoche più correlate. Pertanto tolgo tali epoche coinvolte nel
        %calcolo della stima dalla matrice dele epoche
         MMnew=[MM(:,3:end)]; %sizeMM=size(MM)
    else %alle iterazioni successive alla prima
        %Solo la prima epoca della matrice delle epoche ordinata è
        %coinvolta nel calcolo della stima. Pertanto tolgo tale epoca.
        MMnew=[MM(:,2:end)]; %sizeMM=size(MM) %butto sempre la prima riga
    end
    %Aggiorno la matrice delle epoche, avendo tolto le epoche coinvolte nel
    %calcolo della stima
    MM=MMnew; 
end
LRPwoody=stima; %Il risultato alla fine della procedura è la stima!

%cerco indice originale delle epoche scartate e delle epoche selezionate
%per il calcolo di LRPwoody per verificare la presenza o meno di una
%dipendenza temporale
epochsoriginal=FC3tutti_filtered';

%cerco indice originale delle epoche scartate 
for ff=1:size(epochsfolded,2)
    for gg=1:size(epochsoriginal,2)
        if epochsoriginal(:,gg)==epochsfolded(:,ff)
            epochsfoldedindices=[epochsfoldedindices gg]; %OUTPUT !
        end
    end
end

%cerco indice originale delle epoche selezionate per il calcolo di LRPwoody
for ss=1:size(epochssaved,2)
    for gg=1:size(epochsoriginal,2)
        if epochsoriginal(:,gg)==epochssaved(:,ss)
            epochssavedindices=[epochssavedindices gg]; %OUTPUT !
        end
    end
end

end

