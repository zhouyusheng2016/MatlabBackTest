%% this is unit test of Futrue Trading Frame
%% ����·��
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                                          % added �ڻ�path
path(path,genpath(optionDicPath));                                          % added 
path(path,genpath(stockDicPath));                                           % added

%% ��ʼ����
% the wind obj
w = windmatlab;
% Future settings
FOptions.InitCash = 10000000;
FOptions.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
FOptions.RiskFreeReturn = 0.05; % �޷���������
FOptions.MinCommission = 5; % ��СӶ��
FOptions.Commission = 0.0003; % Ӷ��,Ŀǰ�����ֿ�ƽ������
FOptions.Slippage = 0.00246; % ����
FOptions.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
FOptions.DelayDays = 3; % ����ʧ��������ӳٽ����������������������
% test code const
windcodeMultiF = {'IH1807.CFE','IH00.CFE'};
windcodeSingleF = {'IH1807.CFE'};

start_time = '2018-06-01';
end_time = '2018-06-18';
windCodeMultiKind = {'IH1807.CFE', 'RB1807.SHF','IH00.CFE'};

%% start the testing 
%% 1. test load future data
% 1.1���Լ��ؼ�������
[DB flag] = FutureMarketData(w,windCodeMultiKind,start_time,end_time,FOptions);
% 1.2���Լ��ص�һ����
[DB1 flag] = FutureMarketData(w,windcodeSingleF,start_time,end_time,FOptions);
%% 2. test get hist data
HisDB0 = HisFutureData(DB,windCodeMultiKind,FOptions);
DB1.CurrentK = 801;
HisDB1 = HisFutureData(DB1,windcodeSingleF,FOptions);
%% 3. test order
% ��ʼ���ʲ���
Asset = InitFutureAsset(DB,FOptions);
%DB0.CurrentK = 798;
%��ʵ��ԼIH
DB.CurrentK = 1;
Signal{1}.Volume = 5;
Signal{1}.Stock = windCodeMultiKind{1};
Signal{1}.Type = 'Today';
Data1=getfield(DB,code2structname(Signal{1}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{1}.Stock,Signal{1}.Volume,Data1.Open(DB.CurrentK),Signal{1}.Type,FOptions); % �䵥
Asset = OrderFuture(DB,Asset,Signal{1}.Stock,-Signal{1}.Volume-11,Data1.Open(DB.CurrentK+1),'Next',FOptions); % �䵥
%��ʵ��ԼRB
Signal{2}.Volume = -6;
Signal{2}.Stock = windCodeMultiKind{2};
Signal{2}.Type = 'Today';
Data2=getfield(DB,code2structname(Signal{2}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{2}.Stock,Signal{2}.Volume,Data2.Open(DB.CurrentK),Signal{2}.Type,FOptions); % �䵥
Asset = OrderFuture(DB,Asset,Signal{2}.Stock,-Signal{2}.Volume+1,Data2.Open(DB.CurrentK+1),'Next',FOptions); % �䵥
%������Լ
Signal{3}.Volume = -7;
Signal{3}.Stock = windCodeMultiKind{3};
Signal{3}.Type = 'Today';
Data3=getfield(DB,code2structname(Signal{3}.Stock,'F'));
Asset = OrderFuture(DB,Asset,Signal{3}.Stock,Signal{3}.Volume,Data3.Open(DB.CurrentK),Signal{3}.Type,FOptions); % �䵥
Asset = OrderFuture(DB,Asset,Signal{3}.Stock,-Signal{3}.Volume+2,Data3.Open(DB.CurrentK+1),'Next',FOptions); % �䵥
%% 4. test clearing
%��һ��
DB.CurrentK = 1;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
% here should be a intraday settlement, which alters the margins
% and issuing margin calls if needed. But for simplicity, just think they
% are settled since we can consider the result are settled once in trading
% process
%�ڶ���
DB.CurrentK = 2;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
%������
%������û�ж�����ϣ�clearing���ı�Asset״̬�� Settlement�ı�Asset״̬
DB.CurrentK = 3;
Asset = ClearingFuture(Asset,DB,FOptions);
Asset = SettleFutrueAsset(Asset,DB,FOptions);
%% 5. test day end settlement









