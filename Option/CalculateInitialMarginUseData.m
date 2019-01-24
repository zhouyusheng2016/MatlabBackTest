function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %合约标的struct

underlyingPreSettle = GetUnderlyingPreSettlePriceByType(Underlying,...
    I, Options.LastSettlementType);                                         %合约标的前结算价

preSettle = GetOptionContractPreSettlePriceByType( Data,...                 %合约前结算价
    I, Options.LastSettlementType);

contractInfo = GetOptionContractInfo(Data);
if strcmp(Options.OptionType, 'CommodityOption')
    margin = CalculateMargin(preSettle,underlyingPreSettle,Data.Strike(I), contractInfo,Options.OptionType, underlyingPreSettle*Underlying.Margin(I));
    return
end
if strcmp(Options.OptionType, '50ETFOption')
    margin = CalculateMargin(preSettle,underlyingPreSettle,Data.Strike(I), contractInfo);
    return
end

error('No InitialMargin Calculated')

end

