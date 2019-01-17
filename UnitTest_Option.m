%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
filename = strcat(backtestDicPath,'DataExample\OptionDataExample.csv');

path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added �ڻ�path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added

% �˻�����
% ֤ȯ�����˻�ѡ������
Options.InitCash = 1000000;
Options.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
Options.CommissionPerContract = 4; % ÿ�ź�ԼӶ��
Options.SettlementFeePerContract = 1;
Options.Slippage = 0; % ����
Options.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
Options.DelayDays = 3; % ����ʧ��������ӳٽ����������������������
Options.OptLastSettlementType = 'Close'; %��ǰ�����ȱʧ������²������̼۴��� ��Settle��

w = windmatlab();
%% 1.���ݵ���
% this could take a while
start_time = '2015-02-09';
end_time = '2018-04-30';
[DB flag] = LoadOptionData_Local(w, filename,start_time,end_time,'510050.SH',Options);

%��ȡ����
fields = fieldnames(DB);
optionFieldnames = fields(1:end-5);
% ��ʼ����Ȩ�ʲ�
Asset = InitOptionAsset(DB,Options);
%% 2.�䵥
% �����䵥����
DB.CurrentK = 29;
Asset = OrderOption(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data.Open(1),Signal{2}.Type,Options);


% �����䵥 �����䵥
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


%% ��������
%��� ����
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
% ֻ�䵥 1��2��3��Ϊ0���䵥��1��2����1��3��ҲΪ0
% �䵥��2��3���������ͬ��1��2��3��

% ÿ�ն���
Asset = SettleOptionAsset(Asset,DB,Options);
% ƽ�෴�֣�ƽ�շ��֣��ղ��¿��ղ�
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
% ÿ�ն���
Asset = SettleOptionAsset(Asset,DB,Options);
% �����ս���
for I = 3:27
    DB.CurrentK = I;
    Asset = ClearingOption(Asset,DB,Options);
    % ÿ�ն���
    Asset = SettleOptionAsset(Asset,DB,Options);
end
% �����䵥���� 28 Ϊ�׸���Լ����K���α��
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
error = cashAfter-(cashBefore+pnl-fee+totalMargin); % error Ϊ0
%% ���Ծ�ֵ����
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
%% ����Ѱ��ÿ�տɽ��׺�Լ
tic
tradeableOptNames = GetTradeableOptions(DB, I, optionFieldnames);
toc % 0.02��һ�β�ѯ

%% ���Բ�ѯÿ��ƽֵ��Լ
% ���ÿɽ��׺�Լ����Ϊ������
tic
optInfo = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames);
toc % 0.03s/103contracts

%����ÿ���ѯ
tic
all = [];
for I = 1:DB.NK
    tradeableOptNames = GetTradeableOptions(DB, I, optionFieldnames);
    optInfo = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames);
    all = [all;optInfo];
end
toc% 784��20s
%% ȱ�ݽ��������ܲ�֧��ͬһ��K�߻��ֺ��ѯ�ʲ��ٶȿ���
 % ԭ�򣺵�����Order�µ�������δ����clearing,�˻��ʲ�δ����
 % �ʲ���ȷ��ͬ��K�����¿���λ���ʽ��Ƿ񳬹������ֽ�
 % ��������� ƽ�ֺ�����ִ��Clearing��ͨ����ǰ�α꣨T����ѯ���յ��ʲ����
 % ȷ��Asset.Cash(I), Asset.FrozenCash(I)�ȣ����µ��ʲ���Ϣȷ���¿���
 % ��ʱ���ʲ������
 % clearing����Ҫ�����������clearing�洢����I��ʱ������Ϣ��
 % ��󱾷���������Ҫ����Settle
 
 % ���ԣ�
%����ǰ��ʽ�µ�
DB.CurrentK = 1;
% ͬһ���������Σ���¼�״�������
Asset = ClearingOption(Asset,DB,Options);
AssetFirstClearing = Asset;
Asset = ClearingOption(Asset,DB,Options);
AssetSecondClearing = Asset;
AssetSecondClearing = UnClearingOptionAsset(Asset,I);
% ����Ա�
%��ͬ���
AssetFirstClearing.Cash(DB.CurrentK) == AssetSecondClearing.Cash(DB.CurrentK)
AssetFirstClearing.FrozenCash(DB.CurrentK) == AssetSecondClearing.FrozenCash(DB.CurrentK)
AssetFirstClearing.Margins{DB.CurrentK} == AssetSecondClearing.Margins{DB.CurrentK}
strcmp(AssetFirstClearing.MarginStock{DB.CurrentK}, AssetSecondClearing.MarginStock{DB.CurrentK})

AssetFirstClearing.CurrentPosition == AssetSecondClearing.CurrentPosition
AssetFirstClearing.CurrentMargins == AssetSecondClearing.CurrentMargins

% �仯�Ľ�� --- ֻ�ı���Deal�ֶΣ���ΪDealΪappend��ʽ
AssetFirstClearing.DealStock{DB.CurrentK}
AssetSecondClearing.DealStock{DB.CurrentK}
AssetFirstClearing.DealVolume{DB.CurrentK}
AssetSecondClearing.DealVolume{DB.CurrentK}
AssetFirstClearing.DealPrice{DB.CurrentK}
AssetSecondClearing.DealPrice{DB.CurrentK}
AssetFirstClearing.DealFee{DB.CurrentK}
AssetSecondClearing.DealFee{DB.CurrentK}
% ��Ҫ����deal�ֶΣ������ֶοɲ�����
 
%% ͬһk��������ͬ��Ʊ
Asset = InitOptionAsset(DB,Options);
DB.CurrentK = 1;
%��������
Signal{1}.Volume = 5;
Signal{1}.Stock = optionFieldnames{1}(4:end);
Signal{1}.Type = 'Today';
Data1 = getfield(DB, optionFieldnames{1});
Asset = OrderOption(DB,Asset,Signal{1}.Stock, Signal{1}.Volume,Data1.Open(1),Signal{1}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{1}.Stock, -Signal{1}.Volume,Data1.Open(1),Signal{1}.Type,Options);
Asset = ClearingOption(Asset,DB,Options);
%��������
Asset = InitOptionAsset(DB,Options);
DB.CurrentK = 1;
Asset = OrderOption(DB,Asset,Signal{1}.Stock, -Signal{1}.Volume,Data1.Open(1),Signal{1}.Type,Options);
Asset = OrderOption(DB,Asset,Signal{1}.Stock, +Signal{1}.Volume,Data1.Open(1),Signal{1}.Type,Options);
Asset = ClearingOption(Asset,DB,Options);
 
 
 
 



