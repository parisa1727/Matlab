% @brief Matrix factorization test 
%cluster based
%
% @author: Parisa
%


%% Settings
% <set>
%absoluteRootPath = 'D:\00xBeds\04-MatrixFactorizationMATLABTools';
%dataPath = '02-Data\LDOS';
%toolsPath = '03-Tools';
% </set>

%global testSet;




numOfFeatures =6;
numOfEpochs = 10;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;


%% Load data and parse data

%data = textread(datafile);
%[train,test] = dividerand(1000209,0.8,0.2);
%for i =(1:length(test));
 %   testSet(i,:) = data(test(i),:);
%end
%for j = (1:length(train));
  % trainSet(j,:) = data(train(j),:);
%end

%%datafile = 'Rating1M.xls';
%%trainSet = xlsread(datafile);
%%datafile2='Rating1Mtest.xlsx';
%%testSet=xlsread(datafile2);




%% Matrix factorization

% calculate biases
%globalBias = mean(trainSet(:,3));
[globalBias, userBiases, itemBiases] = calculateBiases( trainSet );
%for numOfEpochs=29:32
%numOfEpochs=33
% training
%for numOfFeatures = (1:20)
pUF = zeros(max(trainSet(:,1)),numOfFeatures);
qIF = zeros(max(trainSet(:,2)),numOfFeatures);

 for f = 1: numOfFeatures
    % f
    pUF (:,f) = initValue;
    qIF (:,f) = initValue;
     for e = 1:numOfEpochs
         e
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           trueRating = trainSet(i,6);
            
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
     estimatedRatings(i) = round(estimatedRating);
      estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RMSE
 
 %%Clusrering based on pUF (user)
 class = kmeans(pUF,20);
 for i =1:length(class)
 class(i,2) = i;
 end
 
 for m = 1 : length(trainSet)
     for n =1:length(class)
     if trainSet(m,1) == class(n,2)
         trainSet(m,5) =class (n,1);
     end
     end
 end
 
 newrating = 0;
for i =1:20
    for m =1:length(trainSet)
    if trainSet(m,5)== i
        newrating=(trainSet(m,3)+newrating)/2;
        
    end
    end
    ratings(i,:) = newrating;
end

for i =1:20
    for m =1:length(trainSet)
    if trainSet(m,5)== i
        trainSet(m,6)=ratings(i,1);
        
    end
    end
    
end

 
 %%
 %change rating to mean of rating in each cluster
 
 trainSet(:,5)= class;
 
 %changing user latent based on clusters
 
 for m= 1: length(pUF)  
     pUF(m,8) = mean (pUF(m,1:6)); 
 end
 

 for m = 1:length (pUF)
     pUF(m,9)= pUF(m,8);
      for n= 1:length(pUF)
          if pUF(m,7)== pUF(n,7)
              pUF(n,9:14)= pUF(m,1:6) ;
          end
      end
 end
  
 pUFnew = zeros(length(pUF),numOfFeatures);
 for i= 1:length( pUFnew)
pUFnew(i,7) = mean(pUFnew(i,1:6));
 end
 
 mypUF=pUFnew(:,7);
 
 for i =1:length(qIF)
     qIF(i,7) = mean(qIF(i,1:6));
 end
 myqIF = qIF(:,7);
 
 
   for e = 1:numOfEpochs
         e
        for i = 1:size(trainSet,1)
           userID = trainSet(i,1);
           itemID = trainSet(i,2);
           trueRating = trainSet(i,3);
            
           [estimatedRating] = predictScore(mypUF(userID,:), myqIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
            
           
  
            error = trueRating - estimatedRating;
               
            tempUF = mypUF(userID,f);
tempIF = myqIF(itemID,f);
            
            
            mypUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
myqIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;

            mypUF(userID,f) = tempUF + (error * tempIF - K * tempUF) * learningRate;
myqIF(itemID,f) = tempIF + (error * tempUF - K * tempIF) * learningRate;
            
userBiases(userID) = userBiases(userID) + lRateUserBias * (error-K*userBiases(userID));
itemBiases(itemID) = itemBiases(itemID) + lRateItemBias * (error-K*itemBiases(itemID));
         end
    end




% validating
for i = 1: size(testSet,1)
    userID = testSet(i,1);
    itemID = testSet(i,2);
    trueRating = testSet(i,3);
        
    [estimatedRating] = predictScore(mypUF(userID,:), myqIF(itemID,:),globalBias, userBiases(userID), itemBiases(itemID));
    
    ratingsDifferences(i) = trueRating - estimatedRating;
     estimatedRatings(i) = round(estimatedRating);
      estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RMSE
 
%b(1,numOfEpochs)=RMSE;
%a(1, numOfFeatures) = RMSE;
%end
%% Calculate confusion matrix
% This should give a 5x5 confusion matrix.
%RMSE =

    0.9080

% figure, plot(ubgraf)
% title '220 ratings - user bias'
% figure, plot(ibgraf)
% title '23 ratings - item bias'
%
% figure, plot(pgraf)
% title '220 ratings - user feature'
% figure, plot(qgraf)
% title '23 ratings - item feature'
 


















