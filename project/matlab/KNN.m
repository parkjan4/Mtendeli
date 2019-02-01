function [ avg_preds ] = KNN( data_train, data_test )
%% K Nearest Neighbours
% [Description of the method goes here]

%% Fit KNN model for regression
Mdl = fitcknn(data_train,'FRC_mg_l__1','Distance','euclidean','NSMethod','kdtree','KFold',5,'NumNeighbors',3);
avg_preds = zeros(height(data_test),1);
for i=1:Mdl.KFold
    preds = predict(Mdl.Trained{i},data_test); 
%     subplot(2,3,i); 
%     plot(preds,'r'); hold on;
%     plot(data_test.FRC_mg_l__1,'b');
%     xlabel('Samples');ylabel('Second Chlorine [mg/L]');legend('Predictions','Actuals');title('Support Vector Regression Results');
    avg_preds = avg_preds + preds;
end
avg_preds = avg_preds / Mdl.KFold;

end

