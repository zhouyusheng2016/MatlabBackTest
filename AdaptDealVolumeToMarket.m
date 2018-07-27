function dealvolume =  AdaptDealVolumeToMarket(I,Data,vol,Options)
if abs(vol) < Data.Volume(I)*Options.VolumeRatio % 不能超过当日交易量限制
    dealvolume = vol;
else
    dealvolume = sign(vol) * Data.Volume(I)*Options.VolumeRatio;
    disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 超过当日总交易量限制，' Data.Code '仅交易' num2str(dealvolume) '手']);
end
end