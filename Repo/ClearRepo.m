function Asset = ClearRepo(Asset, DB, Options)
%% �α�
I = DB.CurrentK;
%% ��ȡ�˻�״̬
if I == 1
    AvaCash = Asset.InitCash ;
    TransCash = Asset.InitCash;
else
    AvaCash = Asset.Cash(I);
    TransCash = Asset.CashTransAble(I);
end

%% �������
for i = 1:length(Asset.OrderRepo{I})
    %��ȡ��������
    Data = getfield(DB, Asset.OrderRepo{I}{i});
    %��ȡ����������
    VolumeLimit = Options.VolumeRatio * Data.Volume(I);
    dealPrinciplie = Asset.OrderPrinciple{I}(i);
    if dealPrinciplie > VolumeLimit
        if Options.PartialDeal
            dealPrinciplie = VolumeLimit;
        else
            error('OrderVolumeHigherThanLimitError')
        end
    end
    %% �˻��ʽ����
    AvaCash = AvaCash - dealPrinciplie;
    TransCash = TransCash - dealPrinciplie;
    
    commission = GetGCCommission(dealPrinciplie, Data.Period);
    interest = InterestByNominalRate(dealPrinciplie, Asset.OrderRate{I}(i), Data.Period);
    pnL = interest-commission;
    %% ���½��׼�¼
    Asset.DealRepo{I} = [Asset.DealRepo{I}, Asset.OrderRepo{I}(i)];
    Asset.DealRate{I} = [Asset.DealRate{I},Asset.OrderRate{I}(i)];
    Asset.DealVolume{I} = [Asset.DealVolume{I}, dealPrinciplie];
    Asset.DealFee{I} = [Asset.DealFee{I}, commission];
    %% ���½��״̬
    Asset.OutStandingPrinciple = Asset.OutStandingPrinciple+dealPrinciplie;
    %% ȷ���ؿ�
    BackDate = DB.Times(I)+Data.Period;                                     %�ؿ���Ȼ��
    TansDate = BackDate+1;                                                  %�ؿ��ת��
    
    idx_FirstTradeDate = find(DB.Times>=BackDate,1);               %�ؿ����
    idx_FirstTransDate = find(DB.Times>=TansDate,1);               %�ؿ��ת������
    % �ؿ��¼
    Asset.RepoBack{idx_FirstTradeDate} = [Asset.RepoBack{idx_FirstTradeDate}, Asset.OrderRepo{I}(i)];
    Asset.InterestGetBack{idx_FirstTradeDate} = [Asset.InterestGetBack{idx_FirstTradeDate}, pnL];
    Asset.PrincipleGetBack{idx_FirstTradeDate} = [Asset.PrincipleGetBack{idx_FirstTradeDate}, dealPrinciplie];
    % ���ñ���ؿ�
    Asset.PrincipleReceivable(idx_FirstTradeDate) = Asset.PrincipleReceivable(idx_FirstTradeDate)+dealPrinciplie;
    % ������Ϣ�ؿ�
    Asset.InterestReceivable(idx_FirstTradeDate) = Asset.InterestReceivable(idx_FirstTradeDate)+pnL;
    % ��ת
    Asset.CashTransReceivables(idx_FirstTransDate) = Asset.CashTransReceivables(idx_FirstTransDate)+dealPrinciplie+pnL;
end
%% �����ֽ�״̬
Asset.Cash(I) = AvaCash;
Asset.CashTransAble(I) = TransCash;
end