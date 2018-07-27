function [DB flag] = FutureMarketData(w,windcode,start_time,end_time,Options)
% 单一数据
if ischar(windcode)
    % 定位游标位置到第一条K线
    DB.CurrentK = 1;
    isRealContract = length(windcode) == 10; % 连续合约为8位,
    [Data, flag] = LoadFutureData(w,windcode,start_time,end_time,isRealContract,Options);
    DB=setfield(DB,code2structname(windcode,'F'),Data);
    if flag==0
        disp('=== Back test shutting down! ===')
        return;
    end
end
% 集合数据
if iscell(windcode)
    % 定位游标位置到第一条K线
    DB.CurrentK = 1;
    for i=1:max(size(windcode))
        isRealContract = length(windcode{i}) == 10;
        [Data flag] = LoadFutureData(w,windcode{i},start_time,end_time,isRealContract,Options);
        DB=setfield(DB,code2structname(windcode{i},'F'),Data);
        if flag==0
            disp('=== Back test shutting down! ===')
            return;
        end
    end
end
% 时间轴
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%按年月日格式的时间戳（交易日）
% K线总数
DB.NK = length(Data.Open);
flag = 1;
end

