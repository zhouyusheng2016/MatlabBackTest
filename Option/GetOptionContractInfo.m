function [ info ] = GetOptionContractInfo( Data )
%��ȡ��Ȩ��Լ����Ϣ
info.type = char(Data.Info{1});
info.datetime = Data.Info{2};
info.underlyingCode = num2str(Data.Info{3});
end

