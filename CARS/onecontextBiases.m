%biases 
function [globalBias, userBiases, itemBiases] = onecontextBiases( trainSet )

userBiases = zeros(max(trainSet(:,9)),max(trainSet(:,1))); 
itemBiases = zeros(1,max(trainSet(:,2)));


% global bias
globalBias = mean(trainSet(:,3));
  

% users' biases
for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,9)) : max(trainSet(:,9))
        
    [userIndexes, dummy] = find(trainSet(:,1)==usr & trainSet(:,9)==endemo); 
    if(isempty(userIndexes))
        continue;
    end

    sumOfRatings = sum(trainSet(userIndexes,3));
    userBiases(endemo, usr) = sumOfRatings/length(userIndexes);
         
    end  
end

 for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,9)) : max(trainSet(:,9))    
    if (userBiases(endemo,usr) == 0)
        userBiases(endemo,usr)= (mean(userBiases(:,usr)));
    end
 
    end
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