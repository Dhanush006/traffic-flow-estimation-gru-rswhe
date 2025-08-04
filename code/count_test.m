load TestData/MVI_20034_hist_mrcnn.mat
X = {};

No_Frames = 6;
Left_Frame = 2;
No_Sel_Cars = 3;


for i = 1:1:size(Sequences,1)
    X{i} = reshape(Sequences(i,:,:),[No_Frames No_Sel_Cars])';
end
X = X';

XTest = X;

miniBatchSize = 107;

inputSize = 3;
numHiddenUnits = 500;
numClasses = 3;


YPred = classify(net,XTest, ...
    'MiniBatchSize',miniBatchSize, ...
    'SequenceLength','longest');
Accumulator
