%% Main file
% Jangwon Park
% jangwon.park@mail.utoronto.ca

%% Import and clean data
clear;
clc;
T = readtable('Sept 16 FRC Survey Data Mtendeli.csv');
T_clean = CleanDatav2(T);

%% *************** CUSTOM ALGORITHM ***************
%% 3-Cluster Approach
% STEP 1: Calculate decay rate of each sample (first order)
T_clean.DecayRate = (T_clean.FRC_mg_l__1 - T_clean.FRC_mg_l_) ./ T_clean.FRC_mg_l_;
% T_clean.DecayRate = log(T_clean.FRC_mg_l__1 ./ T_clean.FRC_mg_l_) ./ (-T_clean.TimeElapsed);  % [mg/L]/h
% T_clean.DecayRate = -(1./T_clean.FRC_mg_l__1 - 1./T_clean.FRC_mg_l_) ./ (T_clean.TimeElapsed);  % [mg/L]/h
T_clean = EDA(T_clean);

% STEP 2: Cluster according to decay rate: high, medium, low
T_temp = T_clean(:,{'DecayRate'});
Num_cluster = 3;
clusterID = Clustering(T_temp,Num_cluster);
T_clean.clusterID = clusterID;

% Store the clusters into a new table
T_cluster1 = T_clean(T_clean.clusterID == 1,:); % low decay
T_cluster2 = T_clean(T_clean.clusterID == 2,:); % medium decay
T_cluster3 = T_clean(T_clean.clusterID == 3,:); % high decay
%% 5-Cluster Approach
T_cluster1 = T_clean(T_clean.DecayRate > -0.2,:);
T_cluster2 = T_clean(T_clean.DecayRate <= -0.2 & T_clean.DecayRate > -0.4,:);
T_cluster3 = T_clean(T_clean.DecayRate <= -0.4 & T_clean.DecayRate > -0.6,:);
T_cluster4 = T_clean(T_clean.DecayRate <= -0.6 & T_clean.DecayRate > -0.8,:);
T_cluster5 = T_clean(T_clean.DecayRate <= -0.8,:);

%% ***** EDA CHECKPOINT #1: *****
% Can I clustering into three distinct decay rate categories WIHTOUT the involvement of the response variable?
T_temp = T_clean;

T_temp2 = T_temp(:,{'FRC_mg_l_','Temp_Cent_','JerryCan','Bucket','Cont_Clean','Cont_Covered'});

Num_cluster = 3;
clusterID = Clustering(T_temp2,Num_cluster);
T_temp.clusterID = clusterID;
T_temp1 = T_temp(T_temp.clusterID == 1,:);
T_temp1.DecayRate = (T_temp1.FRC_mg_l__1 - T_temp1.FRC_mg_l_) ./ T_temp1.FRC_mg_l_;
T_temp2 = T_temp(T_temp.clusterID == 2,:);
T_temp2.DecayRate = (T_temp2.FRC_mg_l__1 - T_temp2.FRC_mg_l_) ./ T_temp2.FRC_mg_l_;
T_temp3 = T_temp(T_temp.clusterID == 3,:);
T_temp3.DecayRate = (T_temp3.FRC_mg_l__1 - T_temp3.FRC_mg_l_) ./ T_temp3.FRC_mg_l_;

% medium decay
T_temp2 = EDA(T_temp2); % low decay
T_temp3 = EDA(T_temp3); % high decay

[mean(T_temp2.DecayRate) mean(T_temp1.DecayRate) mean(T_temp3.DecayRate)]

% X1 = [T_temp1.InitialTime; T_temp1.TimeElapsed];
% Y1 = [T_temp1.FRC_mg_l_; T_temp1.FRC_mg_l__1];
% [f1, fitness1, ~] = fit(X1,Y1,'exp1');
% figure; subplot(1,2,1); plot(f1,X1,Y1); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');
% 
% X2 = [T_temp2.InitialTime; T_temp2.TimeElapsed];
% Y2 = [T_temp2.FRC_mg_l_; T_temp2.FRC_mg_l__1];
% [f2, fitness2, ~] = fit(X2,Y2,'exp1');
% subplot(1,2,2); plot(f2,X2,Y2); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

