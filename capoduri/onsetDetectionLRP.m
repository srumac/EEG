yk=FC3tutti;
W=16;


X=ones(size(yk,1),1);
X=[X (1:size(yk,1))'];
yk=(yk');
yk_inverted=yk(end:-1:1,:);


%%Smoothing

yk_tilde=(smooth(yk,W,'moving'))';
yk_tildeinv=(smooth(yk_inverted,W,'moving'))';
yk_tot=(yk_tilde+yk_tildeinv(end:-1:1))'/2;


% yk=abs(yk); %Rectification
Wstar=1;
Wend=8;

% yk_tot=(abs(yk_tot));%.^0.5;
pend=zeros(size(yk));
yk_tot=yk_tot.^2;
for Wstar=1:1:size(yk,2)
    %Linear regression
    linreg=X(Wstar:Wend,:)\double(yk_tot(Wstar:Wend));
    pend(Wstar)= linreg(2);
    
    if Wend<size(yk,2)
        Wend=Wend+1;
    end
    
end

mu0=mean(mean(pend));
sigma0=mean(std(pend));

%% Normalization
gk=(1/sigma0*(pend-mu0)); %

perce=0.9;
h=quantile(gk,perce);

ta=find(gk(1:end) >=h,1 ,'first');


xpoints=0:1:length(FC3tutti)-1;
xseconds=(xpoints/128)-4;
figure,
l=plot(xseconds,-FC3tutti);
set(l,'linewidth',2);
hold on;
l=stem(ta/128 -4,-FC3tutti(ta),'or');
set(l,'linewidth',2);
hold off
onset = ta/128 -4

