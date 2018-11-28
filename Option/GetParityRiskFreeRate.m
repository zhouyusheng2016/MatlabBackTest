function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration, varargin)
% ��put call parity ���������Ȩ��������

%ֱ�Ӽ���
if isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike)/(PutPrice+UnderlyingPrice-CallPrice));
    return
end

% ����
if strcmp(varargin{1},'Margin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike+varargin{2})/(PutPrice+UnderlyingPrice-CallPrice+varargin{2}));
    return
end

end