%% STEP 2 CONTINUED
% They are rouhgly equally sized with roughly equal time frame
T_cluster1 = EDA(T_cluster1);   % Low decay rate group
T_cluster2 = EDA(T_cluster2);   % Medium decay rate group
T_cluster3 = EDA(T_cluster3);   % High decay rate group

% For each cluster, fit a curve
X1 = [T_cluster1.InitialTime; T_cluster1.TimeElapsed];
Y1 = [T_cluster1.FRC_mg_l_; T_cluster1.FRC_mg_l__1];
[f1, fitness1, ~] = fit(X1,Y1,'exp1');
figure; subplot(2,2,1); plot(f1,X1,Y1); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

X2 = [T_cluster2.InitialTime; T_cluster2.TimeElapsed];
Y2 = [T_cluster2.FRC_mg_l_; T_cluster2.FRC_mg_l__1];
[f2, fitness2, ~] = fit(X2,Y2,'exp1');
subplot(2,2,2); plot(f2,X2,Y2); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

X3 = [T_cluster3.InitialTime; T_cluster3.TimeElapsed];
Y3 = [T_cluster3.FRC_mg_l_; T_cluster3.FRC_mg_l__1];
[f3, fitness3, ~] = fit(X3,Y3,'exp1');
subplot(2,2,3); plot(f3,X3,Y3); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

%% ***** EDA CHECKPOINT #2: *****
% Analyze which tap stands produce samples that decay at a high/medium/low rate
unique_taps = unique(T_clean.TapStandID);
counts = zeros(length(unique_taps),3);
decayrates = zeros(length(unique_taps),3);
for i = 1:length(unique_taps)
    for j = 1:height(T_cluster1)
        if string(unique_taps(i)) == string(T_cluster1.TapStandID(j))
            counts(i,1) = counts(i,1) + 1;
            decayrates(i,1) = decayrates(i,1) + T_cluster1.DecayRate(j);
        end
    end    
end
for i = 1:length(unique_taps)
    for j = 1:height(T_cluster2)
        if string(unique_taps(i)) == string(T_cluster2.TapStandID(j))
            counts(i,2) = counts(i,2) + 1;
            decayrates(i,2) = decayrates(i,2) + T_cluster2.DecayRate(j);
        end
    end    
end
for i = 1:length(unique_taps)
    for j = 1:height(T_cluster3)
        if string(unique_taps(i)) == string(T_cluster3.TapStandID(j))
            counts(i,3) = counts(i,3) + 1;
            decayrates(i,3) = decayrates(i,3) + T_cluster3.DecayRate(j);
        end
    end    
end
TapStandAvgRate = transpose(sum(decayrates') ./ sum(counts'));
counts(:,4) = TapStandAvgRate;
counts_sorted = sortrows(counts,4);

figure; bar(counts_sorted(:,1:3),'stacked');
xlabel('Tap Stand IDs'); ylabel('Count'); title('What kind of samples does each tap stand distribute?');

hold on; plot(-counts_sorted(:,4),'k'); legend('Low Rate','Medium Rate','High Rate','Average Decay Rate [mg/L/h]');

% Check normality of avg. tap stand decay rate and compute basic stats
figure; histogram(-TapStandAvgRate); xlabel('Decay Rate [mg/L]'); ylabel('Count'); title('Distribution of average decay rates of all tap stands');
figure; qqplot(-TapStandAvgRate);
MeanDecayRate = mean(-TapStandAvgRate);
StdDecayRate = std(-TapStandAvgRate);

%% ***** EDA CHECKPOINT #3: *****
%% 3-Cluster Approach
% Is temperature differential positively correlated with decay rate?
TempDiff1 = T_cluster1.Temp_Cent__1-T_cluster1.Temp_Cent_;
TempDiff2 = T_cluster2.Temp_Cent__1-T_cluster2.Temp_Cent_;
TempDiff3 = T_cluster3.Temp_Cent__1-T_cluster3.Temp_Cent_;
groups = [ones(size(TempDiff1));2*ones(size(TempDiff2));3*ones(size(TempDiff3))];
figure; boxplot([TempDiff1; TempDiff2; TempDiff3],groups);
xlabel('Clusters'); ylabel('Temperature Differential (final - initial) [C]'); title('Box plots of temperature differential for each cluster');
hold on; plot([1;2;3],[mean(TempDiff1); mean(TempDiff2); mean(TempDiff3)],'dg');

