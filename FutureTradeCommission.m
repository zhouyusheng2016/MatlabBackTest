function  dealfee = FutureTradeCommission( price, vol, contractInfo, Options,Type)
if strcmp(Type,'Open')%��
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.Commission);
elseif strcmp(Type,'CloseToday')%��ƽ
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.CloseTodayCommission);
elseif strcmp(Type,'CloseYesterday')%��ƽ
    dealfee = max(Options.MinCommission, abs(vol)*price*contractInfo.multiplier*Options.CloseYesterdayCommission);
end
end

