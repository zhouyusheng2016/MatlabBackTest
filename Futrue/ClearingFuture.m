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
%% 落单撮合
for i = 1:length(Asset.OrderPrice{I})
    %% 考虑交易价格滑点
    dealprice = OrderPirceWithSlippage(Asset.OrderPrice{I}(i), Asset.OrderVolume{I}(i), Options);
    %% 检查限制交易量占市场比
    dealvolume = [];
    Data=getfield(DB,code2structname(Asset.OrderStock{I}{i},'F'));
    dealvolume = AdaptDealVolumeToMarket(I,Data,Asset.OrderVolume{I}(i),Options);
    dealvolume = floor(dealvolume);                                         % 必须整数买入

    %% 获取合约信息（初始保证金，交易保证金，合约乘数）
    contractInfo = GetFutureContractInfo(Data);
    %% 计算合约金额
    nomialValuePerContract = dealprice*contractInfo.multiplier;
    initialMarginValuePerContract = nomialValuePerContract*contractInfo.imargin;
    %% 注意开平仓区别
    %检测开平数量
    idxThisStockInCurrentStock = findPositionByName(Asset.OrderStock{I}(i), Asset.CurrentStock);
    thisStockCurrentPosition = Asset.CurrentPosition(idxThisStockInCurrentStock);
    if isempty(thisStockCurrentPosition)
        % 如果不存在仓位则持仓为0
       thisStockCurrentPosition = 0; 
    end
    %判断交易方向
    if dealvolume > 0
        flag_direction = 'Long';
    else
        flag_direction = 'Short';
    end
    % 判断交易开平
    tradeVolume.Close = 0;
    tradeVolume.Open = 0;
    if dealvolume*thisStockCurrentPosition < 0
        if abs(dealvolume)>abs(thisStockCurrentPosition)
            flag_type = {'Close','Open'};%需要先平再开
            tradeVolume.Close = sign(dealvolume)*abs(thisStockCurrentPosition);
            tradeVolume.Open = sign(dealvolume)*(abs(dealvolume)-abs(thisStockCurrentPosition));
        else
            flag_type = {'Close'};%平仓
            tradeVolume.Close = dealvolume;
        end
    else
        flag_type = {'Open'};%开仓
        tradeVolume.Open = dealvolume;
    end
    
    if dealvolume~=0
        %% 自此之下不应该出现总交易量 dealvolume
        %% 撮合平仓,先平仓再开仓
        %撮合前调整账户信息至撮合时  
        flag_settled = false;
        if  thisStockCurrentPosition ~= 0
            lastSettlePrice = Data.Settle(I-1);                             % 上次清算价格,为平仓操作意味着存在I-1的价格
            priceChange = dealprice - lastSettlePrice;                      % 平仓时价格与上次结算价的差值
            priceChangePerContract = priceChange*contractInfo.multiplier;   % 每张合约的价值变化
            thisPositionPnL = thisStockCurrentPosition*priceChangePerContract; %此合约品种上从上次清算到现在的盈亏
            totalMarginThisContractBeforeUpdate = Asset.CurrentMargins(idxThisStockInCurrentStock); % 成交前保证金状态
            
            [AvaCash, totalMarginThisContractAfterUpdate] = ChangeAccountBalanceWithPnL...% 更新可用保证金,已用保证金
                (thisPositionPnL, AvaCash, totalMarginThisContractBeforeUpdate);
            thisMarginChange = totalMarginThisContractAfterUpdate - totalMarginThisContractBeforeUpdate;%此仓位已用保证金变化量
            Asset.CurrentMargins(idxThisStockInCurrentStock) = totalMarginThisContractAfterUpdate; %更新至交易时账户的已用保证金数量
            FrozenCash = FrozenCash+thisMarginChange;                           %更新至交易时总已用保证金数量
            
            % 调整合约的结算价格记录--最后未真实成交但是已经结算的情况
            Asset.SettleCode{I} = [Asset.SettleCode{I} Asset.OrderStock{I}(i)]; %交易价格结算过的证券代码
            Asset.Settle{I} = [Asset.Settle{I} dealprice];                  %结算的交易价格
            flag_settled = true;
        end
        %交易发生
        dealfee.Open = 0;
        dealfee.Close = 0;
        unfrozeCash = 0;
        frozeCash = 0;
        if tradeVolume.Close~=0
            % 释放保证金
            releaseMarginByPercentage = -tradeVolume.Close/thisStockCurrentPosition;%计算释放保证金的比例
            unfrozeCash = releaseMarginByPercentage*Asset.CurrentMargins(idxThisStockInCurrentStock);%计算释放保证金的数额
             % 计算平仓手续费
            dealfee.Close = FutureTradeCommission(dealprice, tradeVolume.Close, contractInfo, Options,'Open');%暂时按照统一手续费
            AvaCash = AvaCash+unfrozeCash-dealfee.Close;                    %可用保证金变动 
        end
        if tradeVolume.Open~=0
            %验证是否开仓导致资金不足，引起部分开仓
            tradeVolume.Open = AdaptDealVolumeWithAvaCash(Data,I,AvaCash,tradeVolume.Open,dealprice,contractInfo, Options);
            if tradeVolume.Open~=0
                % 计算开仓手续费
                dealfee.Open = FutureTradeCommission(dealprice, tradeVolume.Open, contractInfo, Options,'Open');%暂时按照统一手续费
                % 新占用保证金
                frozeCash = abs(tradeVolume.Open)*initialMarginValuePerContract;
                % 可用保证金变动
                AvaCash = AvaCash - frozeCash - dealfee.Open;
            end
        end
        marginChange = frozeCash - unfrozeCash; %新增保证金 - 释放保证金
        FrozenCash = FrozenCash + marginChange;                                     %更新已用保证金总合
        realDealVol = tradeVolume.Open + tradeVolume.Close;%真实成交量
        
        if realDealVol~=0                                                           %最后真实成交量不为0
            % 记录成交
            Asset.DealStock{I} = [Asset.DealStock{I} Asset.OrderStock{I}(i)];       %更新成交code
            Asset.DealVolume{I} = [Asset.DealVolume{I} realDealVol];                %更新成交量
            Asset.DealPrice{I} = [Asset.DealPrice{I} dealprice];                    %更新成交价格
            totalDealfee = dealfee.Open + dealfee.Close;                            % 总交易手续费
            Asset.DealFee{I} = [Asset.DealFee{I} totalDealfee];                     %更新成交手续费
            % 更新现有持仓状态
            if sum(idxThisStockInCurrentStock) > 0 %现持仓有记录
                if sum(idxThisStockInCurrentStock) > 1 %现持仓有多条记录
                    error('当前持仓存在名称重复');
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
            if ~flag_settled
                % 调整合约的结算价格记录--开新仓的情况
                Asset.SettleCode{I} = [Asset.SettleCode{I} Asset.OrderStock{I}(i)]; %交易价格结算过的证券代码
                Asset.Settle{I} = [Asset.Settle{I} dealprice];                  %结算的交易价格
            end
        end
    end
end
%如果交易后导致部分合约空仓，在当前持仓中清除空仓的合约
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];
Asset.CurrentMargins(idxClearEmpty) = [];

%% 更新记录
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;
Asset.Margins{I} = Asset.CurrentMargins;
Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;    
end
