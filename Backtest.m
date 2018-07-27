function [Asset,DB] = Backtest(StrategyFunc,Context,windcode,start_time,end_time,Options)
% ���������ӿ�ȡ����
w = windmatlab;
% ��������K��
[DB,~] = StockMarketData(w,windcode,start_time,end_time,Options);
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
