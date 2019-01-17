function [margin] = Calculate50ETFCallMargin(contractPrice, underlyingPrice,...
    Strike)
%�Ϲ���Ȩ����ֿ��ֱ�֤��[��Լǰ�����+Max��12%����Լ���ǰ���̼�-�Ϲ���Ȩ��ֵ
%7%����Լ���ǰ���̼ۣ�]����Լ��λ
%�谴�ս�������׼�޸Ĳ���
margin = contractPrice + ...
    max(0.12*underlyingPrice-max(Strike-underlyingPrice,0), 0.07*underlyingPrice);    
end

