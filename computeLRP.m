% Retrieve the index of the FC3 channel
FC3nochan = strmatch('Fc3',char(EEG.chanlocs.labels));
% Average
FC3 = EEG.data(FC3nochan,:,:);
FC3tutti = reshape(FC3,size(FC3,2),size(FC3,3)); %Eliminates the 1x
FC3tot = mean(FC3tutti,2);
[ LRPwoody, epochssaved,epochssavedlag,epochssavedindices,epochsfolded,epochsfoldedlag,epochsfoldedindices]= woody(FC3tutti');
% FC3woody = woody (FC3tutti');
%% Plot
figure,title('Readiness Potential');
xpoints = 0:1:length(FC3tutti)-1;
xseconds = (xpoints/EEG.srate)-4;
h1 = plot(xseconds,-FC3tot,'b');   
hold on;
h2 = plot(xseconds,-LRPwoody,'r');
set(h1,'LineWidth',2);
set(h2,'LineWidth',2);
set(gca,'FontSize',16);
legend('Mean','Woody');
plot(xseconds,-epochssaved(:,1),'k');