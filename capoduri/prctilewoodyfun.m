function [ perctilewoody ] = prctilewoodyfun( FC3tutti_filtered,interval,perctilevalue)
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

%% PROCEDURA DI WOODY per il CALCOLO DEL 95esimo PERCENTILE 
%perctile95woody viene utilizzato per fare un primo controllo, durante il
%calcolo dello shift ottimo, nella procedura di woody!
%interval è  l'intervallo (n° campioni) in cui cercare il massimo della
%cross-correlazione
Nepochs=size(FC3tutti_filtered,1);
Nsamples=size(FC3tutti_filtered,2);
%perctile95woody è il massimo del 95esimo percentile di tutte le
%cross-correlazioni (senza scartare epoche)
%Calcolo matrice di correlazione
CorMatrix=corrcoef(FC3tutti_filtered');
%Caloclo la media per ogni riga della matrice di correlazione
MeanCorMatrix=mean(CorMatrix);
%Ordino le epoche dalla epoca con media di correlazione più alta alla più
%bassa
[CorVectorValue,CorVectorIndex]=sort(MeanCorMatrix,'descend'); 
FC3tuttiFilteredSort=FC3tutti_filtered(CorVectorIndex,:)'; %matrice 1°step 



%inizializzo la matrice delle epoche MM
MM=FC3tutti_filtered';
%calcolato la stima, e serve per memorizzare le epoche ad ogni iter e

epochsstored= FC3tuttiFilteredSort(:,1); %epochsstored 
% è un vettore che si aggiorna ad ogni iter, dopo aver calcolare 
%poi la stima !
%All'inizio epochsstored contiene la epoca che si correla meglio con
%tutte le altre
rr=[]; %"vettore" delle cross-correlazioni, si aggiorna ad ogni ier
%"vettore" perchè in realtà le cross-correlazioni vengono messe una accanto
%all'altra in modo da poter calcolare il 95esimo percentile di TUTTO!
lagslags=[]; %vettoore dei lag delle cross-corrlazioni,  si aggiorna ad ogni ier

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
    %delle epoche MM con la stima
    [r,lags] = xcorr(epoca2,stima,interval,'coeff');
    %ad ogni iter salvo le cross-correlazioni e corrispondenti lags nei
    %seguenti vettori
    rr=[rr; r]; %aggiorno "vettore" dei valori delle cross-correlazioni
    %"vettore" perchè le cross-correlazioni vengono messe una accanto
    %all'altra in modo da poter calcolare il 95esimo percentile di TUTTO!
    lagslags=[lagslags lags']; %aggiorno vettore dei lags cross-correlazioni


    %Calcolo lo shift ottimo, cercando i massimi locali della
    %cross-correlazione, cercando quelli maggiori del 95esimo percentile
    %e tra questi seleziono quello che ha il lag minore (in valore assoluto)!
    %Tale lag (con segno) rappresenterà lo shift
    %Nel vettore dei massimi locali inserisco anche gli etsremi sx
    %(inferiore) e dx (superiore) della cross-correlazione!
    %Una volta calcolalto lo shift ottimo, opero lo shift e aggiorno il
    %valore della stima
    perctile95=prctile(r,95); %calocolo il 95esimo percentile
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
    shift=shiftvalue;
    %opero lo shift
    if shift==0 %se lo shift è 0 allora le epoche sono già allineate
        epoca2shifted = [];
    elseif shift>0 %altrimenti se lo shift è positivo, ovvero l'epoca2 è in ritardo rispetto la stima
    %shifto verso sx e mantengo a dx il valore dell'ulimo campione di epoca2
        epoca2shifted=[epoca2(abs(shift)+1:Nsamples) ; ones(abs(shift),1).*epoca2(Nsamples)];
    else%altrimenti se lo shift è positivo, ovvero l'epoca2 è in anticipo rispetto la stima
       %shifto verso dx e mantengo a sx il valore del primo campione di epoca2
       epoca2shifted=[ones(abs(shift),1).*epoca2(1) ; epoca2(1:Nsamples-abs(shift))  ];
    end
    %aggiorno il valore della stima, calcoland la media tra le epoche
    %precedentemente selezionata per la stima e la epoca attuale allineata con la stima
    stima=mean([epochsstored epoca2shifted],2); %size(epochsdeleted)
    %salvo l'epoca attuale allineata con la stima e coinvolta nel calcolo della nuova stima
    epochsstored=[epochsstored epoca2shifted]; %size(epochsdeleted) 
        
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
%     sizeMMnew=size(MMnew)
    %Aggiorno la matrice delle epoche, avendo tolto le epoche coinvolte nel
    %calcolo della stima
    MM=MMnew; 
end
%Il risultato alla fine della procedura è la stima!
perctilewoody=prctile(rr,perctilevalue);% calcolo il percentile di TUTTO!
%rr contiene tutte le cross-correlazioni, una accanto all'altra!

end

