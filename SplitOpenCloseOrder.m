function [ Volume ] = SplitOpenCloseOrder( CurrentPos, TradeVol)
%根据当前仓位区分开仓类型

% 交易后仓位方向
afterPos = CurrentPos + TradeVol;

Volume = GetDealVolType(afterPos, CurrentPos, TradeVol);

end

