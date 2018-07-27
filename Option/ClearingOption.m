function Asset = ClearingOption(Asset,DB,Options)
I = DB.CurrentK;
if I == 1
    AvaCash = Asset.InitCash;
    PreStock = [];
    PrePosition = [];
else
    AvaCash = Asset.Cash(I-1);
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
end
Asset.CurrentStock = PreStock;
Asset.CurrentPosition = PrePosition;
for i = 1:length(Asset.OrderPrice{I})
    dealvolume = [];
    if Asset.OrderVolume{I}(i) > 0
        dealprice = Asset.OrderPrice{I}(i) * (1+Options.Slippage);
    else
        dealprice = Asset.OrderPrice{I}(i) * (1-Options.Slippage);
    end
    Data=getfield(DB,[Asset.OrderStock{I}{i}(8:9) Asset.OrderStock{I}{i}(1:6)]);
    if abs(Asset.OrderVolume{I}(i)) < Data.Volume(I)*Options.VolumeRatio % ���ܳ������ս���������
        dealvolume = Asset.OrderVolume{I}(i);
    else
        dealvolume = sign(Asset.OrderVolume{I}(i)) * Data.Volume(I)*Options.VolumeRatio;
        disp(['Bar' num2str(I) '@' Asset.TimesStr(I,:) ' Message: ���������ܽ��������ƣ�' Asset.OrderStock{I}{i} '������' num2str(dealvolume) '��']);
    end
    if dealvolume > 0
        dealvolume = floor(dealvolume/100)*100; % ������������
    end
    if dealvolume > 0 && AvaCash - dealvolume*dealprice - max(Options.MinCommission,dealvolume*dealprice*Options.Commission) < 0
        if Options.PartialDeal == 1 % �����ʽ�������ʱ���ֳɽ�
            dealvolume = floor(AvaCash/dealprice/(1+Options.Commission)/100)*100;
            if dealvolume*dealprice*Options.Commission < Options.MinCommission
                dealvolume = floor((AvaCash - Options.MinCommission)/dealprice/100)*100;
            end
            if dealvolume > 0
                disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '��' Asset.OrderStock{I}{i} '����' num2str(dealvolume) '�ɣ����ײ��ֳɽ�']);
            else
                disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '������һ�֣�' Asset.OrderStock{I}{i} '����ʧ��']);
            end
        else
            dealvolume = 0;
            disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: �����ʽ���Ϊ' num2str(AvaCash) '������һ�֣�' Asset.OrderStock{I}{i} '����ʧ��']);
        end
    end
    
    if dealvolume ~= 0
        Asset.DealStock{I} = [Asset.DealStock{I} Asset.OrderStock{I}(i)];
        Asset.DealVolume{I} = [Asset.DealVolume{I} dealvolume];
        Asset.DealPrice{I} = [Asset.DealPrice{I} dealprice];
        if dealvolume > 0
            dealfee = max(Options.MinCommission,dealvolume*dealprice*Options.Commission);
        else
            dealfee = max(Options.MinCommission,-dealvolume*dealprice*Options.Commission) + (-dealvolume)*dealprice*Options.StampTax;
        end
        Asset.DealFee{I} = [Asset.DealFee{I} dealfee];
        AvaCash = AvaCash - dealvolume*dealprice - dealfee;
        
        ind = strcmp(Asset.OrderStock{I}{i},Asset.CurrentStock);
        if sum(ind) > 1
            disp('!!! ��ǰ�ֲִ��� !!!');
        end
        if sum(ind) > 0
            if ( sum(Asset.CurrentPosition(ind)) + dealvolume > 0 ) || ( sum(Asset.CurrentPosition(ind)) + dealvolume < 0 && Options.Short == 1 )
                Asset.CurrentPosition(ind) = sum(Asset.CurrentPosition(ind))+dealvolume;
            end
        else
            if ( dealvolume > 0 ) || ( dealvolume < 0 && Options.Short == 1 )
                Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
                Asset.CurrentPosition = [Asset.CurrentPosition dealvolume];
            end
        end
    end
end
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;
Asset.Cash(I) = AvaCash;