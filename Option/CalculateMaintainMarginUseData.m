function [ margin ] = CalculateMaintainMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %��Լ���struct

underlyingSettle = GetOptionUnderlyingSettlePriceByType(Underlying,...
    I, Options.SettlementType);                                      %��Լ���ǰ�����

settle = GetOptionContractSettlePriceByType( Data,...                 %��Լǰ�����
    I, Options.SettlementType);

contractInfo = GetOptionContractInfo(Data);

margin = CalculateMargin(settle,underlyingSettle,Data.Strike(I), contractInfo);
end