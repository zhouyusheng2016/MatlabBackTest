function [ margin ] = CalculateMargin(price,underlying,Strike,contractInfo,varargin)
% 计算保证金的接口函数
% CalculateMargin(price,underlying,Strike,contractInfo)默认计算50ETF期权的保证金
% varargin - 50ETFOption 计算50ETF期权保证金
% varargin - CommodityOption 计算商品期权铜豆粕白糖的保证金
if nargin < 4
    error(message('CalculateMargin:TooFewInputs')) 
end
%% 50ETF option的保证金计算方式
if nargin == 4 || strcmp(varargin{1}, '50ETFOption')
    margin = Calculate50ETFOptionMargin(price,underlying,Strike,contractInfo);
    return
end

%% 白糖铜豆粕 option的保证金计算方式
if nargin == 5 && strcmp(varargin{1}, 'CommodityOption')
    margin = CalculateCommodityOptionMargin(price,underlying,Strike,contractInfo);
    return
end

error('No Margin Calculated')
end

