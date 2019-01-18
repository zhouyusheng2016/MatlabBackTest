function [Underlying] = GetOptionUnderlyingStruct(OptDB, DB,Options)
% 查找期权标的合约的方法
% 由于商品期权与50ETF期权的数据结构不同，需要不同的调用标的方法
% OptDB     -- 所有期权的struct
% DB        -- 本期权合约的数据strct
% Options   -- 包含期权所属期权类别的字段struct

switch Options.OptionType
    case '50ETFOption'
        Underlying = OptDB.Underlying;                                      
    case 'CommodityOption'
        Underlying =  GetCommodityOptionUnderlyingStruct(OptDB, DB);
    otherwise
        error('Option Type error')
end
end