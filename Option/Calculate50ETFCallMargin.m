function [margin] = Calculate50ETFCallMargin(contractPrice, underlyingPrice,...
    Strike)
%认购期权义务仓开仓保证金＝[合约前结算价+Max（12%×合约标的前收盘价-认购期权虚值
%7%×合约标的前收盘价）]×合约单位
%需按照交易所标准修改参数
margin = contractPrice + ...
    max(0.12*underlyingPrice-max(Strike-underlyingPrice,0), 0.07*underlyingPrice);    
end

