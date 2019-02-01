function [ hier_clus ] = Clustering( T_clean, Num_cluster )
%% Clustering analysis (Agglomerate clustering, K-means clustering)
% Jangwon Park
% jangwon.park@mail.utoronto.ca
% Function definition
% Input arguments:
%   - T_clean: cleaned data table containing water samples

% PROGRESS SUMMARY
%   - WANTED TO IDENTIFY THE OPTIMAL CUTOFF FOR HIERARCHICAL CLUSTERING --
%   TURNS OUT THIS IS VERY DIFFICULT
%   - NEED TO EXAMINE MULTIPLE CUTOFFS
%   - WHICH ONE IS BEST? NEED A QUANTITATIVE MEASURE -- GAP STATISTIC
%       - Ended up visually choosing the right depth from 9 different
%       inconcsistency coefficient graphs (a little arbitrary)
%   - HOW TO IMPLMENET GAP STATISTIC?
%   - POTENTIAL IMPROVEMENT IS THE DEVELOPMENT OF HYBRID CLUSTERING, NAMELY
%   HIERARCHICAL K-MEANS CLUSTERING, USING THE CENTROID LOCATIONS FROM
%   HIERARCHICAL AS INITIAL LOCATIONS IN K-MEANS WHICH REMAIN STATIONARY
%   ALL THROUGHOUT. FOR NOW, THIS IS OUT OF THE SCOPE.

% Why might I not use K-means and inertia vs. K plot to determine the optimal
% #clusters?
% 1. K-means does not let me explore the full combinations of methods and
% metrics
% 2. Inertia is only a measure of the tightness of each cluster, and does
% not consider inter-cluster distances. In general, larger inter-cluster
% distances with small intra-cluster distances is good.
% 3. Inertia vs. K plot still demands me to select a single value of K
% manually by identifying the 'elbow'. This still seems arbitary and could
% be subject to debate; formalizing this heuristic could be much better!
% (gap statistic)

%% Agglomerate clustering / hierarchical clustering.
% This section aims to find the best combination of method and metrics
% which produces the best clustering outcome (highest cophenetic
% correlation coefficient) with hierarchical clustering

close all;
samples = table2array(T_clean);

% Linkage function to form clusters
% Methods = ["Single","Complete","Average","Centroid","Ward","Median","Weighted"];
% Metrics = ["Euclidean","Seuclidean","Squaredeuclidean","Cityblock","Chebychev","Minkowski","Hamming","Cosine","Correlation","Jaccard","Spearman"];
Methods = [string('Single'),string('Complete'),string('Average'),string('Centroid'),string('Ward'),string('Median'),string('Weighted')];
Metrics = [string('Euclidean'),string('Seuclidean'),string('Squaredeuclidean'),string('Cityblock'),string('Chebychev'),string('Minkowski'),string('Hamming'),string('Cosine'),string('Correlation'),string('Jaccard'),string('Spearman')];
C = zeros(length(Methods),length(Metrics));     % Cophenetic correlation coefficients
V = zeros(length(Methods),length(Metrics));     % Variance (of cluster size) matrix
for i=1:length(Methods)
   for j=1:length(Metrics)
        % Linkage
        Z = linkage(samples,char(Methods(i)),char(Metrics(j)));

        % Pairwise distance data
        P = pdist(samples,char(Metrics(j)));
        
        % Calculate mean, variance, and std. dev among clusters generate by
        % each combination of method and metric (I want roughly equally
        % sized clusters
        hier_clus = cluster(Z,'maxclust', Num_cluster);    
        h1 = histogram(hier_clus, Num_cluster);
        
        % Variance in cluster sizes (I want little variance)
        V(i,j) = var(h1.Values);
        
        % Calculate cophenetic correlation coefficients (CCC)
        C(i,j) = cophenet(Z,P);
   end
end
close;


%% Choose the optimal combination of method and metric based on highest CCC
[method_index, metric_index] = find(C == max(max(C)));

% Bar plot for comparison of CCC for different methods and metrics
figure; bar(C');
ylabel('Cophenetic Correlation Coefficient'); set(gca,'XTickLabel',Metrics);
xtickangle(45); title('Comparison of Different Combinations of Methods and Metrics'); legend(Methods);
Optimal_method_based_on_CCC = Methods(method_index)
Optimal_metric_based_on_CCC = Metrics(metric_index)

%% Choose the optimal combination of method and metric based on lowest Var
[method_index, metric_index] = find(V == min(min(V)));

% Bar plot for comparison of CCC for different methods and metrics
figure; bar(V');
ylabel('Variance in Cluster Size'); set(gca,'XTickLabel',Metrics);
xtickangle(45); title('Comparison of Different Combinations of Methods and Metrics'); legend(Methods);
Optimal_method_based_on_Var = Methods(method_index(1))
Optimal_metric_based_on_Var = Metrics(metric_index(1))

%% Choose the optimal combination of method and metric based on BOTH highest CCC AND lowest Var
% Normalize V such that all numbers are b/w 0 and 1 based on lowest var
V_ = V / min(min(V));

% Invert so that the lower variance receives a higher score (closer to 1)
V_ = 1 ./ V_;

% Now multiply C and V to obtain the weightd score (equal weights) b/w CCC and Var
W_C = 0.5;
W_V = 0.5;
wgt_score = ( W_C * C ) + ( W_V * V_ );


% Overall optimal method and metric are:
[r,c]=find(wgt_score==max(max(wgt_score)));
Optimal_method = Methods(r(1))
Optimal_metric = Metrics(c(1))
Optimal_score = max(max(wgt_score))
CCC = C(r,c)
Var = V_(r,c)

%% Now compare the optimal combination to KMeans default settings
% First plot the optimal combination from above
Z = linkage(samples,char(Methods(r(1))),char(Metrics(c(1))));
hier_clus = cluster(Z,'maxclust', Num_cluster); figure; h1 = histogram(hier_clus, Num_cluster);
% title("Cluster Sizes (Hierarchical: "+Methods(r(1))+" Method with "+Metrics(c(1))+" )");
title(string('Cluster Sizes (Hierarchical: ')+Methods(r(1))+string(' Method with ')+Metrics(c(1))+string(' )'));
Variance1 = var(h1.Values)

% % Next plot the Kmeans default setting
% subplot(1,2,2); [kmeans_clus, ~] = kmeans(samples, Num_cluster,'Replicates', 20);
% h2 = histogram(kmeans_clus,Num_cluster); title('Cluster Sizes (K-means: Centroid Method with Euclidean)');
% Variance2 = var(h2.Values)

%% Calculate inconcsistency coefficients for different depths (helps me
% % determine the right number of clusters to use)
% for i=2:17
%     I = inconsistent(Z,i);      % Trying different depths
%     for j=1:length(I)
%         I(j,5) = j;
%     end
%     
%     % Plot inconsistency coefficient graph for each depth
%     subplot(4,4,i-1);
%     scatter(I(:,5),I(:,4),'+'); % I(:,4): inconsistency coeff, I(:,5): index
%     title("Depth = " + string(i)); ylabel('Inconsistency Coefficient');
%     
%     hold on;
%     
%     temp = zeros(length(I),1);
%     for k=1:length(I)
%         temp(k) = max(I(:,4));
%     end
%     plot(I(:,5),temp,'--');
% end

end

