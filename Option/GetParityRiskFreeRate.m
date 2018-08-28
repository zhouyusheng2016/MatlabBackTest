function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration)
% ��put call parity ���������Ȩ��������
rf = (1/TimeUntilExpiration)*log(Strike/(PutPrice+UnderlyingPrice-CallPrice));

end

