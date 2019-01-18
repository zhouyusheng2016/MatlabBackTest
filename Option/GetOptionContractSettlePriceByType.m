function [ price ] = GetOptionContractSettlePriceByType( Data, I, type )
switch type
    case 'Close'
        price = Data.Close(I);
    case 'Settle'
        price = Data.Settle(I);
    otherwise
        error('Error in Options.SettlementType')
end
end