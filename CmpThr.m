% Computing Threshold using percentiles
ta;
% ta=[2728 2647 2593 1063 1206 1325 1680 1012 2790 1088 2731 1100 2952 ...
%     423 2536 2728 2551 2445 2582 1734 2191 1969 1770 2424 2827 3075 ...
%     1771 2214 1302 1746 2486 1325 2380 833 2520 1288 1972 2648 1399 1144];
%   for ii=1:1:size(onsetsample,1)
%     onset(ii)=emgonset(ii)-(epoch_duration*(ii-1));
%  
%   end
%   onsetsample=onset*512;
% figure,hist(slope(1:10,:),10);
  datat=[];
  onsetsample=ta;
  for ii=1:1:size(onsetsample,2)
   values(ii)=slope(ii,onsetsample(ii));
%    P = ( length( data(data<valve ) )+0.5)/length(data)*100
    data=slope(ii,:);
    value=values(ii);
    P(ii) = ( length( data(data<value ) )+0.5)/length(data);
   datat=[datat data];
%    P(ii) = ( length( slope(ii,:)(slope(ii,:)<values(ii) ) )+0.5)/size(slope,2)*100
  end
%  value=mean(values)
%  P = ( length( datat(datat<value ) )+0.5)/length(datat)*100
perce=median(P)
% perce=99
% perce=0.965
threshold=quantile(data,perce)
 
%  sloperes=reshape(slope,1,size(slope,1)*size(slope,2));
%  figure,plot(sloperes)
 