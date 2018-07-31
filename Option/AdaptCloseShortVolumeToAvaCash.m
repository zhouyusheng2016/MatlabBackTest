function [ out_vol ] = AdaptCloseShortVolumeToAvaCash(Data, I, vol, avaCash,dealprice, contractUnit,...
    marginReleaseByOneContract,Options)

% 释放保证金买入量必须为正
if vol < 0
   error('AdaptCloseShortVolumeToAvaCash.m: input error vol < 0') 
end
% 可用现金必须为正
if avaCash < 0 
   error('Negative Avaliable Cash') 
end

cost = vol*dealprice*contractUnit;
fee = vol*Options.CommissionPerContract;
marginRelease = vol*marginReleaseByOneContract;

if avaCash - cost - fee + marginRelease < 0
    if Options.PartialDeal == 1
        % 买入一张期权的金额
        oneUnitOfTrade = dealprice*contractUnit;
        % 买入一张期权平仓的资金变动
        oneUnitCost = oneUnitOfTrade - marginRelease + Options.CommissionPerContract;
        % 买入整数张
        out_vol = floor(avaCash / oneUnitCost);
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Data.Code '买入平仓' num2str(out_vol) '股，交易部分成交']);
    else
        out_vol = 0;
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Data.Code '买入平仓失败']);
    end
else
    out_vol = vol;
end

end

