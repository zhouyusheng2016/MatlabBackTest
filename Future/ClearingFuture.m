function Asset = ClearingFuture(Asset,DB,Options)
I = DB.CurrentK;
if I == 1
    AvaCash = Asset.InitCash;
    FrozenCash = 0;
    PreStock = [];
    PrePosition = [];
    PreMargins = [];
else
    AvaCash = Asset.Cash(I-1);
    FrozenCash = Asset.FrozenCash(I-1);
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
    PreMargins = Asset.Margins{I-1};
end
Asset.CurrentStock = PreStock;
Asset.CurrentPosition = PrePosition;
Asset.CurrentMargins = PreMargins;
%% �䵥���
for i = 1:length(Asset.OrderPrice{I})
    %% ���ǽ��׼۸񻬵�
    dealprice = OrderPirceWithSlippage(Asset.OrderPrice{I}(i), Asset.OrderVolume{I}(i), Options);
    %% ������ƽ�����ռ�г���
    dealvolume = [];
    Data=getfield(DB,code2structname(Asset.OrderStock{I}{i},'F'));
    dealvolume = AdaptDealVolumeToMarket(I,Data,Asset.OrderVolume{I}(i),Options);
    dealvolume = floor(dealvolume);                                         % ������������

    %% ��ȡ��Լ��Ϣ����ʼ��֤�𣬽��ױ�֤�𣬺�Լ������
    contractInfo = GetFutureContractInfo(Data);
    %% �����Լ���
    nomialValuePerContract = dealprice*contractInfo.multiplier;
    initialMarginValuePerContract = nomialValuePerContract*contractInfo.imargin;
    %% ע�⿪ƽ������
    %��⿪ƽ����
    idxThisStockInCurrentStock = findPositionByName(Asset.OrderStock{I}(i), Asset.CurrentStock);
    thisStockCurrentPosition = Asset.CurrentPosition(idxThisStockInCurrentStock);
    if isempty(thisStockCurrentPosition)
        % ��������ڲ�λ��ֲ�Ϊ0
       thisStockCurrentPosition = 0; 
    end
    %�жϽ��׷���
    if dealvolume > 0
        flag_direction = 'Long';
    else
        flag_direction = 'Short';
    end
    % �жϽ��׿�ƽ
    tradeVolume.Close = 0;
    tradeVolume.Open = 0;
    if dealvolume*thisStockCurrentPosition < 0
        if abs(dealvolume)>abs(thisStockCurrentPosition)
            flag_type = {'Close','Open'};%��Ҫ��ƽ�ٿ�
            tradeVolume.Close = sign(dealvolume)*abs(thisStockCurrentPosition);
            tradeVolume.Open = sign(dealvolume)*(abs(dealvolume)-abs(thisStockCurrentPosition));
        else
            flag_type = {'Close'};%ƽ��
            tradeVolume.Close = dealvolume;
        end
    else
        flag_type = {'Open'};%����
        tradeVolume.Open = dealvolume;
    end
    
    if dealvolume~=0
        %% �Դ�֮�²�Ӧ�ó����ܽ����� dealvolume
        %% ���ƽ��,��ƽ���ٿ���
        %���׷���
        dealfee.Open = 0;
        dealfee.Close = 0;
        unfrozeCash = 0;
        frozeCash = 0;
        if tradeVolume.Close~=0
            % �����յ�ӯ��
            lastSettlePrice = Data.PreSettle(I);                             
            priceChange = dealprice - lastSettlePrice;                      
            priceChangePerContract = priceChange*contractInfo.multiplier;   %ÿ�ź�Լ��ӯ��
            thisPositionPnL = -tradeVolume.Close*priceChangePerContract;    %ƽ�ֲ�λ��ӯ����δƽ�ֵĲ����ս��׼۸����
            % ƽ��ǰ�˻������ñ�֤�����
            totalMarginThisContractBeforeUpdate = Asset.CurrentMargins(idxThisStockInCurrentStock); 
            % ��ƽ�ֲ�λ��ӯ�������ʲ�
            [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...
                (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
            % ����ӯ�������ñ�֤���� - ǰ���ñ�֤��
            thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;
            %
            Asset.CurrentMargins(idxThisStockInCurrentStock) = totalMarginThisContractAfterUpdate;
            FrozenCash = FrozenCash+thisMarginChange;
            
            % �ͷű�֤��
            releaseMarginByPercentage = -tradeVolume.Close/thisStockCurrentPosition;%�����ͷű�֤��ı���
            unfrozeCash = releaseMarginByPercentage*Asset.CurrentMargins(idxThisStockInCurrentStock);%�����ͷű�֤�������
             % ����ƽ��������
            dealfee.Close = FutureTradeCommission(dealprice, tradeVolume.Close, contractInfo, Options,'Open');%��ʱ����ͳһ������
            AvaCash = AvaCash+unfrozeCash-dealfee.Close;                    %���ñ�֤��䶯 
        end
        if tradeVolume.Open~=0
            %��֤�Ƿ񿪲ֵ����ʽ��㣬���𲿷ֿ���
            tradeVolume.Open = AdaptDealVolumeWithAvaCash(Data,I,AvaCash,tradeVolume.Open,dealprice,contractInfo, Options);
            if tradeVolume.Open~=0
                % ���㿪��������
                dealfee.Open = FutureTradeCommission(dealprice, tradeVolume.Open, contractInfo, Options,'Open');%��ʱ����ͳһ������
                % ��ռ�ñ�֤��
                frozeCash = abs(tradeVolume.Open)*initialMarginValuePerContract;
                % ���ñ�֤��䶯
                AvaCash = AvaCash - frozeCash - dealfee.Open;
            end
        end
        marginChange = frozeCash - unfrozeCash; %������֤�� - �ͷű�֤��
        FrozenCash = FrozenCash + marginChange;                                     %�������ñ�֤���ܺ�
        realDealVol = tradeVolume.Open + tradeVolume.Close;%��ʵ�ɽ���
        
        if realDealVol~=0                                                           %�����ʵ�ɽ�����Ϊ0
            % ��¼�ɽ�
            Asset.DealStock{I} = [Asset.DealStock{I} Asset.OrderStock{I}(i)];       %���³ɽ�code
            Asset.DealVolume{I} = [Asset.DealVolume{I} realDealVol];                %���³ɽ���
            Asset.DealPrice{I} = [Asset.DealPrice{I} dealprice];                    %���³ɽ��۸�
            totalDealfee = dealfee.Open + dealfee.Close;                            % �ܽ���������
            Asset.DealFee{I} = [Asset.DealFee{I} totalDealfee];                     %���³ɽ�������
            % �������гֲ�״̬
            if sum(idxThisStockInCurrentStock) > 0 %�ֲֳ��м�¼
                if sum(idxThisStockInCurrentStock) > 1 %�ֲֳ��ж�����¼
                    error('��ǰ�ֲִ��������ظ�');
                end
                Asset.CurrentPosition(idxThisStockInCurrentStock) =...
                    Asset.CurrentPosition(idxThisStockInCurrentStock)+realDealVol;
                Asset.CurrentMargins(idxThisStockInCurrentStock)=...
                    Asset.CurrentMargins(idxThisStockInCurrentStock)+marginChange;
            else
                Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
                Asset.CurrentPosition = [Asset.CurrentPosition realDealVol];
                Asset.CurrentMargins = [Asset.CurrentMargins marginChange];
            end
        end
    end
end
%������׺��²��ֺ�Լ�ղ֣��ڵ�ǰ�ֲ�������ղֵĺ�Լ
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];
Asset.CurrentMargins(idxClearEmpty) = [];

%% ���¼�¼
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;
Asset.Margins{I} = Asset.CurrentMargins;
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;    
end
