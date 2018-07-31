%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
dataPath = strcat(backtestDicPath,'DataExample\OptionDataExample.csv');

path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added �ڻ�path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added

% �˻�����
% ֤ȯ�����˻�ѡ������
Options.InitCash = 1000000;
Options.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
Options.CommissionPerContract = 4; % ÿ�ź�ԼӶ��
Options.Slippage = 0; % ����
Options.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
Options.DelayDays = 3; % ����ʧ��������ӳٽ����������������������
Options.OptLastSettlementType = 'Close'; %��ǰ�����ȱʧ������²������̼۴��� ��Settle��

%% 1.���ݵ���
% this could take a while
start_time = '2015-02-09';
end_time = '2018-04-30';
[DB flag] = LoadOptionData_Local(dataPath,start_time,end_time,Options);
%��ȡ����
fields = fieldnames(DB);
optionFieldnames = fields(1:end-5);
% ��ʼ����Ȩ�ʲ�
Asset = InitOptionAsset(DB,Options);
%% 2.�䵥
% �����䵥����
DB.CurrentK = 29;
Asset = OrderOption(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data.Open(1),Signal{2}.Type,Options);

% �����䵥
DB.CurrentK = 1;
Signal{1}.Volume = 5;
Signal{1}.Stock = optionFieldnames{1}(4:end);
Signal{1}.Type = 'Today';
Data = getfield(DB, optionFieldnames{1});
Asset = OrderOption(DB,Asset,Signal{1}.Stock, Signal{1}.Volume,Data.Open(1),Signal{1}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{1}.Stock, -Signal{1}.Volume-1,Data.Open(2),'Next',Options);

Signal{2}.Volume = -7;
Signal{2}.Stock = optionFieldnames{2}(4:end);
Signal{2}.Type = 'Today';
Data = getfield(DB, optionFieldnames{2});
Asset = OrderOption(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data.Open(1),Signal{2}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{2}.Stock,-Signal{2}.Volume+1,Data.Open(2),'Next',Options);

Signal{3}.Volume = -8;
Signal{3}.Stock = optionFieldnames{3}(4:end);
Signal{3}.Type = 'Today';
Data = getfield(DB, optionFieldnames{3});
Asset = OrderOption(DB,Asset,Signal{3}.Stock,Signal{3}.Volume,Data.Open(1),Signal{3}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{3}.Stock,Signal{2}.Volume,Data.Open(2),'Next',Options);


%% ��������
DB.CurrentK = 1;
Asset = ClearingOption(Asset,DB,Options);
%����ʽ�仯
pos = cell2mat(Asset.Position(DB.CurrentK));
allMargins = sum(cell2mat(Asset.Margins(DB.CurrentK)));
allFee = sum(cell2mat(Asset.DealFee(DB.CurrentK)));
price = cell2mat(Asset.DealPrice(DB.CurrentK))*10000;
allCost = sum(-pos.*price);
after = Asset.InitCash +allCost - allFee - allMargins;
error = Asset.Cash(DB.CurrentK) - after;                                    %����Ӧ�ýӽ���0


DB.CurrentK = 2;
Asset = ClearingOption(Asset,DB,Options);
%����ʽ�仯
vol = cell2mat(Asset.DealVolume(DB.CurrentK));
allMargins_before = sum(cell2mat(Asset.Margins(DB.CurrentK-1)));
allMargins_after = sum(cell2mat(Asset.Margins(DB.CurrentK)));
margins_change = allMargins_after - allMargins_before;
allFee = sum(cell2mat(Asset.DealFee(DB.CurrentK)));
price = cell2mat(Asset.DealPrice(DB.CurrentK))*10000;
allCost = sum(-vol.*price);
after = Asset.Cash(DB.CurrentK-1) +allCost - allFee - margins_change;
error = Asset.Cash(DB.CurrentK) - after;                                   %����Ӧ�ýӽ���0








