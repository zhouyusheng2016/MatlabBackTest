function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration, varargin)
% 由put call parity 计算出的期权隐含利率
% varargin{1} -- 计算方式
% varargin{2} -- 卖出合约的保证金

%直接计算
if isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike)/(PutPrice+UnderlyingPrice-CallPrice));
    return
end

% 默认计算以卖出call可获得的rate
if strcmp(varargin{1},'Margin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike+varargin{2})/(PutPrice+UnderlyingPrice-CallPrice+varargin{2}));
    return
end
% 计算以卖出put可获得的rate
if strcmp(varargin{1},'sellPutMargin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((-Strike+varargin{2})/...
        (-PutPrice-UnderlyingPrice+CallPrice+varargin{2}));
    return
end

end

