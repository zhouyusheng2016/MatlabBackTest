function [ rf ] = GetParityRiskFreeRateByDataStruct( CallData,PutData,UnderlyingData,I,field)
%检查类型
if CallData.Info{1} ~= 'call'|| PutData.Info{1}~='put'
    error('wrong call/put input')
end
%检查strike
if CallData.Strike(I) ~= PutData.Strike(I)
    error('pair with different strike')
end
%检查到期日
if CallData.Info{2} ~= PutData.Info{2}
    error('expiriation not match')
end
callPriceList = getfield(CallData,field);
putPriceList = getfield(PutData,field);
underlyingPriceList = getfield(UnderlyingData,field);

callPrice = callPriceList(I);
putPirce = putPriceList(I);
underlyingPirce= underlyingPriceList(I);

rf = GetParityRiskFreeRate(callPrice, putPirce, underlyingPirce, CallData.Strike(I), CallData.TimeUntilExpiration(I));

end

