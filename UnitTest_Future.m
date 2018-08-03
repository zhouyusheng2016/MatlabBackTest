%% this is unit test of Futrue Trading Frame
%% 导入路径
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                                          % added 期货path
path(path,genpath(optionDicPath));                                          % added 
path(path,genpath(stockDicPath));                                           % added

%% 开始测试
% the wind obj
w = windmatlab;
% Future settings
FOptions.InitCash = 10000000;
FOptions.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
FOptions.RiskFreeReturn = 0.05; % 无风险收益率
FOptions.MinCommission = 5; % 最小佣金
FOptions.Commission = 0.0003; % 佣金,目前不区分开平今昨日
FOptions.Slippage = 0.00246; % 滑点
FOptions.PartialDeal = 1; % 开启自动部分成交模式
FOptions.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易
% test code const
windcodeMultiF = {'IH1807.CFE','IH00.CFE'};
windcodeSingleF = {'IH1807.CFE'};

start_time = '2018-06-01';
end_time = '2018-06-18';
windCodeMultiKind = {'IH1807.CFE', 'RB1807.SHF','IH00.CFE'};

%% start the testing 
%% 1. test load future data
% 1.1测试加载集合数据
[DB flag] = FutureMarketData(w,windCodeMultiKind,start_time,end_time,FOptions);
% 1.2测试加载单一数据
[DB1 flag] = FutureMarketData(w,windcodeSingleF,start_time,end_time,FOptions);
%% 2. test get hist data
HisDB0 = HisFutureData(DB,windCodeMultiKind,FOptions);
DB1.CurrentK = 801;
HisDB1 = HisFutureData(DB1,windcodeSingleF,FOptions);
%% 3. test order
% 初始化资产池
Asset = InitFutureAsset(DB,FOptions);
%DB0.CurrentK = 798;
%真实合约IH
DB.CurrentK = 1;
Signal{1}.Volume = 5;
Signal{1}.Stock = windCodeMultiKind{1};
Signal{1}.Type = 'Today';
Data1=getfield(DB,code2structname(Signal{1}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{1}.Stock,Signal{1}.Volume,Data1.Open(DB.CurrentK),Signal{1}.Type,FOptions); % 落单
Asset = OrderFuture(DB,Asset,Signal{1}.Stock,-Signal{1}.Volume-11,Data1.Open(DB.CurrentK+1),'Next',FOptions); % 落单
%真实合约RB
Signal{2}.Volume = -6;
Signal{2}.Stock = windCodeMultiKind{2};
Signal{2}.Type = 'Today';
Data2=getfield(DB,code2structname(Signal{2}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data2.Open(DB.CurrentK),Signal{2}.Type,FOptions); % 落单
Asset = OrderFuture(DB,Asset,Signal{2}.Stock,-Signal{2}.Volume+1,Data2.Open(DB.CurrentK+1),'Next',FOptions); % 落单
%连续合约
Signal{3}.Volume = -7;
Signal{3}.Stock = windCodeMultiKind{3};
Signal{3}.Type = 'Today';
Data3=getfield(DB,code2structname(Signal{3}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{3}.Stock,Signal{3}.Volume,Data3.Open(DB.CurrentK),Signal{3}.Type,FOptions); % 落单
Asset = OrderFuture(DB,Asset,Signal{3}.Stock,-Signal{3}.Volume+2,Data3.Open(DB.CurrentK+1),'Next',FOptions); % 落单
%% 4. test clearing
%第一天
DB.CurrentK = 1;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
% here should be a intraday settlement, which alters the margins
% and issuing margin calls if needed. But for simplicity, just think they
% are settled since we can consider the result are settled once in trading
% process
%第二天
DB.CurrentK = 2;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
%第三天
%第三天没有订单撮合，clearing不改变Asset状态， Settlement改变Asset状态
DB.CurrentK = 3;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
%% 5. test day end settlement









