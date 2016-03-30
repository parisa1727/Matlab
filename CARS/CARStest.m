%% @CARS using MF and using three context as biases Nov2015
% @author: Parisa1727


%% read data- the data is prepared with r- all missing values removed and only incidents with 5 or more observation is kept
% data is devided into 80-20 for training and testing
moviedata = csvread('moviedatacleansort.csv',1,1);
%trainSet = csvread('mtrainSetc.csv',1,1);
%testSet = csvread('mtestSetc.csv',1,1);

%% Initiation

numOfFeatures = 4;
numOfEpochs = 10;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;
conmat = zeros(5,5);

%% 10 fold cross validation

%Indices = crossvalind('Kfold', length(moviedata), 10);
load('indices.mat');
 %n= 1;   
        
for n = 1:10
    test = (Indices == n); 
    train = ~test;
    testSet = moviedata(test,:);
    trainSet = moviedata(train,:);    
n
%% Matrix factorization

% calculate biases
[globalBias, userBiases,userBiasesend,userBiasesdom,userBiasmood,itemBiases] = threecontextbiaswei( trainSet ); 

% training
pUF = zeros(max(moviedata(:,1)),numOfFeatures);
qIF = zeros(max(moviedata(:,2)),numOfFeatures);
 for f = 1: numOfFeatures
     f
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
         e
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           domemo = trainSet(i,11);
           endemo = trainSet(i,10);
           mood = trainSet(i,12);
           trueRating = trainSet(i,3);
            
           [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),globalBias, userBiases(endemo, domemo,mood, userID), itemBiases(itemID));
            
            error = trueRating - estimatedRating;
               
            tempUF = pUF(userID,f);
            tempIF = qIF(itemID,f);
            
            
            pUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
            qIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            
userBiases(endemo, domemo,mood,userID) = userBiases(endemo, domemo,mood, userID) + lRateUserBias * (error-K * userBiases(endemo, domemo,mood, userID));
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
    domemo = testSet(i,11);
    endemo = testSet(i,10);
    mood = testSet(i,12);
    trueRating = testSet(i,3);
        if userID ~= trainSet(:,1)
            userBiases( endemo, domemo,mood, userID) = mean (userBiases);
        end
        if itemID ~= trainSet(:,2)
           itemBiases(itemID) = mean (itemBiases);
        end
    [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:), globalBias, userBiases(endemo, domemo,mood, userID), itemBiases(itemID));
    
    ratingsDifferences(i) = trueRating - estimatedRating;
    estimatedRatings(i) = round(estimatedRating);
    estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RootM(n) = RMSE
 con_mat = confusionmat(testSet(:,3), estimatedRatings);
 conmat = con_mat  + conmat
end

finalRMSE= mean(RootM)
std(RootM)
RootM

