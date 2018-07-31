function [ margin ] = CalculateMargin(price,underlying,Strike,contractInfo)
% º∆À„
if strcmp(contractInfo.type,'call')
    margin = CalculateCallMargin(price,underlying,Strike);
elseif strcmp(contractInfo.type,'put')
    margin = CalculatePutMargin(price,underlying,Strike);
else
    error('CalculateMargin.m: Wrong option type c/p')
end

end

