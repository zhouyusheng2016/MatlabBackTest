function [ margin ] = CalculateMaintainMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %��Լ���struct

underlyingSettle = GetUnderlyingSettlePriceByType(Underlying,...
    I, Options.SettlementType);                                      %��Լ���ǰ�����

settle = GetOptionContractSettlePriceByType( Data,...                 %��Լǰ�����
    I, Options.SettlementType);

contractInfo = GetOptionContractInfo(Data);
if strcmp(Options.OptionType, 'CommodityOption')
    margin = CalculateMargin(settle,underlyingSettle,Data.Strike(I), contractInfo,Options.OptionType, underlyingSettle*Underlying.Margin(I));
    return
end
if strcmp(Options.OptionType, '50ETFOption')
    margin = CalculateMargin(settle,underlyingSettle,Data.Strike(I), contractInfo);
    return
end
error('No MaintainMargin Calculated')
end