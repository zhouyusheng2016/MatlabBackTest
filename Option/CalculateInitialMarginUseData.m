function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
Underlying = GetOptionUnderlyingStruct(DB, Data,Options);                   %��Լ���ǰ���̼�
underlyingPreClose = Underlying.PreClose(I); 
lastSettle = GetOptionContractPreSettlePriceByType( Data,...                %��Լ��ǰ�����
    I, Options.OptLastSettlementType);
contractInfo = GetOptionContractInfo(Data);
margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
end

