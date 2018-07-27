function Asset = SettleFutrueAsset(Asset,DB,Options)
% 用于每日结算期货保证金变化
% 用于每日clearing 结束后
I = DB.CurrentK;%当日游标

AvaCash = Asset.Cash(I);                                                    %撮合订单后的可用保证金
FrozenCash = Asset.FrozenCash(I);                                           %撮合订单后的已用保证金总和
CurrentStock = Asset.Stock{I};                                                  %撮合订单后的持仓证券                          
CurrentPosition = Asset.Position{I};                                            %撮合订单后的持仓量对应证券名
CurrentMargins = Asset.Margins{I};                                              %撮合订单后的持仓保证金对应证券名   

TradeSettledStock = Asset.SettleCode{I};                                    %交易中结算过的证券代码       
TradeSettledPrice = Asset.Settle{I};                                        %交易中结算过的证券价格对应结算证券代码

MarginCallCode = {};                                                        %催缴保证金的合约代码
MarginCallAmount = [];                                                      %催缴保证金的数量
ExpiredContract = {};                                                       %到期合约代码
ExpiredContractPosition = {};                                               %到期合约数量
ExpiredContractSettlePrice ={};                                             %到期合约价格    
for i = 1:length(CurrentStock)
    Data=getfield(DB,code2structname(CurrentStock{i},'F'));                 %合约行情
    lastTradeDateTime = datetime(Data.Info{1});                                        %合约最后交易日 -- 连续合约的最后交易日应该是当前合约的最后交易日（万德数据规则）
    contractInfo = GetFutureContractInfo(Data);                             %合约信息
    %% 结算信息
    settlePrice = Data.Settle(I);                                           %合约当日结算价格
    % CurrentPosition(i) 合约的持仓数量
    %% 确定上次结算价
    idx_tradeSettled = strcmp(CurrentStock(i),TradeSettledStock);           %现持仓合约在交易结算合约中的位置
    if isempty(idx_tradeSettled)%如果持仓的合约没有被交易结算过
        idx_tradeSettled = 0;
    end
    flag_tradeSettled = sum(idx_tradeSettled) ~= 0;                         %是否经过交易中结算           
    if flag_tradeSettled
        lastSettlePrice = TradeSettledPrice(idx_tradeSettled);              %被交易结算则上i结算价为
    else
        lastSettlePrice = Data.Settle(I-1);                                 %未被交易结算则上次结算价为
        if isnan(Data.Settle(I-1))
           %如果昨日结算价不存在
           error('SettleFutreAsset.m:不存在结算价格')
        end
    end
    %% 到期自当平仓
    todayNum = DB.Times(I);                                                 % 今日日期数
    lastTradeDateNum = datenum(lastTradeDateTime);                          % 最后交易日日期数
    % 最后交易日问题
    flag_closeOnLastTradeDate = false;
    if todayNum >= lastTradeDateNum % 如果是最后交易日
        if todayNum > lastTradeDateNum
           error('期货持仓超过最后交易日，需进行交割') 
           return;
        end
        flag_closeOnLastTradeDate = true;
    end
    %% 结算保证金变化
    priceChange = settlePrice - lastSettlePrice;                            % 结算价格与上次结算价的差值
    priceChangePerContract = priceChange*contractInfo.multiplier;           % 每张合约的价值变化
    thisPositionPnL = CurrentPosition(i)*priceChangePerContract;            % 此合约品种上从上次清算到现在的盈亏
    totalMarginThisContractBeforeUpdate = CurrentMargins(i);                % 成交前保证金状态
    
    [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% 更新可用保证金,已用保证金
        (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
    thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;%此仓位已用保证金变化量
    
    CurrentMargins(i) = totalMarginThisContractAfterUpdate;                 %更新至交易时账户的已用保证金数量
    FrozenCash = FrozenCash+thisMarginChange;                               %更新至交易时总已用保证金数量
    if ~flag_closeOnLastTradeDate % 如果未非到期日
        %保证金催缴
        %经过交易结算的已用保证金可能是负数，在每日结算中此种情况需要催缴保证金
        thisContractMaintainMargin = CalculateMaintainMargin(CurrentPosition(i),contractInfo,settlePrice);% 维持保证金
        if totalMarginThisContractAfterUpdate < thisContractMaintainMargin%如小于维持保证金
            %催缴保证金
            MarginCallCode = [MarginCallCode CurrentStock(i)];
            MarginCallAmount = [MarginCallAmount thisContractMaintainMargin - totalMarginThisContractAfterUpdate];%催缴保证金的数量
        end
    else% 如果合约到期
        sprintf(strcat('Bar:', num2str(I), ' Date:', DB.TimesStr(I,:), ' Contract: ', Data.Code, ' Reached Expiration' ))
        FrozenCash = FrozenCash - CurrentMargins(i);                        %释放冻结资金
        AvaCash = AvaCash + CurrentMargins(i);  
        fee = FutureTradeCommission(settlePrice, CurrentPosition(i), contractInfo, Options,'Open');% 目前不分开平都填写Open
        AvaCash = AvaCash - fee;
        Asset.DealFee{I} = [Asset.DealFee{I} fee];                          %平仓手续费录入
        
        ExpiredContract = [ExpiredContract  CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, settlePrice];
        % 释放股票信息
        CurrentMargins(i) = [];
        CurrentPosition(i) = [];                                             %释放仓位
        CurrentStock(i) = [];
    end
end
%可用保证金，已用保证金更新
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;
Asset.Margins{I} = CurrentMargins;
Asset.Stock{I} = CurrentStock;                                                                          
Asset.Position{I} = CurrentPosition;                                           

%保证金催缴记录更新
Asset.MarginCallCodes{I} = MarginCallCode;
Asset.MarginCallAmounts{I} = MarginCallAmount;
% 更新到期合约信息
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end
