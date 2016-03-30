function [globalBias, userBiases, itemBiases] = bias( trainSet )

userBiases = zeros(1,max(trainSet(:,1)));
itemBiases = zeros(1,max(trainSet(:,2)));

% global bias
globalBias = mean(trainSet(:,3));

% users' biases
for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    [userIndexes, dummy] = find(trainSet(:,1)==usr);
    if(isempty(userIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(userIndexes,3));
    userBiases(usr) = sumOfRatings/length(userIndexes);
end

userBiases = userBiases - globalBias;

% items' biases
for itm = min(trainSet(:,2)) : max(trainSet(:,2))
    [itemIndexes, dummy] = find(trainSet(:,2)==itm);
    if(isempty(itemIndexes))
        continue;
    end
    sumOfRatings = sum(trainSet(itemIndexes,3));
    itemBiases(itm) = sumOfRatings/length(itemIndexes);
end

itemBiases = itemBiases - globalBias;
end