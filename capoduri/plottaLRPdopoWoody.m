close all
clc
[LRPwoody,epochssaved,epochssavedlag,epochssavedindices,epochsfolded,epochsfoldedlag,epochsfoldedindices] = woody( FC3tutti_filtered,512,90);
figure(7777);h55=plot(xseconds,LRP);set(h55,'LineWidth',2);set(gca,'FontSize',16); hold on; grid on; ylim([-30,30]);
figure(7777);h5551=plot(xseconds,LRPwoody);set(h5551,'LineWidth',2);set(gca,'FontSize',16);
title(['Alice Camponovo SoloMano, interval 512, prctile 90, epoche scartate ',num2str(size(epochsfolded,2))]);legend('LRP','LRPwoody');
for ii=1:size(FC3tutti_filtered,1)
    close all
    figure(ii);
    plot(xseconds,FC3tutti_filtered(ii,:));
end