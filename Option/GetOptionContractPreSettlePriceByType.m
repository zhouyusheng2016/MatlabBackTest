function [ price ] = GetOptionContractPreSettlePriceByType( Data, I, type )
% 获取期权合约前结算价
% 根据type选择结算价 或是 收盘价代替结算价
% 当不存在前价格时，采用开盘价代替结算价
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

