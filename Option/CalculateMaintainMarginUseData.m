function [ margin ] = CalculateMaintainMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %合约标的struct

underlyingSettle = GetUnderlyingSettlePriceByType(Underlying,...
    I, Options.SettlementType);                                      %合约标的前结算价

settle = GetOptionContractSettlePriceByType( Data,...                 %合约前结算价
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