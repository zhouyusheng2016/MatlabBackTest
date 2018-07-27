function [ m ] = CalculateMaintainMargin( CurrentPosition,contractInfo,settlePrice  )
% 计算维持保证金
m = abs(CurrentPosition)*contractInfo.multiplier*contractInfo.mmargin*settlePrice;
end

