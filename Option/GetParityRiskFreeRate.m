function [ rf ] = GetParityRiskFreeRate(CallPrice, PutPrice, UnderlyingPrice, Strike, TimeUntilExpiration, varargin)
% ��put call parity ���������Ȩ��������
% varargin{1} -- ���㷽ʽ
% varargin{2} -- ������Լ�ı�֤��

%ֱ�Ӽ���
if isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike)/(PutPrice+UnderlyingPrice-CallPrice));
    return
end

% Ĭ�ϼ���������call�ɻ�õ�rate
if strcmp(varargin{1},'Margin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((Strike+varargin{2})/(PutPrice+UnderlyingPrice-CallPrice+varargin{2}));
    return
end
% ����������put�ɻ�õ�rate
if strcmp(varargin{1},'sellPutMargin')&&~isempty(varargin)
    rf = (1/TimeUntilExpiration)*log((-Strike+varargin{2})/...
        (-PutPrice-UnderlyingPrice+CallPrice+varargin{2}));
    return
end

end

