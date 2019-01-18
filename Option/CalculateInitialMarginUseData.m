function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %��Լ���struct

underlyingPreSettle = GetUnderlyingPreSettlePriceByType(Underlying,...
    I, Options.LastSettlementType);                                      %��Լ���ǰ�����

preSettle = GetOptionContractPreSettlePriceByType( Data,...                 %��Լǰ�����
    I, Options.LastSettlementType);

contractInfo = GetOptionContractInfo(Data);

margin = CalculateMargin(preSettle,underlyingPreSettle,Data.Strike(I), contractInfo);
end

