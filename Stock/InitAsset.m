function Asset = InitAsset(DB,Options)
NT = DB.NK;
% ʱ����
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
% ��ǰ�ֲ���
Asset.CurrentPosition = 0;
Asset.CurrentStock = [];
% �µ�������
Asset.OrderVolume = cell(NT,1);
% �µ�������
Asset.OrderPrice = cell(NT,1);
% �µ��������
Asset.OrderStock = cell(NT,1);
% �ɽ�������
Asset.DealVolume = cell(NT,1);
% �ɽ�������
Asset.DealPrice = cell(NT,1);
% �ɽ��������
Asset.DealStock = cell(NT,1);
% �ɽ�����������
Asset.DealFee = cell(NT,1);
% �ֲ�������
Asset.Position = cell(NT,1);
% �ֱֲ������
Asset.Stock = cell(NT,1);
% �����ֽ�����
Asset.Cash = zeros(NT,1);
% ���ʲ�����
Asset.GrossAssets = zeros(NT,1);
% ��ʼ�ʽ���
Asset.InitCash = Options.InitCash;