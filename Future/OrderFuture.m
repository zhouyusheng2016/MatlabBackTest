function Asset = OrderFuture(DB,Asset,stock,volume,price,type,Options)
I = DB.CurrentK;
if strcmp(type,'Today')==1
    OrderDay = 0;
elseif strcmp(type, 'Next')==1
    if I+1<=DB.NK
        OrderDay = 1;
    else
        return;
    end
end
if volume > 0
    ordertype = '����';
else
    ordertype = '����';
end
flag = 0;
Data=getfield(DB,code2structname(stock,'F'));
for k=0:Options.DelayDays % ����ʧ�����ӳٽ���
    if I+OrderDay+k <= DB.NK
        cond_(1,1) = ~isnan(Data.Open(I+OrderDay+k));
        cond_(1,2) = ~isnan(Data.High(I+OrderDay+k));
        cond_(1,3) = ~isnan(Data.Low(I+OrderDay+k));
        cond_(1,4) = ~isnan(Data.Close(I+OrderDay+k));
        cond(1) = sum(cond_)==4;                                            %�������ݴ���
        cond(2) = -9.9<=Data.Pct_chg{I+OrderDay+k};                         %�������̼�ȷ����ͣ�������� %��ͣ����
        cond(3) = Data.Pct_chg{I+OrderDay+k}<=9.9;                          %�������̼�ȷ����ͣ�������� %��ͣ����
        %��Լ����
        today = Data.Times(I+OrderDay+k);
        lasttrade_date = datenum(datetime(Data.Info{1}));
        cond(4) = today<=lasttrade_date;                                    %�µ�ʱ���Լ�Ƿ���
        if cond(1) && cond(2) && cond(3) && cond(4)
            flag = 1;
            break;
        else
            if cond(1)==0
                reason = '�������ݲ�����';
            end
            if cond(2)==0
                reason = '���̵�ͣ';
            end
            if cond(3)==0
                reason = '������ͣ';
            end
            if cond(4) == 0
                reason = '�����ڻ���Լ�������';
            end
            disp(['Bar' num2str(I) '@' DB.TimesStr(I+OrderDay,:) ' Message: ' stock reason '���½���ʧ�ܣ������ӳ�' num2str(k+1) '��' ordertype]);
        end
    else
        return
    end
end
if flag == 1
    OrderDay = OrderDay + k;
    if I+OrderDay <= DB.NK
        Asset.OrderStock{I+OrderDay} = [Asset.OrderStock{I+OrderDay},{stock}];
        Asset.OrderPrice{I+OrderDay} = [Asset.OrderPrice{I+OrderDay} price];
        Asset.OrderVolume{I+OrderDay} = [Asset.OrderVolume{I+OrderDay} volume];
    end
end