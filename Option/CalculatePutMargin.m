function [ margin, rate1, rate2] = CalculatePutMargin(contractPrice, underlyingPrice,...
    Strike)
%�Ϲ���Ȩ����ֿ��ֱ�֤��Min[��Լǰ�����+Max��12%����Լ���ǰ���̼�-�Ϲ���Ȩ
%��ֵ��7%����Ȩ�۸񣩣���Ȩ�۸�] ����Լ��λ
margin = min( contractPrice+max(0.12*underlyingPrice- max(underlyingPrice-Strike,0),...
    0.07*Strike),...
    Strike);
rate1 = 0.12;
rate2 = 0.07;
end

