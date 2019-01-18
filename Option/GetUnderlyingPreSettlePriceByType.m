function [ price ] = GetUnderlyingPreSettlePriceByType( Data, I, type )

switch type
    case 'Close'
        if I == 1
            price = Data.Open(I);
        else
            price = Data.Close(I-1);
        end
    case 'Settle'
        if I == 1
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