
    carDatasetPath='database';
%     seedDatasetPath='C:\Users\User\Desktop\data\brri 52 36 49';
    carData = imageDatastore(carDatasetPath,...
        'IncludeSubfolders',true,'LabelSource','foldernames');

    %%
    % Display some of the images in the datastore.

    perm = randperm(2400,20);
    for plotCounter = 1:20
        subplot(4,5,plotCounter);
        imshow(carData.Files{perm(plotCounter)});
    end
    %Calculate the number of images in each category
    labelCount = countEachLabel(carData)

    %size of the first image in |digitData|
    img = readimage(carData,1);
    size(img)

    %% Specify Training and Validation Sets
    trainNumFiles = 800;
    [trainData,valData] = splitEachLabel(carData,trainNumFiles,'randomize');
    

%% Define Network Architecture
layers = [
    imageInputLayer([30 50 1])
    
    convolution2dLayer(3,8,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(15)
    softmaxLayer
    classificationLayer];

%% Specify Training Options
% 'MiniBatchSize',50
options = trainingOptions('sgdm',...
    'MaxEpochs',10, ...
    'ValidationData',valData,...
    'ValidationFrequency',30,...
    'Verbose',false,...
    'Plots','training-progress');

% Train Network Using Training Data
carNet = trainNetwork(trainData,layers,options);
save carNet;

% %% Classify Validation Images and Compute Accuracy
% predictedLabels = classify(carNet,valData);
% valLabels = valDigitData.Labels;
% 
% accuracy = sum(predictedLabels == valLabels)/numel(valLabels)



