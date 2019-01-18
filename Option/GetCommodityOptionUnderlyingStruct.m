function [Underlying] = GetCommodityOptionUnderlyingStruct(OptDB, DB)
% 获取商品期权标的凡是

thisOptContractInfo = GetOptionContractInfo(DB);
str = split(thisOptContractInfo.underlyingCode,'.');
underlyingCode = str{1};
Underlying = getfield(OptDB.Underlying,underlyingCode);
end