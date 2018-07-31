function [ price ] = GetUnderlyingLastPrice(DB, type)
switch (type) 
    case 'Close'
        price = DB.Underlying.Close(DB.CurrentK-1);
    case 'Settle'
        price = DB.Underlying.Settle(DB.CurrentK-1);        
end
end

