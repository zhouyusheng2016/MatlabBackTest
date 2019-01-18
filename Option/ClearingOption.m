function Asset = ClearingOption(Asset,DB,Options)
%% 获取账户状态
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
%% 落单撮合
for i = 1:length(Asset.OrderPrice{I})
    %% 考虑交易价格滑点
    dealprice = OrderPirceWithSlippage(Asset.OrderPrice{I}(i), Asset.OrderVolume{I}(i), Options);
    %% 检查限制交易量占市场比
    dealvolume = [];
    Data=getfield(DB,code2structname(Asset.OrderStock{I}{i},Options.OptionType));
    dealvolume = AdaptDealVolumeToMarket(I,Data,Asset.OrderVolume{I}(i),Options);
    dealvolume = floor(dealvolume);                                         % 必须整数买入

    %% 获取合约信息（初始保证金，交易保证金，合约乘数）
    contractInfo = GetOptionContractInfo(Data);
    contractUnit = Data.ContractUnit(I);                                    %涉及合约调整
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
        %交易发生
        dealfee.Open = 0;
        dealfee.Close = 0;
        unfrozeCash = 0;
        frozeCash = 0;
        
        %先平仓在开仓的原则
        % 平仓
        if tradeVolume.Close ~= 0
            costOfDeal = tradeVolume.Close *dealprice * contractUnit;
            dealfee.Close = abs(tradeVolume.Close)*Options.CommissionPerContract;
            % 空仓平仓需要释放保证金
            if tradeVolume.Close>0
                idx_margin = findPositionByName(Asset.OrderStock{I}(i),Asset.CurrentMarginStock);
                thisStockCurrentMargin = Asset.CurrentMargins(idx_margin);
                if isempty(thisStockCurrentMargin)
                    thisStockCurrentMargin = 0;
                end
                marginReleaseByOneContract = thisStockCurrentMargin...
                    /abs(thisStockCurrentPosition);
                % 根据账户状态调整买回的仓量
                tradeVolume.Close = AdaptCloseShortVolumeToAvaCash(Data, I,...
                    tradeVolume.Close, AvaCash,dealprice, contractUnit, ...
                    marginReleaseByOneContract, Options);
                releaseRatio = abs(tradeVolume.Close/thisStockCurrentPosition);
                costOfDeal = tradeVolume.Close *dealprice * contractUnit;
                dealfee.Close = tradeVolume.Close*Options.CommissionPerContract;        
                unfrozeCash = releaseRatio*thisStockCurrentMargin;
                % 释放保证金
                Asset.CurrentMargins(idx_margin) = Asset.CurrentMargins(idx_margin) - unfrozeCash;      
            end
            AvaCash = AvaCash - costOfDeal - dealfee.Close + unfrozeCash;
        end
        
        %开仓
        if tradeVolume.Open~=0
            marginPerContract = 0;
            if tradeVolume.Open < 0     % 空仓开仓
                % 卖出合约，收取保证金
                Underlying = GetOptionUnderlyingStruct(DB, Data,Options);  
                underlyingPreClose = Underlying.PreClose(I);                     %合约标的的前收盘价
                lastSettle = GetOptionContractPreSettlePriceByType( Data,...        %合约的前结算价
                    I, Options.OptLastSettlementType);
                margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
                marginPerContract = margin*contractUnit;                    %每手期权的义务开仓保证金     
            end
            
            tradeVolume.Open = AdaptOpenVolumeToAvaCash(Data, I,tradeVolume.Open,...
                AvaCash,dealprice, contractUnit,marginPerContract, Options);
            
            costOfDeal = tradeVolume.Open *dealprice * contractUnit;
            dealfee.Open = abs(tradeVolume.Open)*Options.CommissionPerContract;
            frozeCash = marginPerContract*abs(tradeVolume.Open);     
            % 如果开空仓则收取保证金
            if tradeVolume.Open < 0
                idx_margin = findPositionByName(Asset.OrderStock{I}(i),Asset.CurrentMarginStock);
                if sum(idx_margin) == 0 % 如果新开空仓
                    Asset.CurrentMarginStock  = [Asset.CurrentMarginStock Asset.OrderStock{I}(i)];
                    Asset.CurrentMargins = [Asset.CurrentMargins frozeCash];
                else% 已经存在空仓
                    Asset.CurrentMargins(idx_margin) = Asset.CurrentMargins(idx_margin) + frozeCash;
                end
            end
            AvaCash = AvaCash - costOfDeal - dealfee.Open - frozeCash;
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
            else
                Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
                Asset.CurrentPosition = [Asset.CurrentPosition realDealVol];
            end
        end
    end
end
%如果交易后导致部分合约空仓，在当前持仓中清除空仓的合约
idxClearEmpty = Asset.CurrentPosition == 0;
Asset.CurrentStock(idxClearEmpty) = [];
Asset.CurrentPosition(idxClearEmpty) = [];

idxClearEmptyMargin = Asset.CurrentMargins == 0;
Asset.CurrentMargins(idxClearEmptyMargin) = [];
Asset.CurrentMarginStock(idxClearEmptyMargin) = [];

%% 更新记录
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;

Asset.MarginStock{I} = Asset.CurrentMarginStock;
Asset.Margins{I} = Asset.CurrentMargins;

Asset.Cash(I) = AvaCash;
Asset.FrozenCash(I) = FrozenCash;    
end