function Asset = CollectOutStandings(Asset,DB)
%% �α�
I = DB.CurrentK;
%% ǰ���˻��ʽ�״̬
if I == 1
   PreCash = Asset.InitCash; 
   PreCashTrans = Asset.InitCash;
else
   PreCash = Asset.Cash(I-1);
   PreCashTrans = Asset.CashTransAble(I-1);
end
%% �ֽ�״̬�ı�
Asset.Cash(I) =PreCash + Asset.PrincipleReceivable(I)+ Asset.InterestReceivable(I);
Asset.CashTransAble(I) =PreCashTrans + Asset.CashTransReceivables(I);
%�ı�����ծ��
Asset.OutStandingPrinciple = Asset.OutStandingPrinciple - Asset.PrincipleReceivable(I);
end