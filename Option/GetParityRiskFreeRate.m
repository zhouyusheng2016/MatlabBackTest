function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration, varargin)
% 由put call parity 计算出的期权隐含利率

%直接计算
if isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike)/(PutPrice+UnderlyingPrice-CallPrice));
    return
end

% 考虑
if strcmp(varargin{1},'Margin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike+varargin{2})/(PutPrice+UnderlyingPrice-CallPrice+varargin{2}));
    return
end

end

