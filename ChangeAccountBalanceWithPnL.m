function [ Ava, Frozen ] = ChangeAccountBalanceWithPnL(pnl, avaCash, frozeCash)

% ����ӯ���������ñ�֤�������ñ�֤��
if pnl+avaCash >= 0                                                         % ���ȱ䶯���ñ�֤��
   Ava =  pnl+avaCash;
   Frozen = frozeCash;
else                                                                        % �����ñ�֤������ʱ��ʹ�����ñ�֤��
   Ava = 0;
   Frozen = frozeCash+avaCash+pnl;
end
end

