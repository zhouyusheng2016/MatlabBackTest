function [Volume] = GetDealVolType(currentPos, lastPos, tradeVol)
% 确定今日仓位变化类型以及数量
% 输入现仓、昨仓、今交易量
% 今开仓、今平仓 struct
if sign(lastPos)*sign(tradeVol) == 1 %今仓昨仓方向相同
    openVol = tradeVol;
    closeVol = 0;
elseif sign(lastPos)*sign(tradeVol) == -1 % 今仓跟昨仓方向相反
    if sign(lastPos) == sign(currentPos) % 昨仓跟最终仓位同号
        openVol = 0;
        closeVol = tradeVol;
    else % 今仓跟最终仓位同号
        closeVol = -lastPos;
        openVol = tradeVol - closeVol;
    end
else % 今仓或昨仓为0
    openVol = tradeVol;
    closeVol = 0;
end

Volume.open = openVol;
Volume.close = closeVol;
    
end

