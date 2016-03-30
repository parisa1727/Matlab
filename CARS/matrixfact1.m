% @brief Matrix factorization
%
% @author: Ante Odiæ
%


%% Settings
% <set>
%absoluteRootPath = 'D:\00xBeds\04-MatrixFactorizationMATLABTools';
%dataPath = '02-Data\LDOS';
%toolsPath = '03-Tools';
% </set>

%global testSet;


%addpath(fullfile(absoluteRootPath, dataPath));
%addpath(fullfile(absoluteRootPath, toolsPath));

%varsIds = cell(1, 20);
%varsIds{1} = 'UserID'; varsIds{2} = 'ItemID'; varsIds{3} = 'Rating';
%varsIds{4} = 'Age'; varsIds{5} = 'Sex'; varsIds{6} = 'City';
%varsIds{7} = 'Country'; varsIds{8} = 'Reliability'; varsIds{9} = 'Time';
%varsIds{10} = 'Daytype'; varsIds{11} = 'Season'; varsIds{12} = 'Location';
%varsIds{13} = 'Weather'; varsIds{14} = 'Social'; varsIds{15} = 'EndEmotion';
%varsIds{16} = 'DominantEmotion'; varsIds{17} = 'Mood'; varsIds{18} = 'Physical';
%varsIds{19} = 'Decision'; varsIds{20} = 'Interaction';
% Ante: 9 - 20 so kontekst - potentialy.

numOfFeatures = 6;
numOfEpochs = 29;
learningRate = 0.01;
lRateItemBias = 0.01;
lRateUserBias = 0.0001;
K = 0.005;
initValue = 0.03;


%% Load data
%testSetName = 'LDOScontextTEST.xlsx';
%trainSetName = 'LDOScontextTRAINnoLAST.xlsx';

%testSet = xlsread(fullfile(dataPath, testSetName));
%trainSet = xlsread(fullfile(dataPath, trainSetName));

datafile = 'Rating1M.xls';
trainSet = xlsread(datafile);
datafile2='Rating1Mtest.xlsx';
testSet=xlsread(datafile2);



%% Testing only
%

%% Visualization
%


%% Matrix factorization

% calculate biases
[globalBias, userBiases, itemBiases] = calculateBiases( trainSet );
%for numOfFeatures=16:20
% training
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
        
    [estimatedRating] = predictScore(pUF(userID,:), qIF(itemID,:),...
               globalBias, userBiases(userID), itemBiases(itemID));
    
    ratingsDifferences(i) = trueRating - estimatedRating;
    
      estrateep(userID,itemID) = estimatedRating;     
end

 RMSE = sum(ratingsDifferences.^2);
 RMSE = sqrt(RMSE/size(testSet,1));
 RMSE
%b(1,numOfEpochs)=RMSE;
%a(1, numOfFeatures) = RMSE;
%end


% figure, plot(ubgraf)
% title '220 ratings - user bias'
% figure, plot(ibgraf)
% title '23 ratings - item bias'
%
% figure, plot(pgraf)
% title '220 ratings - user feature'
% figure, plot(qgraf)
% title '23 ratings - item feature'
 


















