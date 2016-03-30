numOfFeatures = 35
    
pUF = zeros(max(trainSet(:,1)),numOfFeatures);
qIF = zeros(max(trainSet(:,2)),numOfFeatures);

 for f = 1: numOfFeatures
    % f
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
         %e
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           trueRating = trainSet(i,3);
            
           [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
            
           
  
            error = trueRating - estimatedRating;
               
            tempUF = pUF(userID,f);
tempIF = qIF(itemID,f);
            
            
            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;
            
userBiases(userID) = userBiases(userID) + lRateUserBias * (error-K*userBiases(userID));
itemBiases(itemID) = itemBiases(itemID) + lRateItemBias * (error-K*itemBiases(itemID));
         end
    end
 end


% validating
for i = 1: size(testSet,1)
    userID = testSet(i,1);
    itemID = testSet(i,2);
    trueRating = testSet(i,3);
        
    [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
    
    ratingsDifferences(i) = trueRating - estimatedRating;
    
      estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RMSE
b(1,numOfEpochs)=RMSE;
%a(1, numOfFeatures) = RMSE;