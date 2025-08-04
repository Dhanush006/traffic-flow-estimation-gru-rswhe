clear
load trainingdata.mat%UA-DETRAC DATASET 6 groupings for 3 cars

idx = randperm(length(labels));
labels = labels(idx);
Sequences = Sequences(idx);

Y = labels;
X = {};


No_Frames = 6;
Left_Frame = 5;
No_Sel_Cars = 3;


for i = 1:1:size(Sequences,1)
      X{i} = reshape(Sequences{i,:,:},[No_Frames No_Sel_Cars])';
end
X = X';
numTimeStepsTrain = floor(0.9*numel(X));

XTrain = X(1:numTimeStepsTrain+1);
YTrain = Y(1:numTimeStepsTrain+1);
XTest = X(numTimeStepsTrain+1:end);
YTest = Y(numTimeStepsTrain+1:end);

numTimeStepsCheck = floor(0.8*numel(XTrain));
XCheck = XTrain(numTimeStepsCheck+1:end);
YCheck = YTrain(numTimeStepsCheck+1:end);

XTrain = XTrain(1:numTimeStepsCheck+1);
YTrain = YTrain(1:numTimeStepsCheck+1);

Val_Data = {XCheck YCheck};


numObservations = numel(XTrain);
miniBatchSize = 107;

inputSize = 3;
numHiddenUnits = 500;
numClasses = 3;

layers = [ ...
    sequenceInputLayer(inputSize)
    gruLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer] %#ok<NOPTS>
maxEpochs = 25;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','gpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress',...
    'ValidationData', Val_Data );

[net,info] = trainNetwork(XTrain,YTrain,layers,options);

YPred = classify(net,XTest, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
count_test;
















