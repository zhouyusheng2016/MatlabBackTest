function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
underlyingPreClose = DB.Underlying.PreClose(I);                             %合约标的前收盘价
lastSettle = GetOptionContractPreSettlePriceByType( Data,...                %合约的前结算价
    I, Options.OptLastSettlementType);
contractInfo = GetOptionContractInfo(Data);
margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
end

