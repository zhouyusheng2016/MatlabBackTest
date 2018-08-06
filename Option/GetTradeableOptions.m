function [ fieldNames ] = GetTradeableOptions(DB, I, allOptionFieldnames)
% 查找可交易的期权合约结构名
%   DB， 期权信息数据结构， I 游标
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

