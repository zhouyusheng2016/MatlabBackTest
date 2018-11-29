function [TDB flag] = LoadRepoRate(RateTable,RateType,start_time,end_time,Options)

%% 起止日期
start_datenum = datenum(start_time, 'yyyy-mm-dd');
end_datenum = datenum(end_time, 'yyyy-mm-dd');
DataDatenum = datenum(num2str(RateTable.date),'yyyymmdd');
cond1 = DataDatenum>=start_datenum;
cond2 = DataDatenum<=end_datenum;

RateTable = RateTable(cond1 & cond2,:);
RateTable = sortrows(RateTable,'date','ascend');%日期排序
w_wsd_times_0 =unique(datenum(num2str(RateTable.date),'yyyymmdd'));
timeLength = length(w_wsd_times_0);
% 构建期权代码引索表
codes = unique(RateTable.code);
%设置游标
TDB = struct;
for code = codes'
    idx_code_opt = RateTable.code == code;
    thisGC = RateTable(idx_code_opt,:);
    thisGC = sortrows(thisGC,'date','ascend');%日期排序
   
    dataTime = datenum(num2str(thisGC.date),'yyyymmdd');
    DB.Times = w_wsd_times_0;
    DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）
    [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
    %记录C/P 到期日 标的代码
    DB.Code = strcat(RateType,num2str(thisGC.code(1)));
    DB.Type = RateType;
    DB.Period = str2double(DB.Code(end-2:end));% 204001中后三位为到期时限
    % 期权行情信息
    DB.Open = nan(timeLength,1);
    DB.Open(idx_haveData) = thisGC.open;%开
    DB.High = nan(timeLength,1);
    DB.High(idx_haveData) = thisGC.high;%高
    DB.Low = nan(timeLength,1);
    DB.Low(idx_haveData) = thisGC.low;%低
    DB.Close = nan(timeLength,1);
    DB.Close(idx_haveData) = thisGC.close;%收
    DB.Volume = nan(timeLength,1);
    DB.Volume(idx_haveData) = thisGC.volume;%量
    DB.Turnover = nan(timeLength,1);
    DB.Turnover(idx_haveData) = thisGC.turnover;%额
    
    DB.NK = length(DB.Open);

    TDB=setfield(TDB,DB.Code,DB);
end
TDB.Times = w_wsd_times_0;
TDB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）
TDB.NK = length(w_wsd_times_0);
TDB.CurrentK = 1;
flag = 1;

end