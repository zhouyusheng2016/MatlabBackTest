function [Underlying] = GetCommodityOptionUnderlyingStruct(OptDB, DB)
% ��ȡ��Ʒ��Ȩ��ķ���

thisOptContractInfo = GetOptionContractInfo(DB);
str = split(thisOptContractInfo.underlyingCode,'.');
underlyingCode = str{1};
Underlying = getfield(OptDB.Underlying,underlyingCode);
end