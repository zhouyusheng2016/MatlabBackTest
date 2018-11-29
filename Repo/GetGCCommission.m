function commission = GetGCCommission(principle, period)
% 计算commission
%每10万元费率
if period <= 4
    commission_rate = period;
elseif period == 7
    commission_rate = 5;
elseif period == 14
    commission_rate = 10;
elseif period == 28
    commission_rate = 20;
elseif period == 91
    commission_rate = 30;
elseif period == 182
    commission_rate = 30;
else
    error('CommisionErrorOnNoneGCREPo')
end
num = ceil(principle/1e5);
%手续费占款
commission = num * commission_rate;
end