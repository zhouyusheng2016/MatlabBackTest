function [ price ] = GetOptionContractPreSettlePriceByType( Data, I, type )
% ��ȡ��Ȩ��Լǰ�����
% ����typeѡ������ ���� ���̼۴�������
% ��������ǰ�۸�ʱ�����ÿ��̼۴�������
switch type
    case 'Close'
        if I == 1
            price = Data.Open(I);
        elseif Data.Trade_status(I-1) ==0
            price = Data.Open(I);
        else
            price = Data.Close(I-1);
        end
    case 'Settle'
        if I == 1
            price = Data.Open(I);
        elseif Data.Trade_status(I-1) ==0
            price = Data.Open(I);
        else
            price = Data.Settle(I-1);
        end
    case 'PreClose'
        price = Data.PreClose(I);
    case 'PreSettle'
        price = Data.PreSettle(I);
    otherwise
        error('Error in Options.LastSettlementType')
end

end

