function [ preds, SE ] = NN( data_train, data_test )
%% Neural Network
% Jangwon Park
% jangwon.park@mail.utoronto.ca

%% Fit Neural Network
% Data prep
data = [data_train; data_test];
inputs = table2array([data(:,1:37) data(:,39:end)])';
targets = table2array(data(:,38))';

% Create a Fitting Network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize);

% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;
 
% Train the Network
[net,tr] = train(net,inputs,targets);
 
% Test the Network
outputs = net(inputs);
errors = gsubtract(outputs,targets);
performance = perform(net,targets,outputs);
 
% % View the Network
% view(net)

%% Plot
subplot(2,3,5);
plot(preds,'r')
hold on
plot(data_test.FRC_mg_l__1,'b')
xlabel('Samples'); ylabel('Terminal FRC [mg/L]');
legend('Predictions','Actuals');
title('Neural Network Results');
end

