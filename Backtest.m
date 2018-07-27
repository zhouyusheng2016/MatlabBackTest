function [Asset,DB] = Backtest(StrategyFunc,Context,windcode,start_time,end_time,Options)
% ���������ӿ�ȡ����
w = windmatlab;
% ����K������
if ischar(windcode)
    % ��λ�α�λ�õ���һ��K��
    DB.CurrentK = 1;
    [Data, flag] = LoadData(w,windcode,start_time,end_time,Options);
    DB=setfield(DB,[windcode(8:9) windcode(1:6)],Data);
    if flag==0
        disp('=== Back test shutting down! ===')
        return;
    end
end
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
    w.wsd(Options.Benchmark,'close',start_time,end_time,'PriceAdj=F');
if w_wsd_errorid_0~=0
    disp(['!!! ����' Options.Benchmark '�������ݴ���: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    return;
end
DB.Benchmark = w_wsd_data_0;
DB.BenchmarkStock = Options.Benchmark;
% ʱ����
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%�������ո�ʽ��ʱ����������գ�
% K������
DB.NK = length(Data.Open);

% ��ʼ���ʲ���
Asset = InitAsset(DB,Options);

% ��K��ѭ��
for K = 1:DB.NK
    DB.CurrentK = K; %��ǰK��
    HisDB = HisData(DB,windcode,Options);
    Signal = StrategyFunc(HisDB,Context); %���в��Ժ��������ɽ����ź�
    if ~isempty(Signal)
        for sig=1:length(Signal) %���ź�˳���䵥
            if sum(strcmp(Signal{sig}.Stock, windcode))
                Asset = Order(DB,Asset,Signal{sig}.Stock,Signal{sig}.Volume,Signal{sig}.price,Signal{sig}.Type,Options); % �䵥
            else
                disp(['!!! δ����' Signal{sig}.Stock '���ݣ�������Ʊ���ĳغ��ٴ����лز� !!!']);
                return;
            end
        end
    end
    % ÿ��K�������н���ʱ��Ҫ����
    Asset = Clearing(Asset,DB,Options);
end

Asset=Summary(Asset,DB,Options);
disp('=== Back test complete! ===')
end
