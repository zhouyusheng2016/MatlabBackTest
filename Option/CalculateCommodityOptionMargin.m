function [ margin ] = CalculateCommodityOptionMargin(price,underlying,underlyingMargin,Strike,contractInfo)
% 豆粕、白糖、铜期权的交易保证金
% 计算的是每单位保证金，合约保证金需要乘以 ！！！标的期货合约交易单位！！！
if strcmp(contractInfo.type,'call')
    otmValue = max(Strike - underlying,0);
elseif strcmp(contractInfo.type,'put')
    otmValue = max(underlying - Strike,0);
else
    error('CalculateMargin.m: Wrong option type c/p')
end

margin = price + max(underlyingMargin - otmValue/2, underlyingMargin/2);

end

