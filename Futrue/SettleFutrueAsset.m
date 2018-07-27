function Asset = SettleFutrueAsset(Asset,DB,Options)
% ����ÿ�ս����ڻ���֤��仯
% ����ÿ��clearing ������
I = DB.CurrentK;%�����α�

AvaCash = Asset.Cash(I);                                                    %��϶�����Ŀ��ñ�֤��
FrozenCash = Asset.FrozenCash(I);                                           %��϶���������ñ�֤���ܺ�
CurrentStock = Asset.Stock{I};                                                  %��϶�����ĳֲ�֤ȯ                          
CurrentPosition = Asset.Position{I};                                            %��϶�����ĳֲ�����Ӧ֤ȯ��
CurrentMargins = Asset.Margins{I};                                              %��϶�����ĳֱֲ�֤���Ӧ֤ȯ��   

TradeSettledStock = Asset.SettleCode{I};                                    %�����н������֤ȯ����       
TradeSettledPrice = Asset.Settle{I};                                        %�����н������֤ȯ�۸��Ӧ����֤ȯ����

MarginCallCode = {};                                                        %�߽ɱ�֤��ĺ�Լ����
MarginCallAmount = [];                                                      %�߽ɱ�֤�������
ExpiredContract = {};                                                       %���ں�Լ����
ExpiredContractPosition = {};                                               %���ں�Լ����
ExpiredContractSettlePrice ={};                                             %���ں�Լ�۸�    
for i = 1:length(CurrentStock)
    Data=getfield(DB,code2structname(CurrentStock{i},'F'));                 %��Լ����
    lastTradeDateTime = datetime(Data.Info{1});                                        %��Լ������� -- ������Լ���������Ӧ���ǵ�ǰ��Լ��������գ�������ݹ���
    contractInfo = GetFutureContractInfo(Data);                             %��Լ��Ϣ
    %% ������Ϣ
    settlePrice = Data.Settle(I);                                           %��Լ���ս���۸�
    % CurrentPosition(i) ��Լ�ĳֲ�����
    %% ȷ���ϴν����
    idx_tradeSettled = strcmp(CurrentStock(i),TradeSettledStock);           %�ֲֳֺ�Լ�ڽ��׽����Լ�е�λ��
    if isempty(idx_tradeSettled)%����ֲֵĺ�Լû�б����׽����
        idx_tradeSettled = 0;
    end
    flag_tradeSettled = sum(idx_tradeSettled) ~= 0;                         %�Ƿ񾭹������н���           
    if flag_tradeSettled
        lastSettlePrice = TradeSettledPrice(idx_tradeSettled);              %�����׽�������i�����Ϊ
    else
        lastSettlePrice = Data.Settle(I-1);                                 %δ�����׽������ϴν����Ϊ
        if isnan(Data.Settle(I-1))
           %������ս���۲�����
           error('SettleFutreAsset.m:�����ڽ���۸�')
        end
    end
    %% �����Ե�ƽ��
    todayNum = DB.Times(I);                                                 % ����������
    lastTradeDateNum = datenum(lastTradeDateTime);                          % �������������
    % �����������
    flag_closeOnLastTradeDate = false;
    if todayNum >= lastTradeDateNum % ������������
        if todayNum > lastTradeDateNum
           error('�ڻ��ֲֳ���������գ�����н���') 
           return;
        end
        flag_closeOnLastTradeDate = true;
    end
    %% ���㱣֤��仯
    priceChange = settlePrice - lastSettlePrice;                            % ����۸����ϴν���۵Ĳ�ֵ
    priceChangePerContract = priceChange*contractInfo.multiplier;           % ÿ�ź�Լ�ļ�ֵ�仯
    thisPositionPnL = CurrentPosition(i)*priceChangePerContract;            % �˺�ԼƷ���ϴ��ϴ����㵽���ڵ�ӯ��
    totalMarginThisContractBeforeUpdate = CurrentMargins(i);                % �ɽ�ǰ��֤��״̬
    
    [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% ���¿��ñ�֤��,���ñ�֤��
        (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
    thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;%�˲�λ���ñ�֤��仯��
    
    CurrentMargins(i) = totalMarginThisContractAfterUpdate;                 %����������ʱ�˻������ñ�֤������
    FrozenCash = FrozenCash+thisMarginChange;                               %����������ʱ�����ñ�֤������
    if ~flag_closeOnLastTradeDate % ���δ�ǵ�����
        %��֤��߽�
        %�������׽�������ñ�֤������Ǹ�������ÿ�ս����д��������Ҫ�߽ɱ�֤��
        thisContractMaintainMargin = CalculateMaintainMargin(CurrentPosition(i),contractInfo,settlePrice);% ά�ֱ�֤��
        if totalMarginThisContractAfterUpdate < thisContractMaintainMargin%��С��ά�ֱ�֤��
            %�߽ɱ�֤��
            MarginCallCode = [MarginCallCode CurrentStock(i)];
            MarginCallAmount = [MarginCallAmount thisContractMaintainMargin - totalMarginThisContractAfterUpdate];%�߽ɱ�֤�������
        end
    else% �����Լ����
        sprintf(strcat('Bar:', num2str(I), ' Date:', DB.TimesStr(I,:), ' Contract: ', Data.Code, ' Reached Expiration' ))
        FrozenCash = FrozenCash - CurrentMargins(i);                        %�ͷŶ����ʽ�
        AvaCash = AvaCash + CurrentMargins(i);  
        fee = FutureTradeCommission(settlePrice, CurrentPosition(i), contractInfo, Options,'Open');% Ŀǰ���ֿ�ƽ����дOpen
        AvaCash = AvaCash - fee;
        Asset.DealFee{I} = [Asset.DealFee{I} fee];                          %ƽ��������¼��
        
        ExpiredContract = [ExpiredContract  CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, settlePrice];
        % �ͷŹ�Ʊ��Ϣ
        CurrentMargins(i) = [];
        CurrentPosition(i) = [];                                             %�ͷŲ�λ
        CurrentStock(i) = [];
    end
end
%���ñ�֤�����ñ�֤�����
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;
Asset.Margins{I} = CurrentMargins;
Asset.Stock{I} = CurrentStock;                                                                          
Asset.Position{I} = CurrentPosition;                                           

%��֤��߽ɼ�¼����
Asset.MarginCallCodes{I} = MarginCallCode;
Asset.MarginCallAmounts{I} = MarginCallAmount;
% ���µ��ں�Լ��Ϣ
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end
