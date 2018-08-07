%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
filename = strcat(backtestDicPath,'DataExample\OptionDataExample.csv');

path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added 期货path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added

% 账户设置
% 证券交易账户选项设置
Options.InitCash = 1000000;
Options.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
Options.CommissionPerContract = 4; % 每张合约佣金
Options.SettlementFeePerContract = 1;
Options.Slippage = 0; % 滑点
Options.PartialDeal = 1; % 开启自动部分成交模式
Options.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易
Options.OptLastSettlementType = 'Close'; %在前结算价缺失的情况下采用收盘价代替 ‘Settle’

w = windmatlab();
%% 1.数据导入
% this could take a while
start_time = '2015-02-09';
end_time = '2018-04-30';
[DB flag] = LoadOptionData_Local(w, filename,start_time,end_time,'510050.SH',Options);

%获取代码
fields = fieldnames(DB);
optionFieldnames = fields(1:end-5);
% 初始化期权资产
Asset = InitOptionAsset(DB,Options);
%% 2.落单
% 测试落单限制
DB.CurrentK = 29;
Asset = OrderOption(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data.Open(1),Signal{2}.Type,Options);


% 首日落单 次日落单
Asset = InitOptionAsset(DB,Options);
DB.CurrentK = 1;
Signal{1}.Volume = 5;
Signal{1}.Stock = optionFieldnames{1}(4:end);
Signal{1}.Type = 'Today';
Data1 = getfield(DB, optionFieldnames{1});
Asset = OrderOption(DB,Asset,Signal{1}.Stock, Signal{1}.Volume,Data1.Open(1),Signal{1}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{1}.Stock, -Signal{1}.Volume-1,Data1.Open(2),'Next',Options);
Signal{2}.Volume = -7;
Signal{2}.Stock = optionFieldnames{2}(4:end);
Signal{2}.Type = 'Today';
Data2 = getfield(DB, optionFieldnames{2});
Asset = OrderOption(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data2.Open(1),Signal{2}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{2}.Stock,-Signal{2}.Volume+1,Data2.Open(2),'Next',Options);
Signal{3}.Volume = -8;
Signal{3}.Stock = optionFieldnames{10}(4:end);
Signal{3}.Type = 'Today';
Data3 = getfield(DB, optionFieldnames{10});                                  % put
Asset = OrderOption(DB,Asset,Signal{3}.Stock,Signal{3}.Volume,Data3.Open(1),Signal{3}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{3}.Stock,Signal{3}.Volume,Data3.Open(2),'Next',Options);


%% 撮合与结算
%多空 开仓
DB.CurrentK = 1;
Asset = ClearingOption(Asset,DB,Options);
%检查资金变化
pos = cell2mat(Asset.Position(DB.CurrentK));
allMargins = sum(cell2mat(Asset.Margins(DB.CurrentK)));
allFee = sum(cell2mat(Asset.DealFee(DB.CurrentK)));
price = cell2mat(Asset.DealPrice(DB.CurrentK))*10000;
allCost = sum(-pos.*price);
after = Asset.InitCash +allCost - allFee - allMargins;
error = Asset.Cash(DB.CurrentK) - after;                                    %错误应该接近于0
% 只落单 1，2，3都为0，落单（1，2）（1，3）也为0
% 落单（2，3）则出现误差，同（1，2，3）

% 每日盯盘
Asset = SettleOptionAsset(Asset,DB,Options);
% 平多反手，平空反手，空仓新开空仓
DB.CurrentK = 2;
Asset = ClearingOption(Asset,DB,Options);
%检查资金变化
vol = cell2mat(Asset.DealVolume(DB.CurrentK));
allMargins_before = sum(cell2mat(Asset.Margins(DB.CurrentK-1)));
allMargins_after = sum(cell2mat(Asset.Margins(DB.CurrentK)));
margins_change = allMargins_after - allMargins_before;
allFee = sum(cell2mat(Asset.DealFee(DB.CurrentK)));
price = cell2mat(Asset.DealPrice(DB.CurrentK))*10000;
allCost = sum(-vol.*price);
after = Asset.Cash(DB.CurrentK-1) +allCost - allFee - margins_change;
error = Asset.Cash(DB.CurrentK) - after;                                   %错误应该接近于0
% 每日盯盘
Asset = SettleOptionAsset(Asset,DB,Options);
% 到期日结算
for I = 3:27
    DB.CurrentK = I;
    Asset = ClearingOption(Asset,DB,Options);
    % 每日盯盘
    Asset = SettleOptionAsset(Asset,DB,Options);
end
% 测试落单限制 28 为首个合约到期K线游标号
DB.CurrentK = 28;
Asset = ClearingOption(Asset,DB,Options);
Asset = SettleOptionAsset(Asset,DB,Options);

cashBefore = Asset.Cash(DB.CurrentK-1);
cashAfter = Asset.Cash(DB.CurrentK);

pos = cell2mat(Asset.ExpiredContractPosition{DB.CurrentK});
payoff = cell2mat(Asset.ExpiredContractSettlePrice{DB.CurrentK});
pnl = sum(pos.*payoff);

fee = sum(Asset.SettlementFee{DB.CurrentK});
totalMargin = sum(Asset.Margins{DB.CurrentK-1});
error = cashAfter-(cashBefore+pnl-fee+totalMargin); % error 为0
%% 测试净值核算
for I = 1:28
DB.CurrentK  = I;
Asset = ClearingOption(Asset,DB,Options);
Asset = SettleOptionAsset(Asset,DB,Options);
Asset = RecordOptionAssetValueAtBarClose(Asset,DB,I,Options);
end

underlyingClose = DB.Underlying.Close(I);
strikes = [Data1.Strike(I), Data2.Strike(I), Data3.Strike(I)];
multi = [Data1.ContractUnit(I), Data2.ContractUnit(I), Data3.ContractUnit(I)];
[Data1.Info{1} Data2.Info{1} Data3.Info{1}]
payoff(1:2) = max(underlyingClose - strikes(1:2),0);
payoff(3) = max(strikes(3)- underlyingClose, 0);
payoffPos = payoff.*multi;

payoffPos == cell2mat(Asset.ExpiredContractSettlePrice{I})
%% 测试寻找每日可交易合约
tic
tradeableOptNames = GetTradeableOptions(DB, I, optionFieldnames);
toc % 0.02秒一次查询

%% 测试查询每日平值合约
% 采用可交易合约名作为输入量
tic
optInfo = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames);
toc % 0.03s/103contracts

%测试每天查询
tic
all = [];
for I = 1:DB.NK
    tradeableOptNames = GetTradeableOptions(DB, I, optionFieldnames);
    optInfo = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames);
    all = [all;optInfo];
end
toc% 784天20s
%% 
 





