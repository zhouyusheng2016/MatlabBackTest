function [ margin,rate1,rate2 ] = CalculateCallMargin(contractPrice, underlyingPrice,...
    Strike)
%�Ϲ���Ȩ����ֿ��ֱ�֤��[��Լǰ�����+Max��12%����Լ���ǰ���̼�-�Ϲ���Ȩ��ֵ
%7%����Լ���ǰ���̼ۣ�]����Լ��λ
%�谴�ս�������׼�޸Ĳ���
rate1 = 0.12;
rate2 = 0.07;
margin = contractPrice + ...
    max(0.12*underlyingPrice-max(Strike-underlyingPrice,0), 0.07*underlyingPrice);    
end

