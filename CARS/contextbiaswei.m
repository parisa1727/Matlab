%biases for two context%
function [globalBias, userBiases,userBiasesend,userBiasesdom, itemBiases] = contextbiaswei( trainSet )

userBiasesend = zeros(max(trainSet(:,12)),max(trainSet(:,1)));
userBiasesdom = zeros(max(trainSet(:,11)),max(trainSet(:,1)));
userBiases = zeros(max(trainSet(:,12)),max(trainSet(:,11)), max(trainSet(:,1)));
itemBiases = zeros(1,max(trainSet(:,2)));


% global bias
globalBias = mean(trainSet(:,3));
  

% users' biases
for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,12)) : max(trainSet(:,12))        
    [userIndexes, dummy] = find(trainSet(:,1)==usr & trainSet(:,12)==endemo);
        if(isempty(userIndexes))
        continue;
        end
    sumOfRatings = sum(trainSet(userIndexes,3));
    userBiasesend(endemo,usr) = sumOfRatings/length(userIndexes);
    end
    for domemo = min(trainSet(:,11)) : max(trainSet(:,11))  
        [userIndexes, dummy] = find(trainSet(:,1)==usr & trainSet(:,11)==domemo);
        if(isempty(userIndexes))
        continue;
        end
    sumOfRatings = sum(trainSet(userIndexes,3));
    userBiasesdom(domemo,usr) = sumOfRatings/length(userIndexes);
    end
end   
    

 for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,12)) : max(trainSet(:,12))    
    if (userBiasesend(endemo,usr) == 0)
        userBiasesend(endemo, usr)= mean(userBiasesend(:,usr));
    end
    end
 

    for domemo =min(trainSet(:,11)) : max(trainSet(:,11))
    if (userBiasesdom(domemo,usr) == 0)
        userBiasesdom(domemo, usr)= mean(userBiasesdom(:,usr));
    end
   end
    
end

 
 

       for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,12)) : max(trainSet(:,12))
        for domemo =min(trainSet(:,11)) : max(trainSet(:,11))

    userBiases(endemo,domemo,usr) = (0.7645 * (userBiasesend(endemo,usr)) +  0.2355 * (userBiasesdom (domemo, usr)));
        end
    end
       end
  

   for usr = min(trainSet(:,1)) : max(trainSet(:,1))
    for endemo =min(trainSet(:,12)) : max(trainSet(:,12))
       for domemo =min(trainSet(:,11)) : max(trainSet(:,11))
        if (userBiases(endemo,domemo,usr) == 0)
        userBiases(endemo,domemo, usr)= (mean(mean(userBiases(:,:,usr))));
         end
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