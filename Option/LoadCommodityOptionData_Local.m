function [TDB flag] = LoadCommodityOptionData_Local(OptionDataTable,UnderlyingDataTable,start_time,end_time,contractunit,Options)
% ��ȡʱ������
start_datenum = datenum(start_time, 'yyyy-mm-dd');
end_datenum = datenum(end_time, 'yyyy-mm-dd');
% ��Ȩ����
optionDataDatenum = datenum(num2str(OptionDataTable.date),'yyyymmdd');
cond1 = optionDataDatenum>=start_datenum;
cond2 = optionDataDatenum<=end_datenum;
OptionDataTable = OptionDataTable(cond1 & cond2,:);
OptionDataTable = sortrows(OptionDataTable,'date','ascend');%��������
% �������
underlyingDataDatenum = unique(datenum(UnderlyingDataTable.date));
underlyingDataDatenum = underlyingDataDatenum(underlyingDataDatenum>=start_datenum & ...
    underlyingDataDatenum<=end_datenum);
optionDataDatenum = unique(datenum(num2str(OptionDataTable.date),'yyyymmdd'));

w_wsd_times_0 = unique([optionDataDatenum;underlyingDataDatenum]);
timeLength = length(w_wsd_times_0);
%% ��Ȩ����
codes = unique(OptionDataTable.code);
TDB = struct;
for code = codes'
    DB = struct();
    idx_code_opt = OptionDataTable.code == code;
    thisOpt = OptionDataTable(idx_code_opt,:);
    thisOpt = sortrows(thisOpt,'date','ascend');%��������
   
    dataTime = datenum(num2str(thisOpt.date),'yyyymmdd');
    DB.Times = w_wsd_times_0;
    DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�
    [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
    % ��Ȩ��Լ��Ϣ
    structName = char(code);
    DB.Code =  structName;
    %��¼C/P ������ ��Ĵ���
    DB.Info = {thisOpt.OptionType(1)...
        datetime(num2str(thisOpt.Expiration(1)),'InputFormat','yyyyMMdd')...
        thisOpt.UnderlyingSymbol(1,:)};
    % ��Ȩ������Ϣ
    DB.Open = nan(timeLength,1);
    DB.Open(idx_haveData) = thisOpt.open;%��
    DB.High = nan(timeLength,1);
    DB.High(idx_haveData) = thisOpt.high;%��
    DB.Low = nan(timeLength,1);
    DB.Low(idx_haveData) = thisOpt.low;%��
    DB.Close = nan(timeLength,1);
    DB.Close(idx_haveData) = thisOpt.close;%��
    DB.Volume = nan(timeLength,1);
    DB.Volume(idx_haveData) = thisOpt.volume;%��
    DB.Strike = nan(timeLength,1);
    DB.Strike(idx_haveData) = thisOpt.Strike;
    DB.Settle = nan(timeLength,1);
    DB.Settle(idx_haveData) = thisOpt.settle;%��
    DB.PreSettle = nan(timeLength,1);
    DB.PreSettle(idx_haveData) = thisOpt.PreSettle;%��
    % ��Ȩ��Լ����
    DB.ContractUnit = nan(timeLength,1);
    DB.ContractUnit(idx_haveData) = contractunit;
    % ��Ȩ
    % ��Ȩ������Ϣ
    DB.OpenInterest = nan(timeLength,1);
    DB.OpenInterest(idx_haveData) = thisOpt.openinterest;
    DB.DaysUntilExpiration = nan(timeLength,1);
    DB.DaysUntilExpiration(idx_haveData)= datenum(DB.Info{2}) - DB.Times(idx_haveData);
    DB.TimeUntilExpiration = nan(timeLength,1);
    DB.TimeUntilExpiration(idx_haveData)= DB.DaysUntilExpiration(idx_haveData)/365;
    DB.InterestRate = nan(timeLength,1);
    DB.InterestRate(idx_haveData)= thisOpt.InterestRate;
    
    DB.Trade_status = zeros(timeLength,1);
    DB.Trade_status(idx_haveData) = 1;
    DB.NK = length(DB.Open);%����������
    
    TDB=setfield(TDB,structName,DB);
end
TDB.Times = w_wsd_times_0;
TDB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�

%% �������
UnderlyingDataTable = sortrows(UnderlyingDataTable,'date','ascend');
underlyingDataDatenum = datenum(UnderlyingDataTable.date);
cond1 = underlyingDataDatenum>=start_datenum;
cond2 = underlyingDataDatenum<=end_datenum;
UnderlyingDataTable = UnderlyingDataTable(cond1&cond2,:);

codes = unique(UnderlyingDataTable.code);
Underlying = struct;
for code = codes'
   idx_code_underlying = UnderlyingDataTable.code==code;
   thisUnderlying = UnderlyingDataTable(idx_code_underlying,:);
   dataTime = datenum(thisUnderlying.date);
   DB = struct;
   DB.Times = w_wsd_times_0;
   DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�
   [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
   
   codeSplit = split(char(code),'.');
   structName = codeSplit{1};
   DB.Times = w_wsd_times_0;
   DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');
   DB.Open = nan(timeLength,1);
   DB.Open(idx_haveData) = thisUnderlying.open;
   DB.High = nan(timeLength,1);
   DB.High(idx_haveData) = thisUnderlying.high;
   DB.Low = nan(timeLength,1);
   DB.Low(idx_haveData) = thisUnderlying.low;
   DB.Close = nan(timeLength,1);
   DB.Close(idx_haveData) = thisUnderlying.close;
   DB.Volume = nan(timeLength,1);
   DB.Volume(idx_haveData) = thisUnderlying.volume;
   DB.Vwap = nan(timeLength,1);
   DB.Vwap(idx_haveData) = thisUnderlying.vwap;
   DB.PreClose = nan(timeLength,1);
   DB.PreClose(idx_haveData) = thisUnderlying.pre_close;
   DB.Settle = nan(timeLength,1);
   DB.Settle(idx_haveData) = thisUnderlying.settle;
   DB.PreSettle = nan(timeLength,1);
   DB.PreSettle(idx_haveData) = thisUnderlying.pre_settle;
   DB.ContractUnit = nan(timeLength,1);
   DB.ContractUnit(idx_haveData) = thisUnderlying.contractmultiplier;
   DB.Margin = nan(timeLength,1);
   DB.Margin(idx_haveData) = thisUnderlying.margin;
   
   Underlying=setfield(Underlying,structName,DB);
end
TDB=setfield(TDB,'Underlying',Underlying);

%% �α�����
TDB.CurrentK = 1;
TDB.NK = length(w_wsd_times_0);
% 
TradeableOptionField = cell(TDB.NK,1);
fields = fieldnames(TDB);
OptionFileds = fields(1:end-6);
for i = 1:TDB.NK 
    fieldNames = GetTradeableOptions(TDB, i, OptionFileds);
    TradeableOptionField{i} = fieldNames;
end
TDB.TradeableOptionField = TradeableOptionField;
%���ݼ��سɹ�
flag=1;