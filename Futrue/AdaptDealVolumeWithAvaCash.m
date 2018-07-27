function volume = AdaptDealVolumeWithAvaCash(Data,I,AvaCash,vol,dealprice,contractInfo, Options)

if (AvaCash <0)                                                             % 保证金不能为负数
    volume = 0;
    return;
end
nomialValuePerContract = dealprice*contractInfo.multiplier;
initialMarginValuePerContract = nomialValuePerContract*contractInfo.imargin;
volume = vol;
if AvaCash - abs(vol)*initialMarginValuePerContract...
        - max(Options.MinCommission,abs(vol)*nomialValuePerContract*Options.Commission) < 0
    if Options.PartialDeal == 1 % 买入资金量不足时部分成交
        volume = floor(AvaCash/nomialValuePerContract/(Options.Commission+contractInfo.imargin));
        if  volume*nomialValuePerContract*Options.Commission < Options.MinCommission
            volume = floor((AvaCash - Options.MinCommission)/initialMarginValuePerContract);
        end
        if volume > 0
            disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Data.Code '买入' num2str(volume) '股，交易部分成交']);
        else
            disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，不足一手，' Data.Code  '买入失败']);
        end
    else
        volume = 0;
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，不足一手，' Data.Code  '买入失败']);
    end
end

end