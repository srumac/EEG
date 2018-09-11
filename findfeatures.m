function [Mdl,features, class] = findfeatures(EEG, N)
% N = number of training samples for LDA
nepochs = size(EEG.matched,2);

% select N random epochs
rndindex = randperm(nepochs,N);
negative_f = zeros(5,N);
positive_f = zeros(5,N);
negative_ff = zeros(5,N);
for i = 1:N
    epoch = EEG.matched(:,rndindex(i));
    negative_f(:,i) = [epoch(64+128) epoch(128+128) epoch(192+128) epoch(256+128) epoch(320+128)];
    negative_ff(:,i) = [epoch(64) epoch(128) epoch(192) epoch(256) epoch(320)];
    positive_f(:,i) = [epoch(256) epoch(320) epoch(384) epoch(448) epoch(512)];
    positive_ff(:,i) = [epoch(256-32) epoch(320-32) epoch(384-32) epoch(448-32) epoch(512-32)];
end
train_features = [negative_f negative_ff positive_f positive_ff]';
train_class = [zeros(1,N*2) ones(1,N*2)]';
EEG.matched(:,rndindex) = [];

%% Train the LDA
Mdl = fitcdiscr(train_features,train_class,'DiscrimType', 'Quadratic');
%% Extract remaining features
remain_epochnum = size(EEG.matched,2);
negative_f2 = zeros(5,remain_epochnum);

negative_ff2 = zeros(5,remain_epochnum);
positive_f2 = zeros(5,remain_epochnum);
for k = 1:remain_epochnum
    epoch = EEG.matched(:,k);
    negative_f2(:,k) = [epoch(64+128) epoch(128+128) epoch(192+128) epoch(256+128) epoch(320+128)];
    negative_ff2(:,k) = [epoch(64) epoch(128) epoch(192) epoch(256) epoch(320)];
    positive_f2(:,k) = [epoch(256) epoch(320) epoch(384) epoch(448) epoch(512)];
    positive_ff2(:,k) = [epoch(256-32) epoch(320-32) epoch(384-32) epoch(448-32) epoch(512-32)];
end
features = [negative_f2 negative_ff2 positive_f2 positive_ff2]';
class = [zeros(1,remain_epochnum*2) ones(1,remain_epochnum*2)]';


end