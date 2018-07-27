function HisDB = HisOptionData(DB,windcode,Options)
I = DB.CurrentK;
HisDB = DB;
HisDB.Times = HisDB.Times(1:I,:);
HisDB.TimesStr = HisDB.TimesStr(1:I,:);
for i=1:max(size(windcode))
    stock = num2str(windcode{i});
    structName = code2structname(stock, 'O');
    Data=getfield(HisDB, structName);
    
    Data.Times = Data.Times(1:I,:);
    Data.TimesStr = Data.TimesStr(1:I,:);
    
    Data.Trade_status = Data.Trade_status(1:I,:);

    Data.Open = Data.Open(1:I,:);
    Data.High = Data.High(1:I,:);
    Data.Low = Data.Low(1:I,:);
    Data.Close = Data.Close(1:I,:);
    Data.Volume = Data.Volume(1:I,:);
    
    Data.OpenInterest = Data.OpenInterest(1:I,:);
    Data.contractunit = Data.contractunit(1:I,:);
    Data.DaysUntilExpiration = Data.DaysUntilExpiration(1:I,:);
    Data.TimeUntilExpiration = Data.TimeUntilExpiration(1:I,:);
    Data.InterestRate = Data.InterestRate(1:I,:);
    Data.ImpliedVolatilityLast = Data.ImpliedVolatilityLast(1:I,:);
    Data.Delta = Data.Delta(1:I,:);
    Data.Gamma = Data.Gamma(1:I,:);
    Data.Vega = Data.Vega(1:I,:);
    Data.Theta = Data.Theta(1:I,:);
    Data.hv10 = Data.hv10(1:I,:);
    Data.hv20 = Data.hv20(1:I,:);
    Data.hv30 = Data.hv30(1:I,:);
    Data.hv60 = Data.hv60(1:I,:);
    Data.hv90 = Data.hv90(1:I,:);
    Data.hv120 = Data.hv120(1:I,:);
    Data.hv150 = Data.hv150(1:I,:);
    Data.hv180 = Data.hv180(1:I,:);
    
    
    HisDB=setfield(HisDB,structName,Data);
end