% Is the fullness of each sample (container) correlated with decay rate?
groups = [ones(size(T_cluster1.HowFull___));2*ones(size(T_cluster2.HowFull___));3*ones(size(T_cluster3.HowFull___))];
figure; boxplot([T_cluster1.HowFull___; T_cluster2.HowFull___; T_cluster3.HowFull___],groups);
xlabel('Clusters'); ylabel('Fullness of the container [%]'); title('Box plots of container fullness for each cluster');
X = [mean(T_cluster1.HowFull___); mean(T_cluster2.HowFull___); mean(T_cluster3.HowFull___)];
hold on; plot([1;2;3],X,'dg');
%% 5-Cluster Approach
% Is temperature differential positively correlated with decay rate?
TempDiff1 = T_cluster1.Temp_Cent__1-T_cluster1.Temp_Cent_;
TempDiff2 = T_cluster2.Temp_Cent__1-T_cluster2.Temp_Cent_;
TempDiff3 = T_cluster3.Temp_Cent__1-T_cluster3.Temp_Cent_;
TempDiff4 = T_cluster4.Temp_Cent__1-T_cluster4.Temp_Cent_;
TempDiff5 = T_cluster5.Temp_Cent__1-T_cluster5.Temp_Cent_;
groups = [ones(size(TempDiff1));2*ones(size(TempDiff2));3*ones(size(TempDiff3));4*ones(size(TempDiff4));5*ones(size(TempDiff5))];
figure; boxplot([TempDiff1; TempDiff2; TempDiff3; TempDiff4; TempDiff5],groups);
xlabel('Clusters'); ylabel('Temperature Differential (final - initial) [C]'); title('Box plots of temperature differential for each cluster');
hold on; plot([1;2;3;4;5],[mean(TempDiff1); mean(TempDiff2); mean(TempDiff3); mean(TempDiff4); mean(TempDiff5)],'dg');

% Is the fullness of each sample (container) correlated with decay rate?
groups = [ones(size(T_cluster1.HowFull___));2*ones(size(T_cluster2.HowFull___));3*ones(size(T_cluster3.HowFull___));4*ones(size(T_cluster4.HowFull___));5*ones(size(T_cluster5.HowFull___))];
figure; boxplot([T_cluster1.HowFull___; T_cluster2.HowFull___; T_cluster3.HowFull___; T_cluster4.HowFull___; T_cluster5.HowFull___],groups);
xlabel('Clusters'); ylabel('Fullness of the container [%]'); title('Box plots of container fullness for each cluster');
X = [mean(T_cluster1.HowFull___); mean(T_cluster2.HowFull___); mean(T_cluster3.HowFull___); mean(T_cluster4.HowFull___); mean(T_cluster5.HowFull___)];
hold on; plot([1;2;3;4;5],X,'dg');

%% ***** EDA CHECKPOINT #4: *****
%% 3-Cluster Approach
% Is their any correlation between container type and decay rate?
figure; subplot(2,2,1);
cluster1_jc = T_cluster1(T_cluster1.JerryCan==1,:);
cluster1_bk = T_cluster1(T_cluster1.Bucket==1,:);
histogram(cluster1_jc.DecayRate); hold on; histogram(cluster1_bk.DecayRate); legend('Jerry Can','Bucket');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 1 Decay Rate Distribution by Container Type');

subplot(2,2,2);
cluster2_jc = T_cluster2(T_cluster2.JerryCan==1,:);
cluster2_bk = T_cluster2(T_cluster2.Bucket==1,:);
histogram(cluster2_jc.DecayRate); hold on; histogram(cluster2_bk.DecayRate); legend('Jerry Can','Bucket');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 2 Decay Rate Distribution by Container Type');

