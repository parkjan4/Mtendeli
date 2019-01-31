function [ preds_ens, actuals, Rsq_ens ] = CustomEnsembleMethod( T_clean )
%% Custome Ensemble Method
%   Combines the predictions from random forest and SVR to produce a model
%   with greater predictive power. Takes the average of the two methods.
% Jangwon Park
% jangwon.park@mail.utoronto.ca

%% Split training and testing data sets (if NOT using PCA)
% Standardize (continuous) numerical predictors
T_clean.FRC_mg_l_ = (T_clean.FRC_mg_l_ - mean(T_clean.FRC_mg_l_)) ./ std(T_clean.FRC_mg_l_);
T_clean.TRC_mg_l_ = (T_clean.TRC_mg_l_ - mean(T_clean.TRC_mg_l_)) ./ std(T_clean.TRC_mg_l_);
T_clean.Temp_Cent_ = (T_clean.Temp_Cent_ - mean(T_clean.Temp_Cent_)) ./ std(T_clean.Temp_Cent_);
T_clean.HowFull___ = (T_clean.HowFull___ - mean(T_clean.HowFull___)) ./ std(T_clean.HowFull___);

% I cannot include features that are directly related to decay rate
% rng(18)

T_clean(:,23:35) = [];
T_clean.DecayRate = [];
T_clean.TRC_mg_l__1 = [];
T_clean.Temp_Cent__1 = [];
T_clean.TapStandID = [];
T_clean.clusterID = [];
T_clean.Status = [];

%% If using PCA:
% scores = zscore(scores);
% new_data_set = array2table(scores);
% new_data_set.FRC_mg_l__1 = T_clean.FRC_mg_l__1;
% T_clean = new_data_set;

%% Data partitioning
n = height(T_clean);        % Number of observations
n70 = round(0.8 * n);       % Use 70% of data as training
rand70 = randperm(n,n70);   % Random permutation
data_train = T_clean(rand70,:);
data_test = T_clean;
data_test(rand70,:) = [];   % Use the remaining for test set

%% Call ML algorithms
preds_GB = GBTrees(data_train, data_test);
% preds_SVR = SVMR(data_train, data_test);
% preds_KNN = KNN(data_train, data_test);
preds_RF = RandomForest(data_train, data_test);
preds_ens = ( preds_GB + preds_RF ) / 2;
actuals = data_test.FRC_mg_l__1;

%% Compute R squared
error_GB = actuals - preds_GB;
% error_SVR = actuals - preds_SVR;
% error_KNN = actuals - preds_KNN;
error_RF = actuals - preds_RF;
error_ens = actuals - preds_ens;

Rsq_GB = 1 - sum(error_GB.^2)/sum((actuals - mean(actuals)).^2);
% Rsq_SVR = 1 - sum(error_SVR.^2)/sum((actuals - mean(actuals)).^2);
% Rsq_KNN = 1 - sum(error_KNN.^2)/sum((actuals - mean(actuals)).^2);
Rsq_RF = 1 - sum(error_RF.^2)/sum((actuals - mean(actuals)).^2);
Rsq_ens = 1 - sum(error_ens.^2)/sum((actuals - mean(actuals)).^2);
Rsq = [Rsq_GB, Rsq_RF, Rsq_ens];

% figure; bar(Rsq); xlabel('Algorithms'); ylabel('R squared'); title('Comparison of R Squared');
    
%% Plot REC Curves
% figure; dlw = 1; %default line width
% [AUC,AOC, maxSE] = RECC('SE',actuals,repmat(mean(actuals),length(actuals),1),'k--',dlw); hold on;
% [AUC_KNN, AOC_KNN, maxSE_KNN] = RECC('SE',actuals,preds_KNN,'m-',dlw);
% [AUC_SVR, AOC_SVR, maxSE_SVR] = RECC('SE',actuals,preds_SVR,'r-',dlw);
% [AUC_GB,AOC_GB, maxSE_GB] = RECC('SE',actuals,preds_GB,'b-',dlw);
% [AUC_RF, AOC_RF, maxSE_RF] = RECC('SE',actuals,preds_RF,'g-',dlw);
% [AUC_ens, AOC_ens, maxSE_ens] = RECC('SE',actuals,preds_ens,'k-',2);
% legend('Benchmark','K-NN','SVR','GBTrees','RF','Ensemble');
% 
% AUC_benchmark = AUC / (AUC+AOC);
% AUC_GB = (AUC_GB + maxSE - maxSE_GB) / (AUC_GB + AOC_GB + maxSE - maxSE_GB);
% AUC_SVR = (AUC_SVR + maxSE - maxSE_SVR) / (AUC_SVR + AOC_SVR + maxSE - maxSE_SVR);
% AUC_KNN = (AUC_KNN + maxSE - maxSE_KNN) / (AUC_KNN + AOC_KNN + maxSE - maxSE_KNN);
% AUC_RF = (AUC_RF + maxSE - maxSE_RF) / (AUC_RF + AOC_RF + maxSE - maxSE_RF);
% AUC_ens = (AUC_ens + maxSE - maxSE_ens) / (AUC_ens + AOC_ens + maxSE - maxSE_ens);
% 
% AUC = [AUC_benchmark, AUC_GB, AUC_SVR, AUC_KNN, AUC_RF, AUC_ens];
end

