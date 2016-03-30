function [globalBias, userBiases, itemBiases] = calculateBiases( moviedata )

userBiases = zeros(1,max(moviedata(:,1)));
itemBiases = zeros(1,max(moviedata(:,2)));


% global bias
globalBias = mean(moviedata(:,3));

% users' biases
for usr = min(moviedata(:,1)) : max(moviedata(:,1))
    [userIndexes, dummy] = find(moviedata(:,1)==usr);
    if(isempty(userIndexes))
        continue;
    end
    sumOfRatings = sum(moviedata(userIndexes,4));
    userBiases(usr) = sumOfRatings/length(userIndexes);
end

userBiases = userBiases - globalBias;

% items' biases
for itm = min(moviedata(:,2)) : max(moviedata(:,2))
    [itemIndexes, dummy] = find(moviedata(:,2)==itm);
    if(isempty(itemIndexes))
        continue;
    end
    sumOfRatings = sum(moviedata(itemIndexes,4));
    itemBiases(itm) = sumOfRatings/length(itemIndexes);
end

itemBiases = itemBiases - globalBias;
end