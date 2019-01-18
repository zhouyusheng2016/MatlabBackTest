function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %合约标的前收盘价
underlyingPreClose = Underlying.PreClose(I); 
lastSettle = GetOptionContractPreSettlePriceByType( Data,...                %合约的前结算价
    I, Options.OptLastSettlementType);
contractInfo = GetOptionContractInfo(Data);
margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
end

