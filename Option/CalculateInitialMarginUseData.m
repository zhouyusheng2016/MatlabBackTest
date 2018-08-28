function [ margin ] = CalculateInitialMarginUseData(DB, Data,I,Options)
underlyingPreClose = DB.Underlying.PreClose(I);                             %��Լ���ǰ���̼�
lastSettle = GetOptionContractPreSettlePriceByType( Data,...                %��Լ��ǰ�����
    I, Options.OptLastSettlementType);
contractInfo = GetOptionContractInfo(Data);
margin = CalculateMargin(lastSettle,underlyingPreClose,Data.Strike(I), contractInfo);
end

