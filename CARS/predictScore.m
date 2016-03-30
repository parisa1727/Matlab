
function [estimatedScore] = predictScore(p,q ,globalBias, userBiases, itemBiases)

estimatedScore = globalBias + userBiases + itemBiases + p*q';

if estimatedScore<1
    estimatedScore=1;
elseif estimatedScore>5
    estimatedScore =5;
end


end