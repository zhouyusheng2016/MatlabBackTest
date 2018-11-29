function Asset = CollectOutStandings(Asset,DB)
%% 游标
I = DB.CurrentK;
%% 前日账户资金状态
if I == 1
   PreCash = Asset.InitCash; 
   PreCashTrans = Asset.InitCash;
else
   PreCash = Asset.Cash(I-1);
   PreCashTrans = Asset.CashTransAble(I-1);
end
%% 现金状态改变
Asset.Cash(I) =PreCash + Asset.PrincipleReceivable(I)+ Asset.InterestReceivable(I);
Asset.CashTransAble(I) =PreCashTrans + Asset.CashTransReceivables(I);
%改变在外债务
Asset.OutStandingPrinciple = Asset.OutStandingPrinciple - Asset.PrincipleReceivable(I);
end