function [ OrderOut ] = AdaptOrderOrder( OrderIn,CurrentStock, CurrentPosition )
% 撮合顺序导致资金为负
OrderOut = [];
ExitLong = [];%平多
ExitShort = [];%平空
EnterLong = [];%多开
EnterShort = [];%空开
% 调整落单顺序
len=length(OrderIn);
orderStock = arrayfun(@(i)OrderIn{i}.Stock, 1:len,'UniformOutput',0);
orderVol = arrayfun(@(i)OrderIn{i}.Volume, 1:len);

for i = 1:length(OrderIn)                                                   %按照order的顺序查找
    idx_orderInCurrent = strcmp(orderStock(i),CurrentStock);
    flag_notInCurrentPos = sum(idx_orderInCurrent) == 0;
%% 重叠部分
    if ~flag_notInCurrentPos % 目前持仓下单合约
        SplitedOrderVol = SplitOpenCloseOrder( CurrentPosition(idx_orderInCurrent),orderVol(i));
        % 平仓
        if SplitedOrderVol.close~=0
            thisOrder = OrderIn{i};%本单的信息
            thisOrder.Volume = SplitedOrderVol.close;%本单平仓量
            if SplitedOrderVol.close < 0% 平多
                ExitLong = [ExitLong {thisOrder}];
            else %>0平空
                ExitShort = [ExitShort {thisOrder}];
            end
        end
        %开仓
        if SplitedOrderVol.open~=0
            thisOrder = OrderIn{i};%本单的信息
            thisOrder.Volume = SplitedOrderVol.open;%本单开仓量
            if SplitedOrderVol.open > 0 %多开
                EnterLong = [EnterLong {thisOrder}];
            else % < 0  空开
                EnterShort = [EnterShort {thisOrder}];
            end
        end
    else % 此单为不与现仓位重叠部分
%% 非重叠部分
        if OrderIn{i}.Volume~=0
            if OrderIn{i}.Volume > 0
                EnterLong = [EnterLong OrderIn(i)];
            else
                EnterShort = [EnterShort OrderIn(i)];
            end
        end
    end
end
OrderOut = [ExitLong, ExitShort, EnterLong, EnterShort];
end

