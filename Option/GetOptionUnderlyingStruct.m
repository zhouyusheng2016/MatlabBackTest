function [Underlying] = GetOptionUnderlyingStruct(OptDB, DB,Options)
% ������Ȩ��ĺ�Լ�ķ���
% ������Ʒ��Ȩ��50ETF��Ȩ�����ݽṹ��ͬ����Ҫ��ͬ�ĵ��ñ�ķ���
% OptDB     -- ������Ȩ��struct
% DB        -- ����Ȩ��Լ������strct
% Options   -- ������Ȩ������Ȩ�����ֶ�struct

switch Options.OptionType
    case '50ETFOption'
        Underlying = OptDB.Underlying;                                      
    case 'CommodityOption'
        Underlying =  GetCommodityOptionUnderlyingStruct(OptDB, DB);
    otherwise
        error('Option Type error')
end
end