function [ m ] = CalculateMaintainMargin( CurrentPosition,contractInfo,settlePrice  )
% ����ά�ֱ�֤��
m = abs(CurrentPosition)*contractInfo.multiplier*contractInfo.mmargin*settlePrice;
end

