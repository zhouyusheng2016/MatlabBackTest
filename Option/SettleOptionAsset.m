function Asset = SettleOptionAsset(Asset,DB,Options)
% ����ÿ�ձ�֤��仯
% ����ÿ��clearing ������
I = DB.CurrentK;%�����α�
% ��������ǰ����Ϣ
if I == 1
    PreStock = [];
    PrePosition = [];
else
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
end

AvaCash = Asset.Cash(I);                                                    %��϶�����Ŀ��ñ�֤��
FrozenCash = Asset.FrozenCash(I);                                           %��϶���������ñ�֤���ܺ�
Asset.CurrentStock = Asset.Stock{I};                                              %��϶�����ĳֲ�֤ȯ                          
Asset.CurrentPosition = Asset.Position{I};                                        %��϶�����ĳֲ�����Ӧ֤ȯ��
Asset.CurrentMarginStock = Asset.MarginStock{I};
Asset.CurrentMargins = Asset.Margins{I};                                          %��϶�����ĳֱֲ�֤���Ӧ֤ȯ��   

MarginCallCode = {};                                                        %�߽ɱ�֤��ĺ�Լ����
MarginCallAmount = [];                                                      %�߽ɱ�֤�������
ExpiredContract = {};                                                       %���ں�Լ����
ExpiredContractPosition = {};                                               %���ں�Լ����
ExpiredContractSettlePrice ={};                                             %���ں�Լ�۸�    

