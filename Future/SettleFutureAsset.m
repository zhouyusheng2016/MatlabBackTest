function Asset = SettleFutureAsset(Asset,DB,Options)
% ����ÿ�ս����ڻ���֤��仯
% ����ÿ��clearing ������
I = DB.CurrentK;%�����α�

%����״̬
if I == 1
    PreStock = [];
    PrePosition = [];
    PreMargins = [];
else
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
    PreMargins = Asset.Margins{I-1};
end

AvaCash = Asset.Cash(I);                                                    %��϶�����Ŀ��ñ�֤��
FrozenCash = Asset.FrozenCash(I);                                           %��϶���������ñ�֤���ܺ�
Asset.CurrentStock = Asset.Stock{I};                                        %��϶�����ĳֲ�֤ȯ                          
Asset.CurrentPosition = Asset.Position{I};                                  %��϶�����ĳֲ�����Ӧ֤ȯ��
Asset.CurrentMargins = Asset.Margins{I};                                    %��϶�����ĳֱֲ�֤���Ӧ֤ȯ��   

ExpiredContract = {};                                                       %���ں�Լ����
ExpiredContractPosition = {};                                               %���ں�Լ����
ExpiredContractSettlePrice ={};                                             %���ں�Լ�۸�

today = DB.Times(I);
for i = 1:length(Asset.CurrentStock)
    Data=getfield(DB,code2structname(Asset.CurrentStock{i},'F'));           %��Լ����
    lastTradeDateTime = datetime(Data.Info{1});                             %��Լ������� -- ������Լ���������Ӧ���ǵ�ǰ��Լ��������գ�������ݹ���
    lastTradeDateNum = datenum(lastTradeDateTime);
    contractInfo = GetFutureContractInfo(Data);                             %��Լ��Ϣ
    %% ������Ϣ
    settlePrice = Data.Settle(I);       
    if lastTradeDateNum <today
       error('SettleFutureAsset.m: contract passed last trade date') 
    end
    flag_AtExpiration = lastTradeDateNum==today;
    %% ÿ���޸�ծ����
    % ���ս�����
    idx_todayTrade = strcmp(Asset.CurrentStock(i),Asset.DealStock{I});     %�ֲֳֺ�Լ�ڽ��׽����Լ�е�λ��
    todayDealVol = 0;
    todayDealPrice = 0;
    if ~isempty(idx_todayTrade) && sum(idx_todayTrade)~=0
        todayDealVol = Asset.DealVolume{I}(idx_todayTrade);
        todayDealPrice = Asset.DealPrice{I}(idx_todayTrade);
    end
    % ���ղ�λ
    idx_lastDayPos = strcmp(Asset.CurrentStock(i), PreStock);
    lastDayPos = 0;
    lastDaySettlePrice = Data.PreSettle(I);
    if sum(idx_lastDayPos)~= 0 && ~isempty(idx_lastDayPos)
        lastDayPos = PrePosition(idx_lastDayPos);
    end
    % ���տ� ƽ����
    Volume = GetDealVolType(Asset.CurrentPosition(i), lastDayPos, todayDealVol);
    % �������ʣ������
    lastDayContiPos = lastDayPos+Volume.close;
    %% ���ս��ײ�����λ����ı�֤��仯
    valueChange_deal = settlePrice - todayDealPrice;
    valueChangePerContract_deal = valueChange_deal*contractInfo.multiplier;
    pnl_deal = valueChangePerContract_deal*Volume.open;                     % ���տ��ֵĲ���
    %% ���մ�����λ����ı�֤��仯
    valueChange_last = settlePrice - lastDaySettlePrice;
    valueChangePerContract_last = valueChange_last*contractInfo.multiplier;
    pnl_last = valueChangePerContract_last*lastDayContiPos;                 % ����δ����ƽ�Ĳ���
    %% �����ӯ����������ʽ�䶯
    thisPositionPnL = pnl_deal+pnl_last;
    
    totalMarginThisContractBeforeUpdate = Asset.CurrentMargins(i);          % �ɽ�ǰ��֤��״̬
    
    [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% ���¿��ñ�֤��,���ñ�֤��
        (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
    thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;%�˲�λ���ñ�֤��仯��
    
    Asset.CurrentMargins(i) = totalMarginThisContractAfterUpdate;           %����������ʱ�˻������ñ�֤������
    FrozenCash = FrozenCash+thisMarginChange;                               %����������ʱ�����ñ�֤������
    
    %% ��Լ���ڵ����
    if flag_AtExpiration
        sprintf(strcat('Bar:', num2str(I), ' Date:', DB.TimesStr(I,:), ' Contract: ', Data.Code, ' Reached Expiration' ))
        FrozenCash = FrozenCash - Asset.CurrentMargins(i);                 %�ͷŶ����ʽ�
        AvaCash = AvaCash + Asset.CurrentMargins(i);
        fee = FutureTradeCommission(settlePrice, Asset.CurrentPosition(i), contractInfo, Options,'Open');% Ŀǰ���ֿ�ƽ����дOpen
        AvaCash = AvaCash - fee;
        Asset.DealFee{I} = [Asset.DealFee{I} fee];                          %ƽ��������¼��
        
        ExpiredContract = [ExpiredContract  Asset.CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition Asset.CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, settlePrice];
        % �ͷŹ�Ʊ��Ϣ
        Asset.CurrentMargins(i) = 0;                                        %�ͷű�֤��
        Asset.CurrentPosition(i) = 0;                                       %�ͷŲ�λ
        continue;                                                           %����������Լ��close���в�λ������Ҫ���㱣֤��
    end
    
    %% ά�ֱ�֤��仯������ʽ�䶯
    %ά�ֱ�֤��
    thisContractMaintainMargin = CalculateMaintainMargin(Asset.CurrentPosition(i),contractInfo,settlePrice);% ά�ֱ�֤��
    % �Զ����±�֤���������˻�
    marginChange = thisContractMaintainMargin - Asset.CurrentMargins(i);
    Asset.CurrentMargins(i) = thisContractMaintainMargin;
    AvaCash = AvaCash-marginChange;
    FrozenCash = FrozenCash+marginChange;
end
%% �߽ɱ�֤��
if AvaCash < 0
    Asset.MarginCall(I) = AvaCash;
end
%������׺��²��ֺ�Լ�ղ֣��ڵ�ǰ�ֲ�������ղֵĺ�Լ
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];
Asset.CurrentMargins(idxClearEmpty) = [];

%���ñ�֤�����ñ�֤�����
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;
Asset.Margins{I} = Asset.CurrentMargins;
Asset.Stock{I} = Asset.CurrentStock;                                                                          
Asset.Position{I} = Asset.CurrentPosition;                                           

% ���µ��ں�Լ��Ϣ
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end
