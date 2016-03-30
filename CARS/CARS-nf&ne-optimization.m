%% @CARS using MF and optimizing on Ldos comoda dataset
% @author: Parisa1727


%% read data- the data is prepared with r- all missing values removed and only incidents with 5 or more observation is kept
%data is devided into 80-20 for training and testing
moviedata = csvread('moviedatacleansort.csv',1,1);
%trainSet = csvread('mtrainSetc.csv',1,1);
%testSet = csvread('mtestSetc.csv',1,1);

%% Initiation

%numOfFeatures = 4;
%numOfEpochs = 10;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;


%% Matrix factorization

%% 10 fold cross validation

%Indices = crossvalind('Kfold', length(moviedata), 10);
load('indices.mat');

for numOfFeatures = 2:10
    for numOfEpochs = 2:100
for n = 1:10
    test = (Indices == n); 
    train = ~test;
    testSet = moviedata(test,:);
    trainSet = moviedata(train,:);    
n
%% Matrix factorization

% calculate biases
[globalBias, userBiases, itemBiases] = calculateBiasesnew( trainSet );

% training
pUF = zeros(max(moviedata(:,1)),numOfFeatures);
qIF = zeros(max(moviedata(:,2)),numOfFeatures);
 for f = 1: numOfFeatures
     %f
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
         %e
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           %domemo = trainSet(i,6);
          % endemo= trainSet(i,10);
           trueRating = trainSet(i,3);
            
           [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases( userID), itemBiases(itemID));
            
           
  
            error = trueRating - estimatedRating;
               
            tempUF = pUF(userID,f);
            tempIF = qIF(itemID,f);
            
            
            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
            qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            
userBiases( userID) = userBiases( userID) + lRateUserBias * (error-K*userBiases( userID));
itemBiases(itemID) = itemBiases(itemID) + lRateItemBias * (error-K*itemBiases(itemID));
         end
    end
 end

 estimatedRatings = zeros (1,size(testSet,1));
 ratingsDifferences = zeros (1,size(testSet,1));
% testing
for i = 1: size(testSet,1)
    userID = testSet(i,1);
    itemID = testSet(i,2);
    %domemo = testSet(i,6);
    %endemo= testSet(i,10);
    trueRating = testSet(i,3);
        if (userID ~= trainSet(:,1))
          %  if (endemo ~= trainSet(:,10))
            userBiases( userID) = mean (userBiases(userID));
           % end
        end
        if itemID ~= trainSet(:,2)
           itemBiases(itemID) = mean (itemBiases);
        end
        
    [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:), globalBias, userBiases( userID), itemBiases(itemID));
    
    ratingsDifferences(i) = trueRating - estimatedRating;
    estimatedRatings(i) = round(estimatedRating);
    estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RootM(n) = RMSE;
 

 finalRMSE((numOfFeatures-1), (numOfEpochs-1))= mean(RootM)
end
    end
end