subplot(2,2,3);
cluster3_jc = T_cluster3(T_cluster3.JerryCan==1,:);
cluster3_bk = T_cluster3(T_cluster3.Bucket==1,:);
histogram(cluster3_jc.DecayRate); hold on; histogram(cluster3_bk.DecayRate); legend('Jerry Can','Bucket');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 3 Decay Rate Distribution by Container Type');

subplot(2,2,4);
temp_jc = T_clean(T_clean.JerryCan == 1,:);
temp_bk = T_clean(T_clean.Bucket == 1,:);
histogram(temp_jc.DecayRate); hold on; histogram(temp_bk.DecayRate); legend('Jerry Can','Bucket');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('(ALL) Decay Rate Distribution by Container Type');

%% ***** EDA CHECKPOINT #5: *****
%% 3-Cluster Approach
% Is there any correlation between method of drawing water and decay rate?
figure; subplot(2,2,1);
cluster1_po = T_cluster1(T_cluster1.MethodDrawing==1,:);
cluster1_dg = T_cluster1(T_cluster1.MethodDrawing==0,:);
histogram(cluster1_po.DecayRate); hold on; histogram(cluster1_dg.DecayRate); legend('Pour Out','Dip Glass');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 1 Decay Rate Distribution by Method of Drawing');

subplot(2,2,2);
cluster2_po = T_cluster2(T_cluster2.MethodDrawing==1,:);
cluster2_dg = T_cluster2(T_cluster2.MethodDrawing==0,:);
histogram(cluster2_po.DecayRate); hold on; histogram(cluster2_dg.DecayRate); legend('Pour Out','Dip Glass');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 2 Decay Rate Distribution by Method of Drawing');

subplot(2,2,3);
cluster3_po = T_cluster3(T_cluster3.MethodDrawing==1,:);
cluster3_dg = T_cluster3(T_cluster3.MethodDrawing==0,:);
histogram(cluster3_po.DecayRate); hold on; histogram(cluster3_dg.DecayRate); legend('Pour Out','Dip Glass');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('Cluster 2 Decay Rate Distribution by Method of Drawing');

subplot(2,2,4);
po = T_clean(T_clean.MethodDrawing==1,:);
dg = T_clean(T_clean.MethodDrawing==0,:);
histogram(po.DecayRate); hold on; histogram(dg.DecayRate); legend('Pour Out','Dip Glass');
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); title('(ALL) Decay Rate Distribution by Method of Drawing');

%% ALGORITHM CONTINUED
% STEP 3: Predict second chlorine in each cluster using ML
Num_trials = 9;
Rsq1 = zeros(Num_trials,1); figure;
for i=1:Num_trials
    [preds,actuals,Rsq] = CustomEnsembleMethod(T_cluster1);
    
    subplot(sqrt(Num_trials),sqrt(Num_trials),i);
    plot(preds,'r'); hold on; plot(actuals,'b');
    xlabel('Samples'); ylabel('Second Chlorine [mg/L]');
    legend('Predictions','Actuals');
    title('Ensemble Method Results (Average)');
    
    Rsq1(i) = Rsq;
end
mean(Rsq1)

Rsq2 = zeros(Num_trials,1); figure;
for i=1:Num_trials
    [preds,actuals,Rsq] = CustomEnsembleMethod(T_cluster2);
    
    subplot(sqrt(Num_trials),sqrt(Num_trials),i);
    plot(preds,'r'); hold on; plot(actuals,'b');
    xlabel('Samples'); ylabel('Second Chlorine [mg/L]');
    legend('Predictions','Actuals');
    title('Ensemble Method Results (Average)');
    
    Rsq2(i) = Rsq;
end

Rsq3 = zeros(Num_trials,1); figure;
for i=1:Num_trials
    [preds,actuals,Rsq] = CustomEnsembleMethod(T_cluster3,scores(:,1:index));
    
    subplot(sqrt(Num_trials),sqrt(Num_trials),i);
    plot(preds,'r'); hold on; plot(actuals,'b');
    xlabel('Samples'); ylabel('Second Chlorine [mg/L]');
    legend('Predictions','Actuals');
    title('Ensemble Method Results (Average)');
    
    Rsq3(i) = Rsq;
end
mean(Rsq3)

