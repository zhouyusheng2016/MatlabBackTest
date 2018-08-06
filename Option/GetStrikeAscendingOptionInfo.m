function [ table ] = GetStrikeAscendingOptionInfo(DB, I, tradeableOptNames)
% tradeableOptNames ָ����Ȩ����Ϊͬһ���
% DB����Ϊͬһ�����Ȩ�����ݽṹ
% I Ϊʱ���α꣬����K��
% ���Ϊoption������Ϣ��
UnderlyingOpen = DB.Underlying.Open(I);                                     % K�߿��̼�
tradeableOptNames = tradeableOptNames(:);                                   % ��ʽN X 1
%����������Ϣ
contractInfo = [];
for attr = tradeableOptNames'
    Data = getfield(DB, char(attr));                                        %��ȡ����
    line = {Data.Strike(I) Data.ContractUnit(I) Data.Info{1} Data.Info{2},attr};
    contractInfo = [contractInfo; line];
end
table = cell2table(contractInfo);
table.Properties.VariableNames = {'strike', 'unit','type','expiration','code'};
table = sortrows(table,'strike','ascend');                                  
end
% �����Ż������õ��Ĵ���
%{ 
% ���۸Ľ����ܣ����л�GUP ģʽ��
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