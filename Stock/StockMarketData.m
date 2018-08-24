function [DB flag] = StockMarketData(w,windcode,start_time,end_time,Options)
% 单一数据
if ischar(windcode)
    % 定位游标位置到第一条K线
    DB.CurrentK = 1;
    [Data, flag] = LoadData(w,windcode,start_time,end_time,Options);
    DB=setfield(DB,code2structname(windcode,'S'),Data);
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
        [Data flag] = LoadData(w,windcode{i},start_time,end_time,Options);
        DB=setfield(DB,code2structname(windcode{i},'S'),Data);
        if flag==0
            disp('=== Back test shutting down! ===')
            return;
        end
    end
end
% 加载回测基准行情数据
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(Options.Benchmark,'open, high, low, close,adjfactor',start_time,end_time);
if w_wsd_errorid_0~=0
    disp(['!!! 加载' Options.Benchmark '行情数据错误: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    return;
end

DB.Benchmark.Open = w_wsd_data_0(:,1);
DB.Benchmark.High = w_wsd_data_0(:,2);
DB.Benchmark.Low = w_wsd_data_0(:,3);
DB.Benchmark.Close = w_wsd_data_0(:,4);
DB.Benchmark.AdjFactor = w_wsd_data_0(:,5);
DB.BenchmarkStock = Options.Benchmark;
% 时间轴
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%按年月日格式的时间戳（交易日）
% K线总数
DB.NK = length(Data.Open);
flag = 1;
end

