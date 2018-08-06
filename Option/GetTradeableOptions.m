function [ fieldNames ] = GetTradeableOptions(DB, I, allOptionFieldnames)
% ���ҿɽ��׵���Ȩ��Լ�ṹ��
%   DB�� ��Ȩ��Ϣ���ݽṹ�� I �α�
% allOptionFieldnames N X 1 cell
%  return N X 1 cell
fieldNames = {};
for attr = allOptionFieldnames'
   Data = getfield(DB,char(attr));
   if Data.Trade_status(I) == 0
      continue; 
   end
   fieldNames = [fieldNames; attr];
end

end

