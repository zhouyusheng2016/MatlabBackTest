function Asset = SettleFutureAsset(Asset,DB,Options)
% 用于每日结算期货保证金变化
% 用于每日clearing 结束后
I = DB.CurrentK;%当日游标

%昨日状态
if I == 1
    PreStock = [];
    PrePosition = [];
    PreMargins = [];
else
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
    PreMargins = Asset.Margins{I-1};
end

AvaCash = Asset.Cash(I);                                                    %撮合订单后的可用保证金
FrozenCash = Asset.FrozenCash(I);                                           %撮合订单后的已用保证金总和
Asset.CurrentStock = Asset.Stock{I};                                        %撮合订单后的持仓证券                          
Asset.CurrentPosition = Asset.Position{I};                                  %撮合订单后的持仓量对应证券名
Asset.CurrentMargins = Asset.Margins{I};                                    %撮合订单后的持仓保证金对应证券名   

ExpiredContract = {};                                                       %到期合约代码
ExpiredContractPosition = {};                                               %到期合约数量
ExpiredContractSettlePrice ={};                                             %到期合约价格

today = DB.Times(I);
for i = 1:length(Asset.CurrentStock)
    Data=getfield(DB,code2structname(Asset.CurrentStock{i},'F'));           %合约行情
    lastTradeDateTime = datetime(Data.Info{1});                             %合约最后交易日 -- 连续合约的最后交易日应该是当前合约的最后交易日（万德数据规则）
    lastTradeDateNum = datenum(lastTradeDateTime);
    contractInfo = GetFutureContractInfo(Data);                             %合约信息
    %% 结算信息
    settlePrice = Data.Settle(I);       
    if lastTradeDateNum <today
       error('SettleFutureAsset.m: contract passed last trade date') 
    end
    flag_AtExpiration = lastTradeDateNum==today;
    %% 每日无负债盯市
    % 今日交易量
    idx_todayTrade = strcmp(Asset.CurrentStock(i),Asset.DealStock{I});     %现持仓合约在交易结算合约中的位置
    todayDealVol = 0;
    todayDealPrice = 0;
    if ~isempty(idx_todayTrade) && sum(idx_todayTrade)~=0
        todayDealVol = Asset.DealVolume{I}(idx_todayTrade);
        todayDealPrice = Asset.DealPrice{I}(idx_todayTrade);
    end
    % 昨日仓位
    idx_lastDayPos = strcmp(Asset.CurrentStock(i), PreStock);
    lastDayPos = 0;
    lastDaySettlePrice = Data.PreSettle(I);
    if sum(idx_lastDayPos)~= 0 && ~isempty(idx_lastDayPos)
        lastDayPos = PrePosition(idx_lastDayPos);
    end
    % 今日开 平数量
    Volume = GetDealVolType(Asset.CurrentPosition(i), lastDayPos, todayDealVol);
    % 今日昨仓剩余数量
    lastDayContiPos = lastDayPos+Volume.close;
    %% 今日交易产生仓位引起的保证金变化
    valueChange_deal = settlePrice - todayDealPrice;
    valueChangePerContract_deal = valueChange_deal*contractInfo.multiplier;
    pnl_deal = valueChangePerContract_deal*Volume.open;                     % 今日开仓的部分
    %% 昨日存续仓位引起的保证金变化
    valueChange_last = settlePrice - lastDaySettlePrice;
    valueChangePerContract_last = valueChange_last*contractInfo.multiplier;
    pnl_last = valueChangePerContract_last*lastDayContiPos;                 % 昨日未被今平的部分
    %% 结算价盈亏引起的总资金变动
    thisPositionPnL = pnl_deal+pnl_last;
    
    totalMarginThisContractBeforeUpdate = Asset.CurrentMargins(i);          % 成交前保证金状态
    
    [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% 更新可用保证金,已用保证金
        (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
    thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;%此仓位已用保证金变化量
    
    Asset.CurrentMargins(i) = totalMarginThisContractAfterUpdate;           %更新至交易时账户的已用保证金数量
    FrozenCash = FrozenCash+thisMarginChange;                               %更新至交易时总已用保证金数量
    
    %% 合约到期的情况
    if flag_AtExpiration
        sprintf(strcat('Bar:', num2str(I), ' Date:', DB.TimesStr(I,:), ' Contract: ', Data.Code, ' Reached Expiration' ))
        FrozenCash = FrozenCash - Asset.CurrentMargins(i);                 %释放冻结资金
        AvaCash = AvaCash + Asset.CurrentMargins(i);
        fee = FutureTradeCommission(settlePrice, Asset.CurrentPosition(i), contractInfo, Options,'Open');% 目前不分开平都填写Open
        AvaCash = AvaCash - fee;
        Asset.DealFee{I} = [Asset.DealFee{I} fee];                          %平仓手续费录入
        
        ExpiredContract = [ExpiredContract  Asset.CurrentStock(i)];
        ExpiredContractPosition = [ExpiredContractPosition Asset.CurrentPosition(i)];
        ExpiredContractSettlePrice = [ExpiredContractSettlePrice, settlePrice];
        % 释放股票信息
        Asset.CurrentMargins(i) = 0;                                        %释放保证金
        Asset.CurrentPosition(i) = 0;                                       %释放仓位
        continue;                                                           %到期卖出合约，close所有仓位，不需要结算保证金
    end
    
    %% 维持保证金变化引起的资金变动
    %维持保证金
    thisContractMaintainMargin = CalculateMaintainMargin(Asset.CurrentPosition(i),contractInfo,settlePrice);% 维持保证金
    % 自动更新保证金至交易账户
    marginChange = thisContractMaintainMargin - Asset.CurrentMargins(i);
    Asset.CurrentMargins(i) = thisContractMaintainMargin;
    AvaCash = AvaCash-marginChange;
    FrozenCash = FrozenCash+marginChange;
end
%% 催缴保证金
if AvaCash < 0
    Asset.MarginCall(I) = AvaCash;
end
%如果交易后导致部分合约空仓，在当前持仓中清除空仓的合约
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];
Asset.CurrentMargins(idxClearEmpty) = [];

%可用保证金，已用保证金更新
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;
Asset.Margins{I} = Asset.CurrentMargins;
Asset.Stock{I} = Asset.CurrentStock;                                                                          
Asset.Position{I} = Asset.CurrentPosition;                                           

% 更新到期合约信息
Asset.ExpiredContract{I}=ExpiredContract;
Asset.ExpiredContractPosition{I}=ExpiredContractPosition;
Asset.ExpiredContractSettlePrice{I}=ExpiredContractSettlePrice;
end
