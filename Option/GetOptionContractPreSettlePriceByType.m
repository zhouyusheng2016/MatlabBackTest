function [ price ] = GetOptionContractPreSettlePriceByType( Data, I, type )
% ��ȡ��Ȩ��Լǰ�����
% ����typeѡ������ ���� ���̼۴�������
% ��������ǰ�۸�ʱ�����ÿ��̼۴�������
if I == 1
    price = Data.Open(I);   
    return
end

switch type
    case 'Close'
        price = Data.Close(I-1);
    case 'Settle'
        price = Data.Settle(I-1);
end

end

