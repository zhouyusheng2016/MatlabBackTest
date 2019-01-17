function [ Data ] = FindOptionContractByExpMoney( OptDB, I,varargin)
% 检查 varargin
flag_var1IsChar = ischar(varargin{1});

flag_var1IsCell = iscell(varargin{1});
% parser name-value
p = inputParser;
defaultVal = '50ETFOption';
addParameter(p,'OptionType',defaultVal,@ischar);
if flag_var1IsChar
    parse(p,varargin{1:2});
elseif flag_var1IsCell
    parse(p);
else
    error('input error')
end
% 采取适用函数
switch p.Results.OptionType
    case '50ETFOption'
        if flag_var1IsCell
            [ Data ] = Find50ETFOptionContractByExpMoney( OptDB, I,varargin{:});
        else
            [ Data ] = Find50ETFOptionContractByExpMoney( OptDB, I,varargin{3:end});         
        end
    case 'CommodityOption'
        [ Data ] = FindCommodityOptionContractByExpMoney( OptDB, I,varargin{3:end});
    otherwise
        error('Unexpected Option category')
end
end