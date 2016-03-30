function [globalBias, userBiases, itemBiases] = calculateBiases( trainSet )

userBiases = zeros(1,max(trainSet(:,3)));
itemBiases = zeros(1,max(trainSet(:,2)));


% global bias
globalBias = mean(trainSet(:,1));

% users' biases
for usr = min(trainSet(:,3)) : max(trainSet(:,3))
    [userIndexes, dummy] = find(trainSet(:,3)==usr);
    if(isempty(userIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(userIndexes,1));
    userBiases(usr) = sumOfRatings/length(userIndexes);
end

userBiases = userBiases - globalBias;

% items' biases
for itm = min(trainSet(:,2)) : max(trainSet(:,2))
    [itemIndexes, dummy] = find(trainSet(:,2)==itm);
    if(isempty(itemIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(itemIndexes,1));
    itemBiases(itm) = sumOfRatings/length(itemIndexes);
end

itemBiases = itemBiases - globalBias;
end