function Asset = InitRepoAsset(DB,Options)
NT = DB.NK;
% ʱ����
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
Asset.InitCash = Options.InitCash;                                          %��ʼ�ʽ�
Asset.OutStandingPrinciple = 0;
%% �µ���¼
% �µ�������
Asset.OrderPrinciple = cell(NT,1);
% �µ�������
Asset.OrderRate = cell(NT,1);
% �µ��������
Asset.OrderRepo = cell(NT,1);
%% �ɽ���¼
% �ɽ�������
Asset.DealVolume = cell(NT,1);
% �ɽ�������
Asset.DealRate = cell(NT,1);
% �ɽ��������
Asset.DealRepo = cell(NT,1);
% �ɽ�����������
Asset.DealFee = cell(NT,1);
% ��������������
Asset.SettlementFee = cell(NT,1);
%% �ֲּ�¼

%% ��Ϣ����ʱ��
% ��Ϣ
Asset.RepoBack = cell(NT,1);
Asset.InterestGetBack = cell(NT,1);
Asset.PrincipleGetBack = cell(NT,1);
%% �ֽ�״̬
% �����ֽ�����
Asset.Cash = zeros(NT,1);
Asset.InterestReceivable = zeros(NT,1);
Asset.PrincipleReceivable = zeros(NT,1);
% ��ת�ֽ�����
Asset.CashTransAble = zeros(NT,1);
Asset.CashTransReceivables =zeros(NT,1);
%% ���ʲ���¼
Asset.GrossAssets = zeros(NT,1);
end