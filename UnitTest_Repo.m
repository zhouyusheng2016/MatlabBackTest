%% ����
start_time = '2015-02-09';
end_time = '2018-12-28';
RateType = 'GC';
% ֤ȯ�����˻�ѡ������
GCOptions.InitCash = 1000000;
GCOptions.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
GCOptions.Slippage = 0; % ����
GCOptions.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
GCOptions.PriceAdjustOnHighLowOutRange = true; % �µ����������ͼ�ʱ��������Ӧ�����ͼ�

[GCDB flag] = LoadRepoRate(GC,RateType,start_time,end_time,GCOptions);
% �����˻�
Asset = InitRepoAsset(GCDB, GCOptions);
% �տ�
%% 1
GCDB.CurrentK=1;
Asset = CollectOutStandings(Asset,GCDB);
% ������ع�
Asset = OrderRepo(GCDB, Asset, 'GC204003', 2e5, 3, GCOptions);
Asset = OrderRepo(GCDB, Asset, 'GC204003', 1e5, 5, GCOptions);
Asset = OrderRepo(GCDB, Asset, 'GC204002', 2e5, 5, GCOptions);
% ���н���
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