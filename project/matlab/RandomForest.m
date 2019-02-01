function [ preds ] = RandomForest( data_train, data_test )
%% Function description
%   This function is random forest using Bagging algorithm. In bagging
%   algorithms, I am randomly sampling observations with replacement
%   from the full training set with EQUAL probabilities for each 
%   observation to build INDEPENDENT regression trees. These trees are
%   grown in parallel and are by default deep trees. 

%% Random Forest I: Bagging Algorithm
 
% Build a random forest
forest = TreeBagger(100,data_train,'FRC_mg_l__1','Method','regression','NumPredictorsToSample','all');
preds = predict(forest,data_test); 
% plot(preds,'r'); hold on;
% plot(data_test.FRC_mg_l__1,'b');
% xlabel('Samples');ylabel('Second Chlorine [mg/L]');legend('Predictions','Actuals');title('Random Forest');

end

