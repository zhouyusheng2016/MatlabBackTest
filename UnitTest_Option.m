%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
dataPath = strcat(backtestDicPath,'DataExample\OptionDataExample.csv');

path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added 期货path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added

% 账户设置
% 证券交易账户选项设置
Options.InitCash = 1000000;
Options.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
Options.MinAmountPerHand = 100;
Options.MinCommission = 5; % 最小佣金
Options.Commission = 0.0008; % 佣金
Options.StampTax = 0.001; % 卖出时征收的印花税
Options.Slippage = 0.00246; % 滑点
Options.PartialDeal = 1; % 开启自动部分成交模式
Options.Short = 1; % 允许对交易标的进行做空
Options.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易


% this could take a while
start_time = '2015-02-09';
end_time = '2018-04-30';
[DB flag] = LoadOptionData_Local(dataPath,start_time,end_time,Options);

%% 数据导入
