function [ margin, rate1, rate2] = CalculatePutMargin(contractPrice, underlyingPrice,...
    Strike)
%认沽期权义务仓开仓保证金＝Min[合约前结算价+Max（12%×合约标的前收盘价-认沽期权
%虚值，7%×行权价格），行权价格] ×合约单位
margin = min( contractPrice+max(0.12*underlyingPrice- max(underlyingPrice-Strike,0),...
    0.07*Strike),...
    Strike);
rate1 = 0.12;
rate2 = 0.07;
end

