function Asset = SettleOptionAsset(Asset,DB,Options)
% ����ÿ�ձ�֤��仯
% ����ÿ��clearing ������
I = DB.CurrentK;%�����α�

AvaCash = Asset.Cash(I);                                                    %��϶�����Ŀ��ñ�֤��
FrozenCash = Asset.FrozenCash(I);                                           %��϶���������ñ�֤���ܺ�
Asset.CurrentStock = Asset.Stock{I};                                        %��϶�����ĳֲ�֤ȯ                          
Asset.CurrentPosition = Asset.Position{I};                                  %��϶�����ĳֲ�����Ӧ֤ȯ��
Asset.CurrentMarginStock = Asset.MarginStock{I};
Asset.CurrentMargins = Asset.Margins{I};                                    %��϶�����ĳֱֲ�֤���Ӧ֤ȯ��   

ExpiredContract = {};                                                       %���ں�Լ����
ExpiredContractPosition = {};                                               %���ں�Լ����
ExpiredContractSettlePrice ={};                                             %���ں�Լ�۸�    
today = DB.Times(I);                                                        %���㵱������
MaginCall = 0;
for i = 1:length(Asset.CurrentStock)
    %% ��Լ��Ϣ
    Data=getfield(DB,code2structname(Asset.CurrentStock{i},'O')); 
    contractInfo = GetOptionContractInfo(Data);                             %��Լ������Ϣ
    contractUnit = Data.ContractUnit(I);                                    %��Լ��λ
    Strike = Data.Strike(I);                                                %��Լ��Ȩ��

    lasttrade_date = datenum(Data.Info{2});                                 %��Լ������
    flag_atExpirary = lasttrade_date == today;                              %��Լ���ڱ�־
    if lasttrade_date < today
       error('SettleOptionAsset.m: passed last trade date, need deliver')   %���� 
    end
    %% ��Լ���ڽ���
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
            %�ͷű�֤��
            Asset.CurrentMargins(idx_thisStockMargin) = 0;
        end
        settlementFee = Options.SettlementFeePerContract*abs(Asset.CurrentPosition(i));
        AvaCash = AvaCash + payoff + releaseMargin - settlementFee;
        FrozenCash = FrozenCash - releaseMargin;
        % ��¼
        ExpiredContract = [ExpiredContract  Asset.CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition Asset.CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, payoff/Asset.CurrentPosition(i)];
        Asset.SettlementFee{I}= [Asset.SettlementFee{I} settlementFee];
        % �ͷŲ�λ
        Asset.CurrentPosition(i) = 0;
        continue;
    end
    %% ����ֱ�֤��߽�
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
    %����ά�ֱ�֤��
    maintainMargin = CalculateMargin(settlePrice,DB.Underlying.Close(I),Strike,contractInfo);
    totalMaintainMarginThisContract = maintainMargin*abs(Asset.CurrentPosition(i))*contractUnit;
    %Ŀǰ�˻����ñ�֤�����
    idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
    totalMarginThisContractNow = Asset.CurrentMargins(idx_thisStockMargin);
    % ���ñ�֤��仯
    marginChange = totalMaintainMarginThisContract - totalMarginThisContractNow;
    %% ÿ�ն���ʹ���ñ�֤�� ���ñ�֤��仯
    % �������ñ�֤����ñ�֤��
    AvaCash = AvaCash - marginChange;
    FrozenCash = FrozenCash + marginChange;
    Asset.CurrentMargins(idx_thisStockMargin) = totalMaintainMarginThisContract;
end
%% �߽ɱ�֤��
totalMargin = sum(Asset.CurrentMargins);
accountMargin = AvaCash + totalMargin;
if totalMargin > accountMargin % ά�ֱ�֤��������ñ�֤��
    MaginCall = totalMargin-accountMargin;    
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
Asset.MarginCall(I)=MaginCall;
% ���µ��ں�Լ��Ϣ
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end