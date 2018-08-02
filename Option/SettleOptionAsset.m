function Asset = SettleOptionAsset(Asset,DB,Options)
% 用于每日保证金变化
% 用于每日clearing 结束后
I = DB.CurrentK;%当日游标

AvaCash = Asset.Cash(I);                                                    %撮合订单后的可用保证金
FrozenCash = Asset.FrozenCash(I);                                           %撮合订单后的已用保证金总和
Asset.CurrentStock = Asset.Stock{I};                                              %撮合订单后的持仓证券                          
Asset.CurrentPosition = Asset.Position{I};                                        %撮合订单后的持仓量对应证券名
Asset.CurrentMarginStock = Asset.MarginStock{I};
Asset.CurrentMargins = Asset.Margins{I};                                          %撮合订单后的持仓保证金对应证券名   

MarginCallCode = {};                                                        %催缴保证金的合约代码
MarginCallAmount = [];                                                      %催缴保证金的数量
ExpiredContract = {};                                                       %到期合约代码
ExpiredContractPosition = {};                                               %到期合约数量
ExpiredContractSettlePrice ={};                                             %到期合约价格    
today = DB.Times(I);                                                      %结算当日日期
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
    %% 催缴保证金
    %计算维持保证金
    maintainMargin = CalculateMargin(settlePrice,DB.Underlying.Close(I),Strike,contractInfo);
    totalMaintainMarginThisContract = maintainMargin*abs(Asset.CurrentPosition(i))*contractUnit;
    idx_thisStockMargin = strcmp(Asset.CurrentStock(i), Asset.CurrentMarginStock);
    currentMarginThisContract = Asset.CurrentMargins(idx_thisStockMargin);
    % 催缴保证金的状况
    if totalMaintainMarginThisContract > currentMarginThisContract % 维持保证金大于已用保证金
        MarginCallCode = [MarginCallCode Asset.CurrentStock(i)];
        MarginCallAmount = [MarginCallAmount totalMaintainMarginThisContract - currentMarginThisContract];%催缴保证金的数量
    end
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
Asset.MarginCallCodes{I} = MarginCallCode;
Asset.MarginCallAmounts{I} = MarginCallAmount;
% 更新到期合约信息
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end