function [ Ava, Frozen ] = ChangeAccountBalanceWithPnL(pnl, avaCash, frozeCash)

% 根据盈亏调整可用保证金与已用保证金
if pnl+avaCash >= 0                                                         % 优先变动可用保证金
   Ava =  pnl+avaCash;
   Frozen = frozeCash;
else                                                                        % 当可用保证金余额不足时，使用已用保证金
   Ava = 0;
   Frozen = frozeCash+avaCash+pnl;
end
end

