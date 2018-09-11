clc
clear
close all


load('trainingset2')
load('group3')

mu=repmat(mean(trainingset2(:,1:1280)),200,1);
sigma =repmat(std(trainingset2(:,1:1280)),200,1);
trainingset(:,1:1280) = (trainingset2(:,1:1280)- mu)./sigma;

[coeff2,score,latent]=pca(trainingset(:,1:1280),'centered','off');
xdata = [score(:,1:7) ];

% xdata = [ trainingset2(:,1281:1282) ];


SVMModel = fitcsvm(xdata,group);

save('SVMModel','SVMModel');
save('coeff2','coeff2');


% CVSVMModel = crossval(SVMModel,'leaveout','on');
% 
% [validationPredictions, validationScores] = kfoldPredict(CVSVMModel);
% confmat=confusionmat(group,validationPredictions)
% classLoss = (confmat(1,2) + confmat(2,1) )/ sum(sum(confmat))
% beep
% [ScoreSVMModel,ScoreTransform] = fitSVMPosterior(SVMModel)

% for in = 1:1:200
%     if(strcmp(validationPredictions(in),group(in)) == 0)
%         figure,plot(trainingset(in,1:1280))
%         if (strcmp(group(in), 'good') == 1)
%             legend('Marked as GOOD, classified as BAD')
%         else
%             legend('Marked as BAD, classified as GOOD')
%         end
%         
%     end
% end












% cfMat = crossval(f,xdata,group,'partition',cp);
% cfMat = reshape(sum(cfMat),2,2)
% beep
% beep
% % a =crossval(SVMModel,'leaveout','on')
% classLoss = kfoldLoss(CVSVMModel,'mode','individual')*100 % out-of-sample misclassification rate
%
% order = unique(group);
% cp = cvpartition(group,'k',200); % Stratified cross-validation
% f = @(xtr,ytr,xte,yte)confusionmat(yte,classify(xte,xtr,ytr),'order',order);