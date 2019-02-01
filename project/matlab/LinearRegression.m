function [ preds ] = LinearRegression( data_train, data_test )
%% Multiple Linear Regression

%% Fit model and predict
data_train.New = log(data_train.FRC_mg_l__1 ./ data_train.FRC_mg_l_);
data_test.New = log(data_test.FRC_mg_l__1 ./ data_test.FRC_mg_l_);
data_train.FRC_mg_l__1 = [];
data_train.FRC_mg_l_ = [];
data_test.FRC_mg_l__1 = [];
data_test.FRC_mg_l_ = [];

data = table2array(data_train);
X = data(:,1:end-1);
Y = data(:,end);
Mdl = fitrlinear(X,Y,'Learner','svm','CrossVal','on','KFold',5);

X_test = data_test(:,1:end-1);
avg_preds = zeros(height(data_test),1);
for i=1:Mdl.KFold
    preds2 = predict(Mdl.Trained{i},table2array(X_test));
    subplot(2,3,i); 
    plot(preds2,'r'); hold on;
    plot(data_test.New,'b');
    xlabel('Samples');ylabel('Second Chlorine [mg/L]');legend('Predictions','Actuals');
  
    avg_preds = avg_preds + preds2;
end
preds = avg_preds / Mdl.KFold;
error = data_test.New - preds;
Rsq = 1 - sum(error.^2)/sum((data_test.New - mean(data_test.New)).^2);
mean(Rsq)
end

