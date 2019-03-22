function [TDB flag] = LoadOptionData_Local(OptionDataTable,UnderlyingDataTable,start_time,end_time,Options)
% 截取时间数据
start_datenum = datenum(start_time, 'yyyy-mm-dd');
end_datenum = datenum(end_time, 'yyyy-mm-dd');
optionDataDatenum = datenum(num2str(OptionDataTable.date),'yyyymmdd');
cond1 = optionDataDatenum>=start_datenum;
cond2 = optionDataDatenum<=end_datenum;
OptionDataTable = OptionDataTable(cond1 & cond2,:);
OptionDataTable = sortrows(OptionDataTable,'date','ascend');%日期排序
w_wsd_times_0 =unique(datenum(num2str(OptionDataTable.date),'yyyymmdd'));
timeLength = length(w_wsd_times_0);
% 构建期权代码引索表
codes = unique(OptionDataTable.code);
%设置游标
TDB = struct;
for code = codes'
    idx_code_opt = OptionDataTable.code == code;
    thisOpt = OptionDataTable(idx_code_opt,:);
    thisOpt = sortrows(thisOpt,'date','ascend');%日期排序
   
    dataTime = datenum(num2str(thisOpt.date),'yyyymmdd');
    DB.Times = w_wsd_times_0;
    DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）
    [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
    % 期权合约信息
    structName = code2structname(num2str(code), '50ETFOption');
    DB.Code =  num2str(code);
    %记录C/P 到期日 标的代码
    DB.Info = {thisOpt.OptionType(1) thisOpt.Expiration(1) thisOpt.UnderlyingSymbol(1)};
    % 期权行情信息
    DB.Open = nan(timeLength,1);
    DB.Open(idx_haveData) = thisOpt.open;%开
    DB.High = nan(timeLength,1);
    DB.High(idx_haveData) = thisOpt.high;%高
    DB.Low = nan(timeLength,1);
    DB.Low(idx_haveData) = thisOpt.low;%低
    DB.Close = nan(timeLength,1);
    DB.Close(idx_haveData) = thisOpt.Last;%收
    DB.Volume = nan(timeLength,1);
    DB.Volume(idx_haveData) = thisOpt.Volume;%量
    % 期权行权价格
    DB.Strike = nan(timeLength,1);
    DB.Strike(idx_haveData) = thisOpt.Strike;
    % 期权符号
    DB.Symbol = cell(timeLength,1);
    DB.Symbol(idx_haveData,:) = cellstr(thisOpt.OptionSymbol);
    % 期权合约乘数
    DB.ContractUnit = nan(timeLength,1);
    DB.ContractUnit(idx_haveData) = thisOpt.contractunit;
    % 期权
    % 期权其他信息
    DB.OpenInterest = nan(timeLength,1);
    DB.DaysUntilExpiration = nan(timeLength,1);
    DB.TimeUntilExpiration = nan(timeLength,1);
    DB.InterestRate = nan(timeLength,1);
    DB.ImpliedVolatilityLast = nan(timeLength,1);
    DB.Delta = nan(timeLength,1);
    DB.Gamma = nan(timeLength,1);
    DB.Vega = nan(timeLength,1);
    DB.Theta = nan(timeLength,1);
    DB.hv10 = nan(timeLength,1);
    DB.hv20 = nan(timeLength,1);
    DB.hv30 = nan(timeLength,1);
    DB.hv60 = nan(timeLength,1);
    DB.hv90 = nan(timeLength,1);
    DB.hv120 = nan(timeLength,1);
    DB.hv150 = nan(timeLength,1);
    DB.hv180 = nan(timeLength,1);
    
    DB.OpenInterest(idx_haveData) = thisOpt.OpenInterest;
    DB.DaysUntilExpiration(idx_haveData)= thisOpt.DaysUntilExpiration;
    DB.TimeUntilExpiration(idx_haveData)= thisOpt.TimeUntilExpiration;
    DB.InterestRate(idx_haveData)= thisOpt.InterestRate;
    DB.ImpliedVolatilityLast(idx_haveData)= thisOpt.ImpliedVolatilityLast;
    DB.Delta(idx_haveData)= thisOpt.Delta;
    DB.Gamma(idx_haveData)= thisOpt.Gamma;
    DB.Vega(idx_haveData)= thisOpt.Vega;
    DB.Theta(idx_haveData)= thisOpt.Theta;
    DB.hv10(idx_haveData)= thisOpt.hv10;
    DB.hv20(idx_haveData)= thisOpt.hv20;
    DB.hv30(idx_haveData)= thisOpt.hv30;
    DB.hv60(idx_haveData)= thisOpt.hv60;
    DB.hv90(idx_haveData)= thisOpt.hv90;
    DB.hv120(idx_haveData)= thisOpt.hv120;
    DB.hv150(idx_haveData)= thisOpt.hv150;
    DB.hv180(idx_haveData)= thisOpt.hv180;
    DB.Trade_status = zeros(timeLength,1);
    DB.Trade_status(idx_haveData) = 1;
    DB.NK = length(DB.Open);%行情数据量
    
    TDB=setfield(TDB,structName,DB);
end
TDB.Times = w_wsd_times_0;
TDB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）

% 导入标的数据
underlyingDataDatenum = datenum(UnderlyingDataTable.Date);
cond1 = underlyingDataDatenum>=start_datenum;
cond2 = underlyingDataDatenum<=end_datenum;
UnderlyingDataTable = UnderlyingDataTable(cond1&cond2,:);

Underlying.Times = datenum(UnderlyingDataTable.Date);
Underlying.TimesStr = datestr(Underlying.Times,'yymmdd');
Underlying.Open = UnderlyingDataTable.Open;
Underlying.High = UnderlyingDataTable.High;
Underlying.Low = UnderlyingDataTable.Low;
Underlying.Close = UnderlyingDataTable.Close;
Underlying.Volume = UnderlyingDataTable.Volume;
Underlying.Vwap = UnderlyingDataTable.Vwap;
Underlying.PreClose = UnderlyingDataTable.PreClose;
Underlying.AdjFactor = UnderlyingDataTable.AdjFactor;

TDB=setfield(TDB,'Underlying',Underlying);
TDB.CurrentK = 1;
TDB.NK = length(Underlying.Times);
% 
TradeableOptionField = cell(TDB.NK,1);
fields = fieldnames(TDB);
OptionFileds = fields(1:end-5);
for i = 1:TDB.NK 
    fieldNames = GetTradeableOptions(TDB, i, OptionFileds);
    TradeableOptionField{i} = fieldNames;
end
TDB.TradeableOptionField = TradeableOptionField;
%数据加载成功
flag=1;