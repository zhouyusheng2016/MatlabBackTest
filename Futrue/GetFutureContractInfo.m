function struct = GetFutureContractInfo(Data)

initialMargin = Data.Info{4}/100; %���ױ�֤
str = Data.Info{9};
if length(str) == 16
    marginRate = str2double(str(end-2:end-1))/100;%������ױ�֤��
elseif length(str) == 15
    marginRate = str2double(str(end-1))/100;%������ױ�֤��
else
    error('GetFutureContractInfo.m line 10, Undefined String Reading')
end
if isnan(marginRate)
    error('GetFutureContractInfo.m line 14: initialMargin read ERROR')
end
contractMultiplier = Data.Info{8};% Ʒ�ֺ�Լ����

struct.mmargin = marginRate;
struct.imargin = initialMargin;
struct.multiplier = contractMultiplier;
end