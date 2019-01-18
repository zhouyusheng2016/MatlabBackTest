function Asset = ClearingOption(Asset,DB,Options)
%% ��ȡ�˻�״̬
I = DB.CurrentK;
if I == 1
    AvaCash = Asset.InitCash;
    FrozenCash = 0;
    PreStock = [];
    PrePosition = [];
    PreMargins = [];
    PreMarginStock = [];
else
    AvaCash = Asset.Cash(I-1);
    FrozenCash = Asset.FrozenCash(I-1);
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
    PreMargins = Asset.Margins{I-1};
    PreMarginStock = Asset.MarginStock{I-1};
end
Asset.CurrentStock = PreStock;
Asset.CurrentPosition = PrePosition;
Asset.CurrentMargins = PreMargins;
Asset.CurrentMarginStock = PreMarginStock;
%% �䵥���
for i = 1:length(Asset.OrderPrice{I})
    %% ���ǽ��׼۸񻬵�
    dealprice = OrderPirceWithSlippage(Asset.OrderPrice{I}(i), Asset.OrderVolume{I}(i), Options);
    %% ������ƽ�����ռ�г���
    dealvolume = [];
    Data=getfield(DB,code2structname(Asset.OrderStock{I}{i},Options.OptionType));
    dealvolume = AdaptDealVolumeToMarket(I,Data,Asset.OrderVolume{I}(i),Options);
    dealvolume = floor(dealvolume);                                         % ������������

    %% ��ȡ��Լ��Ϣ����ʼ��֤�𣬽��ױ�֤�𣬺�Լ������
    contractInfo = GetOptionContractInfo(Data);
    contractUnit = Data.ContractUnit(I);                                    %�漰��Լ����
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
        %���׷���
        dealfee.Open = 0;
        dealfee.Close = 0;
        unfrozeCash = 0;
        frozeCash = 0;
        
        %��ƽ���ڿ��ֵ�ԭ��
        % ƽ��
        if tradeVolume.Close ~= 0
            costOfDeal = tradeVolume.Close *dealprice * contractUnit;
            dealfee.Close = abs(tradeVolume.Close)*Options.CommissionPerContract;
            % �ղ�ƽ����Ҫ�ͷű�֤��
            if tradeVolume.Close>0
                idx_margin = findPositionByName(Asset.OrderStock{I}(i),Asset.CurrentMarginStock);
                thisStockCurrentMargin = Asset.CurrentMargins(idx_margin);
                if isempty(thisStockCurrentMargin)
                    thisStockCurrentMargin = 0;
                end
                marginReleaseByOneContract = thisStockCurrentMargin...
                    /abs(thisStockCurrentPosition);
                % �����˻�״̬������صĲ���
                tradeVolume.Close = AdaptCloseShortVolumeToAvaCash(Data, I,...
                    tradeVolume.Close, AvaCash,dealprice, contractUnit, ...
                    marginReleaseByOneContract, Options);
                releaseRatio = abs(tradeVolume.Close/thisStockCurrentPosition);
                costOfDeal = tradeVolume.Close *dealprice * contractUnit;
                dealfee.Close = tradeVolume.Close*Options.CommissionPerContract;        
                unfrozeCash = releaseRatio*thisStockCurrentMargin;
                % �ͷű�֤��
                Asset.CurrentMargins(idx_margin) = Asset.CurrentMargins(idx_margin) - unfrozeCash;      
            end
            AvaCash = AvaCash - costOfDeal - dealfee.Close + unfrozeCash;
        end
        
        %����
        if tradeVolume.Open~=0
            marginPerContract = 0;
            if tradeVolume.Open < 0     % �ղֿ���
                % ������Լ����ȡ��֤��
                Underlying = GetOptionUnderlyingStruct(DB, Data,Options);  
                underlyingPreClose = Underlying.PreClose(I);                     %��Լ��ĵ�ǰ���̼�
                lastSettle = GetOptionContractPreSettlePriceByType( Data,...        %��Լ��ǰ�����
                    I, Options.OptLastSettlementType);
                margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
                marginPerContract = margin*contractUnit;                    %ÿ����Ȩ�����񿪲ֱ�֤��     
            end
            
            tradeVolume.Open = AdaptOpenVolumeToAvaCash(Data, I,tradeVolume.Open,...
                AvaCash,dealprice, contractUnit,marginPerContract, Options);
            
            costOfDeal = tradeVolume.Open *dealprice * contractUnit;
            dealfee.Open = abs(tradeVolume.Open)*Options.CommissionPerContract;
            frozeCash = marginPerContract*abs(tradeVolume.Open);     
            % ������ղ�����ȡ��֤��
            if tradeVolume.Open < 0
                idx_margin = findPositionByName(Asset.OrderStock{I}(i),Asset.CurrentMarginStock);
                if sum(idx_margin) == 0 % ����¿��ղ�
                    Asset.CurrentMarginStock  = [Asset.CurrentMarginStock Asset.OrderStock{I}(i)];
                    Asset.CurrentMargins = [Asset.CurrentMargins frozeCash];
                else% �Ѿ����ڿղ�
                    Asset.CurrentMargins(idx_margin) = Asset.CurrentMargins(idx_margin) + frozeCash;
                end
            end
            AvaCash = AvaCash - costOfDeal - dealfee.Open - frozeCash;
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
            else
                Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
                Asset.CurrentPosition = [Asset.CurrentPosition realDealVol];
            end
        end
    end
end
%������׺��²��ֺ�Լ�ղ֣��ڵ�ǰ�ֲ�������ղֵĺ�Լ
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];

idxClearEmptyMargin = Asset.CurrentMargins == 0;
Asset.CurrentMargins(idxClearEmptyMargin) = [];
Asset.CurrentMarginStock(idxClearEmptyMargin) = [];

%% ���¼�¼
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;

Asset.MarginStock{I} = Asset.CurrentMarginStock;
Asset.Margins{I} = Asset.CurrentMargins;

Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;    
end