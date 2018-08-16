function [ price ] = GetOptionContractPreSettlePriceByType( Data, I, type )
% 获取期权合约前结算价
% 根据type选择结算价 或是 收盘价代替结算价
% 当不存在前价格时，采用开盘价代替结算价
if I == 1
    price = Data.Open(I);   
    return
end

% 如本合约不存在前交易状态
if Data.Trade_status(I-1) ==0
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

