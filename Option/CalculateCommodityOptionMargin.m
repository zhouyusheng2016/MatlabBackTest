function [ margin ] = CalculateCommodityOptionMargin(price,underlying,Strike,contractInfo)
% ���ɡ����ǡ�ͭ��Ȩ�Ľ��ױ�֤��
% �������ÿ��λ��֤�𣬺�Լ��֤����Ҫ���� ����������ڻ���Լ���׵�λ������
if strcmp(contractInfo.type,'call')
    otmValue = max(Strike - underlying,0);
elseif strcmp(contractInfo.type,'put')
    otmValue = max(underlying - Strike,0);
else
    error('CalculateMargin.m: Wrong option type c/p')
end

margin = price + max(underlying - otmValue/2, underlying/2);

end
