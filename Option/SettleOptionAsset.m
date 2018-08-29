function Asset = SettleOptionAsset(Asset,DB,Options)
% 用于每日保证金变化
% 用于每日clearing 结束后
I = DB.CurrentK;%当日游标

AvaCash = Asset.Cash(I);                                                    %撮合订单后的可用保证金
FrozenCash = Asset.FrozenCash(I);                                           %撮合订单后的已用保证金总和
Asset.CurrentStock = Asset.Stock{I};                                        %撮合订单后的持仓证券                          
Asset.CurrentPosition = Asset.Position{I};                                  %撮合订单后的持仓量对应证券名
Asset.CurrentMarginStock = Asset.MarginStock{I};
Asset.CurrentMargins = Asset.Margins{I};                                    %撮合订单后的持仓保证金对应证券名   

ExpiredContract = {};                                                       %到期合约代码
ExpiredContractPosition = {};                                               %到期合约数量
ExpiredContractSettlePrice ={};                                             %到期合约价格    
today = DB.Times(I);                                                        %结算当日日期
MaginCall = 0;
for i = 1:length(Asset.CurrentStock)
    %% 合约信息
    Data=getfield(DB,code2structname(Asset.CurrentStock{i},'O')); 
    contractInfo = GetOptionContractInfo(Data);                             %合约基本信息
    contractUnit = Data.ContractUnit(I);                                    %合约单位
    Strike = Data.Strike(I);                                                %合约行权价

    lasttrade_date = datenum(Data.Info{2});                                 %合约到期日
    flag_atExpirary = lasttrade_date == today;                              %合约到期标志
    if lasttrade_date < today
       error('SettleOptionAsset.m: passed last trade date, need deliver')   %交割 
    end
    %% 合约到期结算
    if flag_atExpirary
        % 结算合约
        payoff = CalculateOptionPayoff(DB.Underlying.Close(I), Strike,...
            contractInfo, contractUnit, Asset.CurrentPosition(i));
        releaseMargin = 0;
        if Asset.CurrentPosition(i) < 0
            idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
            releaseMargin = Asset.CurrentMargins(idx_thisStockMargin);
            if isempty(releaseMargin)
                error('settleOptionAsset.m: negative position but no margin found')
            end
            %释放保证金
            Asset.CurrentMargins(idx_thisStockMargin) = 0;
        end
        settlementFee = Options.SettlementFeePerContract*abs(Asset.CurrentPosition(i));
        AvaCash = AvaCash + payoff + releaseMargin - settlementFee;
        FrozenCash = FrozenCash - releaseMargin;
        % 记录
        ExpiredContract = [ExpiredContract  Asset.CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition Asset.CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, payoff/Asset.CurrentPosition(i)];
        Asset.SettlementFee{I}= [Asset.SettlementFee{I} settlementFee];
        % 释放仓位
        Asset.CurrentPosition(i) = 0;
        continue;
    end
    %% 义务仓保证金催缴
    % 跳过非义务仓
    if Asset.CurrentPosition(i)>=0
       continue; 
    end
    %% 本次结算价格
    if strcmp(Options.OptLastSettlementType,'Close')
        settlePrice = Data.Close(I);
    elseif strcmp(Options.OptLastSettlementType,'Settle')
        settlePrice = Data.Settle(I);
    else
        error('SettleOptionAsset.m: Undefined Settle Price')
    end
    %计算维持保证金
    maintainMargin = CalculateMargin(settlePrice,DB.Underlying.Close(I),Strike,contractInfo);
    totalMaintainMarginThisContract = maintainMargin*abs(Asset.CurrentPosition(i))*contractUnit;
    %目前账户已用保证金余额
    idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
    totalMarginThisContractNow = Asset.CurrentMargins(idx_thisStockMargin);
    % 可用保证金变化
    marginChange = totalMaintainMarginThisContract - totalMarginThisContractNow;
    %% 每日盯市使可用保证金 已用保证金变化
    % 更新已用保证金可用保证金
    AvaCash = AvaCash - marginChange;
    FrozenCash = FrozenCash + marginChange;
    Asset.CurrentMargins(idx_thisStockMargin) = totalMaintainMarginThisContract;
end
%% 催缴保证金
totalMargin = sum(Asset.CurrentMargins);
accountMargin = AvaCash + totalMargin;
if totalMargin > accountMargin % 维持保证金大于已用保证金
    MaginCall = totalMargin-accountMargin;    
end

% 清除已经不存在的保证金与仓位
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];

idxClearEmptyMargin = Asset.CurrentMargins == 0;
Asset.CurrentMargins(idxClearEmptyMargin) = [];
Asset.CurrentMarginStock(idxClearEmptyMargin) = [];
%可用保证金，已用保证金更新
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;

Asset.Margins{I} = Asset.CurrentMargins;
Asset.MarginStock{I} = Asset.CurrentMarginStock;

Asset.Stock{I} = Asset.CurrentStock;                                                                          
Asset.Position{I} = Asset.CurrentPosition;                                           

%保证金催缴记录更新
Asset.MarginCall(I)=MaginCall;
% 更新到期合约信息
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end