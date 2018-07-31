function [ vol_out ] = AdaptOpenVolumeToAvaCash(Data, I,vol,...
                AvaCash,dealprice, contractUnit,marginPerContract, Options)

% �����ֽ����Ϊ��
if AvaCash < 0 
   error('Negative Avaliable Cash') 
end       
% ��ȨȨ���ֱ�֤��Ϊ0
if vol > 0
    marginPerContract = 0;
end
%���׷���
if vol > 0 
    dirc = '����';
elseif vol < 0
    dirc = '����';
end
feePerContract = Options.CommissionPerContract;
if AvaCash - vol*contractUnit*dealprice + vol*marginPerContract - abs(vol)*feePerContract < 0 
    if Options.PartialDeal == 1
       unit = sign(vol);
       pricePerContract = contractUnit*dealprice;
       
       costPerContract = unit*pricePerContract - unit*marginPerContract + abs(unit)*feePerContract;
       
       vol_out = floor(AvaCash / costPerContract);
       disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Data.Code '����' dirc  num2str(out_vol) '�ɣ����ײ��ֳɽ�']);
    else
        disp(['Bar' num2str(I) '@' Data.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Data.Code '����' dirc 'ʧ��']);
        vol_out = 0;
    end
else
    vol_out = vol;
end

end

