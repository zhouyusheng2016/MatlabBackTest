function volume = AdaptDealVolumeWithAvaCash(Data,I,AvaCash,vol,dealprice,contractInfo, Options)

if (AvaCash <0)                                                             % ��֤����Ϊ����
    volume = 0;
    return;
end
nomialValuePerContract = dealprice*contractInfo.multiplier;
initialMarginValuePerContract = nomialValuePerContract*contractInfo.imargin;
volume = vol;
if AvaCash - abs(vol)*initialMarginValuePerContract...
        - max(Options.MinCommission,abs(vol)*nomialValuePerContract*Options.Commission) < 0
    if Options.PartialDeal == 1 % �����ʽ�������ʱ���ֳɽ�
        volume = floor(AvaCash/nomialValuePerContract/(Options.Commission+contractInfo.imargin));
        if  volume*nomialValuePerContract*Options.Commission < Options.MinCommission
            volume = floor((AvaCash - Options.MinCommission)/initialMarginValuePerContract);
        end
        if volume > 0
            disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Data.Code '����' num2str(volume) '�ɣ����ײ��ֳɽ�']);
        else
            disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '������һ�֣�' Data.Code  '����ʧ��']);
        end
    else
        volume = 0;
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '������һ�֣�' Data.Code  '����ʧ��']);
    end
end

end