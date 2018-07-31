function [ vol_out ] = AdaptOpenVolumeToAvaCash(Data, I,vol,...
                AvaCash,dealprice, contractUnit,marginPerContract, Options)

% 可用现金必须为正
if AvaCash < 0 
   error('Negative Avaliable Cash') 
end       
% 期权权力仓保证金为0
if vol > 0
    marginPerContract = 0;
end
%交易方向
if vol > 0 
    dirc = '买入';
elseif vol < 0
    dirc = '卖出';
end
feePerContract = Options.CommissionPerContract;
if AvaCash - vol*contractUnit*dealprice + vol*marginPerContract - abs(vol)*feePerContract < 0 
    if Options.PartialDeal == 1
       unit = sign(vol);
       pricePerContract = contractUnit*dealprice;
       
       costPerContract = unit*pricePerContract - unit*marginPerContract + abs(unit)*feePerContract;
       
       vol_out = floor(AvaCash / costPerContract);
       disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Data.Code '开仓' dirc  num2str(out_vol) '股，交易部分成交']);
    else
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Data.Code '开仓' dirc '失败']);
        vol_out = 0;
    end
else
    vol_out = vol;
end

end