% Rsq4 = zeros(Num_trials,1); figure;
% for i=1:Num_trials
%     [preds,actuals,Rsq] = CustomEnsembleMethod(T_cluster4);
%     
%     subplot(sqrt(Num_trials),sqrt(Num_trials),i);
%     plot(preds,'r'); hold on; plot(actuals,'b');
%     xlabel('Samples'); ylabel('Second Chlorine [mg/L]');
%     legend('Predictions','Actuals');
%     title('Ensemble Method Results (Average)');
%     
%     Rsq4(i) = Rsq;
% end

% Rsq5 = zeros(Num_trials,1); figure;
% for i=1:Num_trials
%     [preds,actuals,Rsq] = CustomEnsembleMethod(T_cluster5);
%     
%     subplot(sqrt(Num_trials),sqrt(Num_trials),i);
%     plot(preds,'r'); hold on; plot(actuals,'b');
%     xlabel('Samples'); ylabel('Second Chlorine [mg/L]');
%     legend('Predictions','Actuals');
%     title('Ensemble Method Results (Average)');
%     
%     Rsq5(i) = Rsq;
% end

Rsq_combined = [Rsq1, Rsq2, Rsq3, Rsq4, Rsq5];
VarDecayRate = [var(T_cluster1.DecayRate),var(T_cluster2.DecayRate),var(T_cluster3.DecayRate),var(T_cluster4.DecayRate),var(T_cluster5.DecayRate)];
VarFirstChlr = [var(T_cluster1.FRC_mg_l_),var(T_cluster2.FRC_mg_l_),var(T_cluster3.FRC_mg_l_),var(T_cluster4.FRC_mg_l_),var(T_cluster5.FRC_mg_l_)];
VarSecondChlr = [var(T_cluster1.FRC_mg_l__1),var(T_cluster2.FRC_mg_l__1),var(T_cluster3.FRC_mg_l__1),var(T_cluster4.FRC_mg_l__1),var(T_cluster5.FRC_mg_l__1)];

% STEP 4: Perform translation along time-axis for each sample
% Translate time component of cluster 1
T_input1 = table(X1,Y1,'VariableNames',{'Time','ChlorineLevel'});
[~, T_cluster1_trans] = TimeShift(T_input1,T_cluster1,[f1.a, f1.b]);

X4 = [T_cluster1_trans.InitialTime; T_cluster1_trans.TimeElapsed];
Y4 = [T_cluster1_trans.FRC_mg_l_; T_cluster1_trans.FRC_mg_l__1];
[f4, fitness4, ~] = fit(X4,Y4,'exp1');
figure; subplot(2,2,1); plot(f4,X4,Y4); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

% Translate time component of cluster 2
T_input2 = table(X2,Y2,'VariableNames',{'Time','ChlorineLevel'});
[~, T_cluster2_trans] = TimeShift(T_input2,T_cluster2,[f2.a, f2.b]);

X5 = [T_cluster2_trans.InitialTime; T_cluster2_trans.TimeElapsed];
Y5 = [T_cluster2_trans.FRC_mg_l_; T_cluster2_trans.FRC_mg_l__1];
[f5, fitness5, ~] = fit(X5,Y5,'exp1');
subplot(2,2,2); plot(f5,X5,Y5); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

% Translate time component of cluster 3
T_input3 = table(X3,Y3,'VariableNames',{'Time','ChlorineLevel'});
[~, T_cluster3_trans] = TimeShift(T_input3,T_cluster3,[f3.a, f3.b]);

X6 = [T_cluster3_trans.InitialTime; T_cluster3_trans.TimeElapsed];
Y6 = [T_cluster3_trans.FRC_mg_l_; T_cluster3_trans.FRC_mg_l__1];
[f6, fitness6, ~] = fit(X6,Y6,'exp1');
subplot(2,2,3); plot(f6,X6,Y6); xlabel('Time [h]'); ylabel('Second Chlorine Level [mg/L]');

%% *************** FEATURE SELECTION ***************
%% NCA, lasso, correlation scores
[vars_nca, vars_las, vars_corr] = FeatSelect(T_clean);

%% PCA for dimension reduction
[loadings, scores, index] = DimRed(T_clean);

