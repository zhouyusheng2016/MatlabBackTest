function [Asset,DB] = Backtest(StrategyFunc,Context,windcode,start_time,end_time,Options)
% 运行量化接口取数据
w = windmatlab;
% 行情数据K线
[DB,~] = StockMarketData(w,windcode,start_time,end_time,Options);
% 初始化资产池
Asset = InitAsset(DB,Options);
% 按K线循环
for K = 1:DB.NK
    DB.CurrentK = K; %当前K线
    HisDB = HisData(DB,windcode,Options);
    Signal = StrategyFunc(HisDB,Context); %运行策略函数，生成交易信号
    if ~isempty(Signal)
        for sig=1:length(Signal) %按信号顺序落单
            if sum(strcmp(Signal{sig}.Stock, windcode))
                Asset = Order(DB,Asset,Signal{sig}.Stock,Signal{sig}.Volume,Signal{sig}.price,Signal{sig}.Type,Options); % 落单
            else
                disp(['!!! 未订阅' Signal{sig}.Stock '数据，请加入股票订阅池后再次运行回测 !!!']);
                return;
            end
        end
    end
    % 每条K线在运行结束时都要清算
    Asset = Clearing(Asset,DB,Options);
end

Asset=Summary(Asset,DB,Options);
disp('=== Back test complete! ===')
end
