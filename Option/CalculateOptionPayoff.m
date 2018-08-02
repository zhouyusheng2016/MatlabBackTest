function [ payoff ] = CalculateOptionPayoff( S, K, contractInfo,contractUnit, position)
if strcmp(contractInfo.type,'call')
    payoff = max(S - K, 0);
elseif strcmp(contractInfo.type,'put')
    payoff = max(K - S, 0);
else
    error('CalculateOptionPayoff.m : option type error')
end
payoff = payoff*contractUnit*position;
end

