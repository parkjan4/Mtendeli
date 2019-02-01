function [ T_clean ] = EDA( T_clean )
%% Exploratory Data Analysis
%% Are there any outliers?
% In this analysis, I consider all samples whose second FRC is higher than
% initial to be outliers because in reality, this cannot happen.
outliers = T_clean(T_clean.FRC_mg_l__1 > T_clean.FRC_mg_l_,:)
T_clean(T_clean.FRC_mg_l__1 > T_clean.FRC_mg_l_,:) = [];    % Remove

%% Are there any Inf decay rates? Remove them for the purpose of this analysis
InfDecays = T_clean(T_clean.DecayRate == Inf,:)
T_clean(T_clean.DecayRate == Inf,:) = [];

%% Does "high initial FRC" imply "high FRC Reduction" and/or "high decay rate"?
chl = [T_clean.FRC_mg_l_,T_clean.FRC_mg_l__1,T_clean.DecayRate,T_clean.TimeElapsed/max(T_clean.TimeElapsed)];
chl_sorted = sortrows(chl,1);   % sorted according to initial chlorine
figure; subplot(2,3,1); bar_handle = bar(chl_sorted(:,1:2)); xlabel('Samples'); ylabel('FRC [mg/L]');
set(bar_handle(1),'FaceColor','r'); set(bar_handle(2),'FaceColor','b');
title('Does "high initial FRC" imply "high final FRC" and/or "high decay rate"?');
hold on; plot(chl_sorted(:,3),'k');
hold on; plot(chl_sorted(:,4),'g');
legend('First FRC','Second FRC','Decay Rate [mg/L/h]','Normalized TimeElapsed');

%% Does "small time elapsed" imply "smaller FRC reduction"? (it should if all data points follow one model)
chl = [T_clean.TimeElapsed/max(T_clean.TimeElapsed),T_clean.FRC_mg_l_ - T_clean.FRC_mg_l__1];
chl_sorted = sortrows(chl,1);   % sorted according to initial chlorine
subplot(2,3,2); bar_handle = bar(chl_sorted(:,2)); xlabel('Samples'); ylabel('FRC [mg/L]');
set(bar_handle(1),'FaceColor','r'); %set(bar_handle(2),'FaceColor','b');
title('Does high final FRC imply small time elapsed?');
hold on; plot(chl_sorted(:,1),'k');
legend('FRC Reduction [mg/L]','Normalized Time Elapsed');

%% How is TimeElapsed distributed? What is the range for it?
subplot(2,3,3); histogram(T_clean.TimeElapsed); ylabel('Count'); xlabel('Time Elapsed [h]');
title('How is TimeElapsed distributed? What is the range for it?');
Time_range = max(T_clean.TimeElapsed) - min(T_clean.TimeElapsed)
% ANS: range is about 10 hours. 

%% Does "great % FRC reduced" imply "high initial FRC"?
PercentFRCReduced = (T_clean.FRC_mg_l_ - T_clean.FRC_mg_l__1) ./ T_clean.FRC_mg_l_;
subplot(2,3,4); scatter(T_clean.FRC_mg_l_,-T_clean.DecayRate,'filled'); xlabel('Initial Chlorine [mg/L]'), ylabel('Decay Rate [mg/L/h]');
title('Does "high initial FRC" imply "high decay rate"?');

% Average % FRC left
Avg_percent_FRC_reduced = mean(PercentFRCReduced);

%% Distribution of decay rates
subplot(2,3,5); histogram(-T_clean.DecayRate); xlabel('Decay Rate [mg/L/h]'); ylabel('Count')
title('Distribution of Decay Rates');

%% Distribution of first and second chlorine measurements
subplot(2,3,6); histogram(T_clean.FRC_mg_l_); hold on; histogram(T_clean.FRC_mg_l__1);
xlabel('Chlorine Concentration [mg/L]'); ylabel('Count');
title('Distribution of first and second chlorine measurements');
legend('First Chlorine','Second Chlorine');

%% Correlation between temperature differential and decay rate
figure; subplot(2,2,1);
scatter(T_clean.Temp_Cent_, -T_clean.DecayRate,'ro','filled');
xlabel('Temperature [C]');ylabel('Decay Rate [mg/L/h]');
title('Is there any rorrelation between temperature and decay rate?');

%% Correlation between container type and decay rate
% Opacity = 1 means "translucent". Opacity = 0 means "opaque"
subplot(2,2,2);
temp_jc_op = T_clean(T_clean.JerryCan == 1 & T_clean.Cont_Opacity == 0,:);
temp_jc_tl = T_clean(T_clean.JerryCan == 1 & T_clean.Cont_Opacity == 1,:);
temp_bk_op = T_clean(T_clean.Bucket == 1 & T_clean.Cont_Opacity == 0,:);
temp_bk_tl = T_clean(T_clean.Bucket == 1 & T_clean.Cont_Opacity == 1,:);
histogram(-temp_jc_op.DecayRate); hold on; histogram(-temp_bk_op.DecayRate);
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); legend('Opaque Jerry Can','Opaque Bucket');
title('Distribution of decay rates by container type');

subplot(2,2,3); 
histogram(-temp_jc_tl.DecayRate); hold on; histogram(-temp_bk_tl.DecayRate);
xlabel('Decay Rate [mg/L/h]'); ylabel('Count'); legend('Translucent Jerry Can','Translucent Bucket');
title('Distribution of decay rates by container type');

%% Correlation between time elapsed and decay rate
% subplot(2,2,3);
% scatter(T_clean.TimeElapsed,-T_clean.DecayRate,'ro');
% xlabel('Time Elapsed [h]'); ylabel('Decay Rate [mg/L/h]');
% title('Is there any correlation between time elapsed and decay rate?');

%% Correlation between morning/afternoon and decay rate
subplot(2,2,4);
temp_m = T_clean(T_clean.MorningAfternoon==1,:); % Morning
temp_a = T_clean(T_clean.MorningAfternoon==0,:); % Afternoon
histogram(-temp_m.DecayRate); hold on; histogram(-temp_a.DecayRate);
legend('Morning','Afternoon'); xlabel('Decay Rate [mg/L/h]'); ylabel('Count');

end

