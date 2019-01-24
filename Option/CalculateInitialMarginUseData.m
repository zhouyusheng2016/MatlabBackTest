function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %��Լ���struct

underlyingPreSettle = GetUnderlyingPreSettlePriceByType(Underlying,...
    I, Options.LastSettlementType);                                         %��Լ���ǰ�����

preSettle = GetOptionContractPreSettlePriceByType( Data,...                 %��Լǰ�����
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

