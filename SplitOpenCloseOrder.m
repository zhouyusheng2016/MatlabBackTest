function [ Volume ] = SplitOpenCloseOrder( CurrentPos, TradeVol)
%���ݵ�ǰ��λ���ֿ�������

% ���׺��λ����
afterPos = CurrentPos + TradeVol;

Volume = GetDealVolType(afterPos, CurrentPos, TradeVol);

end

