function [ margin ] = CalculateMaintainMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %合约标的struct

underlyingSettle = GetOptionUnderlyingSettlePriceByType(Underlying,...
    I, Options.SettlementType);                                      %合约标的前结算价

settle = GetOptionContractSettlePriceByType( Data,...                 %合约前结算价
    I, Options.SettlementType);

contractInfo = GetOptionContractInfo(Data);

margin = CalculateMargin(settle,underlyingSettle,Data.Strike(I), contractInfo);
end