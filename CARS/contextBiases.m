function [globalBias, userBiases, itemBiases] = contextBiases( moviedata )

userBiases = zeros(max(moviedata(:,10)),max(moviedata(:,1)));
itemBiases = zeros(1,max(moviedata(:,2)));


% global bias
globalBias = mean(moviedata(:,3));
  

% users' biases
for usr = min(moviedata(:,1)) : max(moviedata(:,1))
    for endemo = min(moviedata(:,10)) : max(moviedata(:,10))
        
    [userIndexes, dummy] = find(moviedata(:,1)==usr & moviedata(:,10)== endemo);
    if(isempty(userIndexes))
        continue;
    end
  
    sumOfRatings = sum(moviedata(userIndexes,3));
    userBiases(endemo,usr) = sumOfRatings/length(userIndexes);
    end
     x = mean (userBiases(:,usr));    
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