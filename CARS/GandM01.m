%This code is written for Globe and Mail project
%Click through rate prediction on auto ads
%Dataset includes data for one month (10,2014)
%Using Matrix Factorization algorithm
%Jan 10 2015 @author Parisa Lak


%% Load and Parse data into train and test set
%reduce dataset



%we are changing sparsity to 10 percent
sample_size = 30000;
desired_density = 2 %1; %Our goal is increasing density of the ratings to 10 percent.
nz_rows = sparsematrixdata(sparsematrixdata(:,3) ~= 0, :);
z_rows = sparsematrixdata(sparsematrixdata(:,3) == 0, :);
less_sparse_matrix = [nz_rows(randsample(length(nz_rows), sample_size* desired_density),:); 
                      z_rows(randsample(length(z_rows), sample_size* (1-desired_density)),:)];
less_sparse_matrix = less_sparse_matrix(randperm(size(less_sparse_matrix,1)),:); % randomize row order

[train,test] = dividerand(sample_size, 0.8, 0.2);



for i =(1:length(test));
    testSet(i,:) = less_sparse_matrix(test(i),:);
end
for j = (1:length(train));
   trainSet(j,:) = less_sparse_matrix(train(j),:);
end


% change the range to 1-5 scale

%OldRange = (OldMax - OldMin)  
%NewRange = (NewMax - NewMin)  
%NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin

testSet (:,4) = testSet(:,3) * 4 + 1;
trainSet (:,4) = trainSet(:,3) * 4 + 1;

% Remove zero rows
TF1 = trainSet(:,1)== 0;
TF2 = trainSet(:,2)== 0;
TFall = TF1 | TF2;
trainSet(TFall,:) = [];

TF1 = testSet(:,1)== 0;
TF2 = testSet(:,2)== 0;
TFall = TF1 | TF2;
testSet(TFall,:) = [];


%Round ratings
testSet (:,4) = ceil(testSet(:,4));
trainSet (:,4) = ceil(trainSet(:,4));

%Click or not click
for i = 1:length(testSet)
    if testSet (i,4) > 1
    testSet(i,4)=2;
    end
   % if testSet(i,1)> max(trainSet(:,1))
    % testSet(i,:) = testSet(1,:);
   % end
end
for i = 1:length(trainSet)
if trainSet (i,4)>1
    trainSet(i,4)=2;
end
end



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
pUF = zeros(max(trainSet(:,1)),numOfFeatures);
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



