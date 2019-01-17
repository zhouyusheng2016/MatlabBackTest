function [ margin ] = CalculateMargin(price,underlying,Strike,contractInfo,varargin)
% ���㱣֤��Ľӿں���
% CalculateMargin(price,underlying,Strike,contractInfo)Ĭ�ϼ���50ETF��Ȩ�ı�֤��
% varargin - 50ETFOption ����50ETF��Ȩ��֤��
% varargin - CommodityOption ������Ʒ��Ȩͭ���ɰ��ǵı�֤��
if nargin < 4
    error(message('CalculateMargin:TooFewInputs')) 
end
%% 50ETF option�ı�֤����㷽ʽ
if nargin == 4 || strcmp(varargin{1}, '50ETFOption')
    margin = Calculate50ETFOptionMargin(price,underlying,Strike,contractInfo);
    return
end

%% ����ͭ���� option�ı�֤����㷽ʽ
if nargin == 5 && strcmp(varargin{1}, 'CommodityOption')
    margin = CalculateCommodityOptionMargin(price,underlying,Strike,contractInfo);
    return
end

error('No Margin Calculated')
end

