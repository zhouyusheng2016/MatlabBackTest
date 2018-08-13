function Asset = InitFutureAsset(DB,Options)
NT = DB.NK;
% ʱ����
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
% ��ǰ�ֲ���
Asset.CurrentPosition = 0;
Asset.CurrentStock = [];
Asset.CurrentMargins = [];
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
% ����Լ���ñ�֤��
Asset.Margins = cell(NT,1);
% �ϴμ�����ñ�֤���Լ����ñ�֤���֤ȯ����
Asset.SettleCode = cell(NT,1);
% �ϴμ�����ñ�֤���Լ����ñ�֤��Ľ���۸�
Asset.Settle = cell(NT,1);
% ���ñ�֤���ܺ�
Asset.FrozenCash = zeros(NT,1);
% ���ʲ�����
Asset.GrossAssets = zeros(NT,1);
% ��ʼ�ʽ���
Asset.InitCash = Options.InitCash;
% ��֤��߽�����
Asset.MarginCall = zeros(NT,1);
% ��֤��߽�Ʒ��
Asset.MarginCallStock = cell(NT,1);
% ��֤��߽����������Լ
Asset.MarginCallAmount = cell(NT,1);
% �ֲ������ں�Լ
Asset.ExpiredContract = cell(NT,1);
% �ֲ������ں�Լ����
Asset.ExpiredContractPosition = cell(NT,1);
% �ֲ������ں�Լ�۸�
Asset.ExpiredContractSettlePrice = cell(NT,1);
end