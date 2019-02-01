function [ T_clean ] = CleanDatav2( T )
% Clean data to prepare it for machine learning algorithms. This is
% slightly different from CleanData, which prepares the data mainly for
% clusteirng.

%% Clean / reformat data
% Remove all unnecessary predictors
T_clean = T;
% T_clean.TapStandID = [];
% T_clean.TRC_mg_l__1 = [];
% T_clean.TimeElapsed = [];
% T_clean.TimeCollected = [];
T_clean.InitialTime = zeros(height(T_clean),1);
T_clean = T_clean(~any(ismissing(T_clean),2),:);

% Reorder so the target is at the front (column 1)
T_clean = [T_clean(:,38) T_clean(:,1:37) T_clean(:,39:end)];

end

