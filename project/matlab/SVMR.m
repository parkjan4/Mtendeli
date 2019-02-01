function [ avg_preds] = SVMR( data_train, data_test )
%% Support Vector Machine Regression
% Support Vector Machine (SVM) is a LEARNING ALGORITHM which obtains the
% best generalized patterns in a complex, high-dimensional data set.
% Support Vector Regression is an application of SVM where it attempts to
% find the function f such that the predicted values are never off from the
% actual values by some bound epsilon. In other words, it finds a function
% f that stays within some bounds around the actual pattern, which is also
% as flat as possible. The way it differs from traditional statistical
% regression models is that while they minimize the observed training
% error, SVR minimizes the "generalized error". 

%% Fit SVMR model
Mdl = fitrsvm(data_train,'FRC_mg_l__1','CrossVal','on','KFold',5,'KernelFunction','linear');

% figure;
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

% subplot(2,3,6);
% plot(avg_preds,'r'); hold on;
% plot(data_test.FRC_mg_l__1,'b');
% xlabel('Samples');ylabel('Second Chlorine [mg/L]');legend('Predictions','Actuals');title('Support Vector Regression Results');

end

