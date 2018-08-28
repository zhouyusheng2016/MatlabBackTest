function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration)
% 由put call parity 计算出的期权隐含利率
rf = (1/TimeUntilExpiration)*log(Strike/(PutPrice+UnderlyingPrice-CallPrice));

end

