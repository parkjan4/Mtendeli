function [vars_nca, vars_lasso, vars_corrcoef] = FeatSelect(T_clean)
%% Function description
% Feature selection algorithms using neighborhood component analysis (NCA),
% lasso regularization, and correlation coefficient scores

%% Neighborhood Component Analysis (NCA) feature selection (Embedded Method)
% Feature selection algorithm by minimizing the average prediction error
% with a regularization term with lambda as a constant being multiplied.
% The regularization term is a sum of squared weights for each feature and
% is therefore conceptually very similar to ridge regression. Default
% "weights" are 1's. Functionally, NCA serves the same purpose as KNN and
% makes direct use of stochastic nearest neighbours. For more info:
% https://www.mathworks.com/help/stats/neighborhood-component-analysis.html

rng(1);
X = [T_clean(:,3:22), T_clean(:,36), T_clean(:,40:41)];
Y = T_clean(:,37);
Mdl = fsrnca(table2array(X),table2array(Y),'Solver','sgd','Standardize',true,'LossFunction','mad');

important = Mdl.FeatureWeights;
figure; plot(important,'ro'); grid on;
xlabel('Feature Index'); ylabel('Feature Weight');

vars_nca = X.Properties.VariableNames(important > 0.01)'

%% Lasso regularization (Embedded Method)
% Lasso regularization is an extension to linear regression where we aim to
% achieve minimum sum of squared errors but by adding another term i.e. sum
% of the beta coefficients with lambda as a constant being multiplied.
% Intuitively, it penalizes large beta coefficients by adding to the errors
% and produces a sparse solution.
[B, FitInfo] = lasso(table2array(X),table2array(Y),'CV',10,'Standardize',true,'PredictorNames',X.Properties.VariableNames);

% Display selected features
vars_lasso = FitInfo.PredictorNames(B(:,FitInfo.Index1SE) ~= 0);
fprintf('\nSelected variables (lasso):\n')
disp(vars_lasso(:));

% Regression coefficients
fprintf('\nRegression coefficients (lasso):\n');
disp(B(B(:,FitInfo.Index1SE)~=0,FitInfo.Index1SE));

%% Correlation coefficient: score of relevance to the target (Filter Method)
vars_corrcoef = zeros(width(X),1);
for i=1:width(X)
    coeffs = corrcoef(table2array(X(:,i)),table2array(Y));
    if abs(coeffs(1,2)) > 0.15
        vars_corrcoef(i) = 1;
    end
end
vars_corrcoef = X.Properties.VariableNames(vars_corrcoef==1);
fprintf('\nSelected variables (corrcoef):\n');
disp(vars_corrcoef(:));

%% Correlation among features
% A = table2array(X);
% corr_feat = triu(corrcoef(A)) - diag(diag(corrcoef(A)))
% [I,J] = find(abs(corr_feat) > 0.85);
% for j = 1:length(I)
%     fprintf('%s and %s: %g\n', X.Properties.VariableNames{I(j)}, X.Properties.VariableNames{J(j)}, corr_feat(I(j),J(j)))
% end

