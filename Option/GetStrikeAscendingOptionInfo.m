function [ table ] = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames)
% tradeableOptNames 指代期权必须为同一标的
% DB必须为同一标的期权的数据结构
% I 为时间游标，代表本K线
% 输出为option基本信息表
UnderlyingOpen = DB.Underlying.Open(I);                                     % K线开盘价
tradeableOptNames = tradeableOptNames(:);                                   % 格式N X 1
%检索分类信息
contractInfo = [];
for attr = tradeableOptNames'
    Data = getfield(DB, char(attr));                                        %获取数据
    line = {Data.Strike(I) Data.ContractUnit(I) Data.Info{1} Data.Info{2},attr};
    contractInfo = [contractInfo; line];
end
table = cell2table(contractInfo);
table.Properties.VariableNames = {'strike', 'unit','type','expiration','code'};
table = sortrows(table,'strike','ascend');                                  
end
% 后续优化可能用到的代码
%{ 
% 讨论改进可能，并行或GUP 模式下
tic
DataCollection = arrayfun(@(attr) getfield(DB, char(attr)),tradeableOptNames,'UniformOutput',0);
contractInfo = arrayfun(@(i)...
    {DataCollection{i}.Strike(I)...
    DataCollection{i}.ContractUnit(I)...
    DataCollection{i}.Info{1}...
    DataCollection{i}.Info{2}},...
    1:length(DataCollection),'UniformOutput',0);
toc
%}