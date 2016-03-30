%%read data
sample1 = csvread('10sample1.csv',1,1);
%testSet = csvread('test.csv',1,1);

%% Matrix Factoization

% Set initial values
numOfFeatures = 4; 
numOfEpochs = 29;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;
%% 10 fold cross validation
sample_size= length(sample1);
[train,test] = dividerand(sample_size, 0.8, 0.2);
       

    testSet = sample1(test,:);
    trainSet = sample1(train,:);    
                         


% calculate biases
[globalBias, userBiases, itemBiases] = globecalculateBiases( trainSet );
% training
pUF = zeros(max(trainSet(:,4)),numOfFeatures);
qIF = zeros(max(trainSet(:,3)),numOfFeatures);

 for f = 1: numOfFeatures
    ['feature'  num2str(f)]
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
        ['epoch'  num2str(e)] 
        for i = 1:size(trainSet,4)
           userID = trainSet(i,4);
           itemID = trainSet(i,3);
           trueRating = trainSet(i,2);
                           
           [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
            
           error = trueRating - estimatedRating;
               
            tempUF = pUF(userID,f);
            tempIF = qIF(itemID,f);
            
            
            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
            qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            
            userBiases(userID) = userBiases(userID) + lRateUserBias * (error-K*userBiases(userID));
            itemBiases(itemID) = itemBiases(itemID) + lRateItemBias * (error-K*itemBiases(itemID));
         end
    end
 end


% testing
for i = 1: size(testSet,4)
    userID = testSet(i,4);
    itemID = testSet(i,3);
    trueRating = testSet(i,2);
   
    [estimatedRating] =  predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
    ratingsDifferences(i) = trueRating - estimatedRating;
    estimatedRatings(i) = round(estimatedRating);
    estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,2));
 RMSE
 
 
 
 con_mat = confusionmat(testSet(:,2), estimatedRating)
 

%% Calculate confusion matrix
% This should give a 5x5 confusion matrix.