for i = 1:length(Asset.CurrentStock)
    %% ��Լ��Ϣ
    Data=getfield(DB,code2structname(Asset.CurrentStock{i},'O')); 
    contractInfo = GetOptionContractInfo(Data);                             %��Լ������Ϣ
    contractUnit = Data.ContractUnit(I);                                    %��Լ��λ
    Strike = Data.Strike(I);                                                %��Լ��Ȩ��
    
    today = Data.Times(I);                                                  %���㵱������
    lasttrade_date = datenum(Data.Info{2});                                 %��Լ������
    flag_atExpirary = lasttrade_date == today;                              %��Լ���ڱ�־
    if lasttrade_date < today
       error('SettleOptionAsset.m: passed last trade date, need deliver')   %���� 
    end
    %% ��Լ����
    if flag_atExpirary
        % �����Լ
        payoff = CalculateOptionPayoff(DB.Underlying.Close(I), Strike,...
            contractInfo, contractUnit, Asset.CurrentPosition(i));
        releaseMargin = 0;
        if Asset.CurrentPosition(i) < 0
            idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
            releaseMargin = Asset.CurrentMargins(idx_thisStockMargin);
            if isempty(releaseMargin)
                error('settleOptionAsset.m: negative position but no margin found')
            end
        end
        settlementFee = Options.SettlementFeePerContract*abs(Asset.CurrentPosition(i));
        AvaCash = AvaCash + payoff + releaseMargin - settlementFee;
        FrozenCash = FrozenCash - releaseMargin;
        % ��¼
        ExpiredContract = [ExpiredContract  Asset.CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition Asset.CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, payoff/Asset.CurrentPosition(i)];
        Asset.SettlementFee{I}= [Asset.SettlementFee{I} settlementFee];
        % �ͷŲ�λ ��֤��
        Asset.CurrentMargins(i) = 0;
        Asset.CurrentPosition(i) = 0;
        continue;
    end
    %% ���������ı�֤��仯
    % �����������
    if Asset.CurrentPosition(i)>=0
       continue; 
    end
    %% ���ν���۸�
    if strcmp(Options.OptLastSettlementType,'Close')
        settlePrice = Data.Close(I);
    elseif strcmp(Options.OptLastSettlementType,'Settle')
        settlePrice = Data.Settle(I);
    else
        error('SettleOptionAsset.m: Undefined Settle Price')
    end
     %% ȷ���ϴν����
    idx_thisStockTodayDeal = strcmp(Asset.CurrentStock(i), Asset.DealStock{I});  %���ձ���Լ�Ŀ���
    todayDealVolume = 0;
    todayDealPrice = 0;
    if sum(idx_thisStockTodayDeal) ~= 0
        todayDealVolume = Asset.DealVolume{I}(idx_thisStockTodayDeal);     %��Լ���տ�����
        todayDealPrice = Asset.DealPrice{I}(idx_thisStockTodayDeal);       %��Լ���տ��ּ۸� 
    end
    % ����Լ����֮ǰ�Ĳ�λ
    idx_thisStockLastDayEnd = strcmp(Asset.CurrentStock(i), PreStock);            % ���մ����ĺ�Լ
    lastDayEndPosition = 0;                                                 % ���մ�����Լ��
    lastDayEndSettlePrice = 0;                                              % ���ս����
    contractUnitLastDay = contractUnit;                                     % ���պ�Լ����
    if sum(idx_thisStockLastDayEnd) ~= 0
        lastDayEndPosition = PrePosition(idx_thisStockLastDayEnd);
        lastDayEndSettlePrice = GetOptionContractPreSettlePriceByType( Data, I, Options.OptLastSettlementType);
        contractUnitLastDay = Data.ContractUnit(I-1);                       
    end
    
    %% �ֱ���㱣֤��䶯
    %���տ��ֵĺ�Լ
    priceChangeToday = settlePrice - todayDealPrice;
    priceChangeTodayPerContract = priceChangeToday*contractUnit;
    todayDealPnL = todayDealVolume*priceChangeTodayPerContract;
    %���մ����ĺ�Լ
    priceChangeLastDayPerContract = settlePrice*contractUnit - lastDayEndSettlePrice*contractUnitLastDay;
    lastDayPnL = lastDayEndPosition*priceChangeLastDayPerContract;
    % �ܱ�֤��䶯
    PnL = todayDealPnL+lastDayPnL;
    %% ��֤��״̬
    idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
    totalMarginThisContractBeforeUpdate = Asset.CurrentMargins(idx_thisStockMargin); 
    %% ����˻���֤��
    [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% ���¿��ñ�֤��,���ñ�֤��
        (PnL, AvaCash, totalMarginThisContractBeforeUpdate);
    marginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;
    
    Asset.CurrentMargins(idx_thisStockMargin) = totalMarginThisContractAfterUpdate;                
    FrozenCash = FrozenCash+marginChange;   
    %% �߽ɱ�֤��
    %����ά�ֱ�֤��
    maintainMargin = CalculateMargin(settlePrice,DB.Underlying.Close(I),Strike,contractInfo);
    totalMaintainMarginThisContract = maintainMargin*abs(Asset.CurrentPosition(i));
    % �߽ɱ�֤���״��
    if totalMaintainMarginThisContract > totalMarginThisContractAfterUpdate % ά�ֱ�֤��������ñ�֤��
        MarginCallCode = [MarginCallCode Asset.CurrentStock(i)];
        MarginCallAmount = [MarginCallAmount totalMaintainMarginThisContract - totalMarginThisContractAfterUpdate];%�߽ɱ�֤�������
    end
end
% ����Ѿ������ڵı�֤�����λ
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];

idxClearEmptyMargin = Asset.CurrentMargins == 0;
Asset.CurrentMargins(idxClearEmptyMargin) = [];
Asset.CurrentMarginStock(idxClearEmptyMargin) = [];
%���ñ�֤�����ñ�֤�����
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;

Asset.Margins{I} = Asset.CurrentMargins;
Asset.MarginStock{I} = Asset.CurrentMarginStock;

Asset.Stock{I} = Asset.CurrentStock;                                                                          
Asset.Position{I} = Asset.CurrentPosition;                                           

%��֤��߽ɼ�¼����
Asset.MarginCallCodes{I} = MarginCallCode;
Asset.MarginCallAmounts{I} = MarginCallAmount;
% ���µ��ں�Լ��Ϣ
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end