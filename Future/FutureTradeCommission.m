function  dealfee = FutureTradeCommission( price, vol, contractInfo, Options,Type)
if strcmp(Type,'Open')%今开
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.Commission);
elseif strcmp(Type,'CloseToday')%今平
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.CloseTodayCommission);
elseif strcmp(Type,'CloseYesterday')%昨平
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.CloseYesterdayCommission);
end
end

