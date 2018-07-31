function [ out_vol ] = AdaptCloseShortVolumeToAvaCash(Data, I, vol, avaCash,dealprice, contractUnit,...
    marginReleaseByOneContract,Options)

% �ͷű�֤������������Ϊ��
if vol < 0
   error('AdaptCloseShortVolumeToAvaCash.m: input error vol < 0') 
end
% �����ֽ����Ϊ��
if avaCash < 0 
   error('Negative Avaliable Cash') 
end

cost = vol*dealprice*contractUnit;
fee = vol*Options.CommissionPerContract;
marginRelease = vol*marginReleaseByOneContract;

if avaCash - cost - fee + marginRelease < 0
    if Options.PartialDeal == 1
        % ����һ����Ȩ�Ľ��
        oneUnitOfTrade = dealprice*contractUnit;
        % ����һ����Ȩƽ�ֵ��ʽ�䶯
        oneUnitCost = oneUnitOfTrade - marginRelease + Options.CommissionPerContract;
        % ����������
        out_vol = floor(avaCash / oneUnitCost);
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Data.Code '����ƽ��' num2str(out_vol) '�ɣ����ײ��ֳɽ�']);
    else
        out_vol = 0;
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Data.Code '����ƽ��ʧ��']);
    end
else
    out_vol = vol;
end

end

