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
    ordertype = '买入';
else
    ordertype = '卖出';
end
flag = 0;
Data=getfield(DB,code2structname(stock,'F'));
for k=0:Options.DelayDays % 交易失败则延迟交易
    if I+OrderDay+k <= DB.NK
        cond_(1,1) = ~isnan(Data.Open(I+OrderDay+k));
        cond_(1,2) = ~isnan(Data.High(I+OrderDay+k));
        cond_(1,3) = ~isnan(Data.Low(I+OrderDay+k));
        cond_(1,4) = ~isnan(Data.Close(I+OrderDay+k));
        cond(1) = sum(cond_)==4;                                            %今日数据存在
        cond(2) = -9.9<=Data.Pct_chg{I+OrderDay+k};                         %根据收盘价确定涨停存在问题 %跌停限制
        cond(3) = Data.Pct_chg{I+OrderDay+k}<=9.9;                          %根据收盘价确定跌停存在问题 %涨停限制
        %合约存续
        today = Data.Times(I+OrderDay+k);
        lasttrade_date = datenum(datetime(Data.Info{1}));
        cond(4) = today<=lasttrade_date;                                    %下单时间合约是否到期
        if cond(1) && cond(2) && cond(3) && cond(4)
            flag = 1;
            break;
        else
            if cond(1)==0
                reason = '交易数据不存在';
            end
            if cond(2)==0
                reason = '收盘跌停';
            end
            if cond(3)==0
                reason = '收盘涨停';
            end
            if cond(4) == 0
                reason = '超过期货合约最后交易日';
            end
            disp(['Bar' num2str(I) '@' DB.TimesStr(I+OrderDay,:) ' Message: ' stock reason '导致交易失败，尝试延迟' num2str(k+1) '天' ordertype]);
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