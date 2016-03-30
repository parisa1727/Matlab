%This code is written hospital experiment project
%missing value prediction
%Dataset all skills (10,2014)
%Using Matrix Factorization algorithm
%Sep 2 2015 @author Parisa Lak


%% Load and Parse data into train and test set
%reduce dataset
%already done in R


%% Matrix Factoization

% Set initial values
numOfFeatures = 3; 
numOfEpochs = 29;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;

                          


% calculate biases
[globalBias, userBiases, itemBiases] = calculateBiases( trainSet );
% training
pUF = zeros(max(train(:,1)),numOfFeatures);
qIF = zeros(max(trainSet(:,2)),numOfFeatures);

 for f = 1: numOfFeatures
    ['feature'  num2str(f)]
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
        ['epoch'  num2str(e)] 
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           trueRating = trainSet(i,4);
                           
           [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
            
           error = trueRating - estimatedRating;
               
            tempUF = pUF(userID,f);
            tempIF = qIF(itemID,f);
            
            
            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
            qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            %pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
            %qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;
            
            userBiases(userID) = userBiases(userID) + lRateUserBias * (error-K*userBiases(userID));
            itemBiases(itemID) = itemBiases(itemID) + lRateItemBias * (error-K*itemBiases(itemID));
         end
    end
 end


% testing
for i = 1: size(testSet,1)
    userID = testSet(i,1);
    itemID = testSet(i,2);
    trueRating = testSet(i,4);
        
    [estimatedRating] =  predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
    ratingsDifferences(i) = trueRating - estimatedRating;
    estimatedRatings(i) = round(estimatedRating);
    estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RMSE

%% Calculate confusion matrix
% This should give a 5x5 confusion matrix.
con_mat = confusionmat(testSet(:,4)', estimatedRatings)



