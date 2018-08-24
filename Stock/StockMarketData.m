function [DB flag] = StockMarketData(w,windcode,start_time,end_time,Options)
% ��һ����
if ischar(windcode)
    % ��λ�α�λ�õ���һ��K��
    DB.CurrentK = 1;
    [Data, flag] = LoadData(w,windcode,start_time,end_time,Options);
    DB=setfield(DB,code2structname(windcode,'S'),Data);
    if flag==0
        disp('=== Back test shutting down! ===')
        return;
    end
end
% ��������
if iscell(windcode)
    % ��λ�α�λ�õ���һ��K��
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
% ���ػز��׼��������
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(Options.Benchmark,'open, high, low, close,adjfactor',start_time,end_time);
if w_wsd_errorid_0~=0
    disp(['!!! ����' Options.Benchmark '�������ݴ���: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    return;
end

DB.Benchmark.Open = w_wsd_data_0(:,1);
DB.Benchmark.High = w_wsd_data_0(:,2);
DB.Benchmark.Low = w_wsd_data_0(:,3);
DB.Benchmark.Close = w_wsd_data_0(:,4);
DB.Benchmark.AdjFactor = w_wsd_data_0(:,5);
DB.BenchmarkStock = Options.Benchmark;
% ʱ����
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%�������ո�ʽ��ʱ����������գ�
% K������
DB.NK = length(Data.Open);
flag = 1;
end

