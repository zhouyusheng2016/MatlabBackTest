%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added 期货path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added
%% 回测模板
% Version/Date:     0.2 / 2017.10.30
%% Options
clear;close all;clc
% 证券交易账户选项设置
Options.InitCash = 1000000;
Options.Benchmark = '600000.SH'; % 设置基准
Options.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
Options.MinAmountPerHand = 100;
Options.RiskFreeReturn = 0.05; % 无风险收益率
Options.MinCommission = 5; % 最小佣金
Options.Commission = 0.0008; % 佣金
Options.StampTax = 0.001; % 卖出时征收的印花税
Options.Slippage = 0.00246; % 滑点
Options.PartialDeal = 1; % 开启自动部分成交模式
Options.Short = 1; % 允许对交易标的进行做空
Options.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易
% Options.T_0 = 1; % 允许T+0交易

windcode = {'600000.SH','600300.SH'};
start_time = '2015-02-09';
end_time = '2018-07-18';

%% Test 1
Context.fast = 5;
Context.slow = 20;
[Asset1,DB1] = Backtest(@Strategy,Context,{'600000.SH','600300.SH'},start_time,end_time,Options);
filename = 'E:\Matlab2017a\bin\SSE_O510050_greek_ivhvlx_1day_201502to20180501.csv';
%% Test 2
Context.fast = 2;
Context.slow = 5;
[Asset2,DB2] = Backtest(@Strategy,Context,{'600000.SH','600300.SH'},'2014-12-02 09:00:00','2015-7-31 12:00:00',Options);
%% TEst
