function [loadings, scores, index] = DimRed(T_clean)
%% PRINCIPAL COMPONENT ANALYSIS (PCA)
% In short: PCA is a dimension-reduction technique which obatins a subset
% of features that explain most of the variability within the data. It
% achieves this by seeking a linear combination of the features which
% maximizes the variance extracted from the features. PCA assumes that
% variance implies variability, hence its importance in explaining our
% dataset.

% What does a 'principal component' mean? A PC is a hypothetical 'axis'.
% PC1 identifies the "direction of variation", or axis, which explains the
% most variation within the data. PC2 is the axis which explains the second
% most variation within the data... and so on. If we only choose TWO PC's
% in our data, then this is effectively transforming our
% however-many-dimensional data into a 2D graph!

% Another important output of PCA might be the 'scores'. Scores is usually
% a n x p matrix where n = #obs and p = #PC's i.e. each sample (data point)
% has scores across each PC. How do I generate a single score for each
% feature in each PC? ANS: if you want to calculate a score of feature 1 in
% PC1, you calculate the linear combination of the scores of all data
% points where each data point's score is multiplied by its original value
% in feature 1.

% OUTPUT:
% loadings = k x p where k = #features, p = #PC's. Indicates each feature's
%   score (or influence) on each PC i.e. correlation with that PC.
% scores = n x p where n = #obs. Indicates each sample's (data point)
% score. Measures that particular observation's influence on that PC.
% latent = variance explained by each PC.
% explained = % variance explained by each PC

%% Standardize all features
T_clean.FRC_mg_l_ = (T_clean.FRC_mg_l_ - mean(T_clean.FRC_mg_l_)) ./ std(T_clean.FRC_mg_l_);
T_clean.TRC_mg_l_ = (T_clean.TRC_mg_l_ - mean(T_clean.TRC_mg_l_)) ./ std(T_clean.TRC_mg_l_);
T_clean.Temp_Cent_ = (T_clean.Temp_Cent_ - mean(T_clean.Temp_Cent_)) ./ std(T_clean.Temp_Cent_);
T_clean.HowFull___ = (T_clean.HowFull___ - mean(T_clean.HowFull___)) ./ std(T_clean.HowFull___);

% I cannot include features that are directly related to decay rate
T_clean(:,23:35) = [];
T_clean.DecayRate = [];
T_clean.TRC_mg_l__1 = [];
T_clean.Temp_Cent__1 = [];
T_clean.TapStandID = [];
T_clean.clusterID = [];

%% Principal Component Analysis (PCA)
[loadings, scores, ~, ~, explained] = pca(table2array(T_clean));  

% Bar plot of % variance explaiend by each PC
figure()
bar(explained); title('Scree plot');
xlabel('Principal Components'); ylabel('% Variance Explained');

% Choosing the number of principal components
index = 1;
while sum(explained(1:index)) < 99
    index = index + 1;
end

%%
% transpose(T_clean) * score
% For each feature in T_clean, I multiply each observation's value under
% that feature with the score of that observation under PC1, PC2, PC3, ...
% The outcome is the total score of that FEATURE in PC1, PC2, PC3, ...



end

