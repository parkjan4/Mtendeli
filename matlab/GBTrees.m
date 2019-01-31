function [ avg_preds ] = GBTrees( data_train, data_test )
%% Gradient boosted regression trees function description
%   I am using Least Squares Boosting algorithm.
%   Boosting algorithm assigns weights to each observation so that they
%   have DIFFERENT probabilities of being sampled. At each instance of
%   building a regression tree, the algorithm attempts to adjust weights so
%   that it improves its predictions on observations that it previously
%   didn't perform well on. However, to evaluate goodness of prediction, it
%   needs a measure -- or a function. LSBoost simply means it uses least
%   squares function to evaludate accuracy. LSBoost works with shallow
%   trees (weak learners; reduce bias)

%% GB Trees: Least Squares Boosting Algorithm
% Build a random forest
Mdl = fitensemble(data_train,'FRC_mg_l__1','LSBoost',100,'tree','CrossVal','on','KFold',5);
Mdl = regularize(Mdl);
% figure;
avg_preds = zeros(height(data_test),1);
for i=1:Mdl.KFold
    preds2 = predict(Mdl.Trained{i},data_test); 
%     subplot(2,3,i); 
%     plot(preds2,'r'); hold on;
%     plot(data_test.FRC_mg_l__1,'b');
%     xlabel('Samples');ylabel('Second Chlorine [mg/L]');legend('Predictions','Actuals');title("Random Forest (LSBoost) with " + NumCycles + " Trees");
  
    avg_preds = avg_preds + preds2;
end
avg_preds = avg_preds / Mdl.KFold;

end

