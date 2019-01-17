%% 测试
start_time = '2015-02-09';
end_time = '2018-12-28';
RateType = 'GC';
% 证券交易账户选项设置
GCOptions.InitCash = 1000000;
GCOptions.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
GCOptions.Slippage = 0; % 滑点
GCOptions.PartialDeal = 1; % 开启自动部分成交模式
GCOptions.PriceAdjustOnHighLowOutRange = true; % 下单超过最高最低价时调整至相应最高最低价

[GCDB flag] = LoadRepoRate(GC,RateType,start_time,end_time,GCOptions);
% 建立账户
Asset = InitRepoAsset(GCDB, GCOptions);
% 收款
%% 1
GCDB.CurrentK=1;
Asset = CollectOutStandings(Asset,GCDB);
% 进行逆回购
Asset = OrderRepo(GCDB, Asset, 'GC204003', 2e5, 3, GCOptions);
Asset = OrderRepo(GCDB, Asset, 'GC204003', 1e5, 5, GCOptions);
Asset = OrderRepo(GCDB, Asset, 'GC204002', 2e5, 5, GCOptions);
% 进行结算
Asset = ClearRepo(Asset, GCDB, GCOptions);
Asset = UpdateAccountGrossAsset(Asset,GCDB);
%% 2
GCDB.CurrentK = 2;
Asset = CollectOutStandings(Asset,GCDB);
Asset = ClearRepo(Asset, GCDB, GCOptions);
Asset = UpdateAccountGrossAsset(Asset,GCDB);
%% 3
GCDB.CurrentK = 3;
Asset = CollectOutStandings(Asset,GCDB);
Asset = ClearRepo(Asset, GCDB, GCOptions);
Asset = UpdateAccountGrossAsset(Asset,GCDB);
%% 4
GCDB.CurrentK = 4;
Asset = CollectOutStandings(Asset,GCDB);
Asset = ClearRepo(Asset, GCDB, GCOptions);
Asset = UpdateAccountGrossAsset(Asset,GCDB);
%% 5
GCDB.CurrentK = 5;
Asset = CollectOutStandings(Asset,GCDB);
Asset = ClearRepo(Asset, GCDB, GCOptions);
Asset = UpdateAccountGrossAsset(Asset,GCDB);