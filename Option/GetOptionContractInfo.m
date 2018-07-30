function [ info ] = GetOptionContractInfo( Data )
%获取期权合约的信息
info.type = char(Data.Info{1});
info.datetime = Data.Info{2};
info.underlyingCode = num2str(Data.Info{3});
end

