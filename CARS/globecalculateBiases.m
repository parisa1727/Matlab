function [globalBias, userBiases, itemBiases] = globecalculateBiases( trainSet )

userBiases = zeros(1,max(trainSet(:,4)));
itemBiases = zeros(1,max(trainSet(:,3)));

% global bias
globalBias = mean(trainSet(:,2));

% users' biases
for usr = min(trainSet(:,4)) : max(trainSet(:,4))
    [userIndexes, dummy] = find(trainSet(:,4)==usr);
    if(isempty(userIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(userIndexes,2));
    userBiases(usr) = sumOfRatings/length(userIndexes);
end

userBiases = userBiases - globalBias;

% items' biases
for itm = min(trainSet(:,3)) : max(trainSet(:,3))
    [itemIndexes, dummy] = find(trainSet(:,3)==itm);
    if(isempty(itemIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(itemIndexes,2));
    itemBiases(itm) = sumOfRatings/length(itemIndexes);
end

itemBiases = itemBiases - globalBias;
end