function [ margin ] = Calculate50ETFOptionMargin(price,underlying,Strike,contractInfo)
% ����
if strcmp(contractInfo.type,'call')
    margin = Calculate50ETFCallMargin(price,underlying,Strike);
elseif strcmp(contractInfo.type,'put')
    margin = Calculate50ETFPutMargin(price,underlying,Strike);
else
    error('CalculateMargin.m: Wrong option type c/p')
end

end