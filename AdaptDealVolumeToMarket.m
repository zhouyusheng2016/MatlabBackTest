function dealvolume =  AdaptDealVolumeToMarket(I,Data,vol,Options)
if abs(vol) < Data.Volume(I)*Options.VolumeRatio % ���ܳ������ս���������
    dealvolume = vol;
else
    dealvolume = sign(vol) * Data.Volume(I)*Options.VolumeRatio;
    disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: ���������ܽ��������ƣ�' Data.Code '������' num2str(dealvolume) '��']);
end
end