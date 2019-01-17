function [ Data ] = FindCommodityOptionContractByExpMoney( OptDB, I,varargin)
% OptDB -- ��Ȩ���ݽṹ
% varargin{}{1} -- undelryign price type�� close/open
% varargin{}{2} -- option moneyness : otm/ itm
% varargin{}{3} -- number of strikes divegerd from underlying price
% varargin{}{4} -- expiraiton: 1 for current monty, 2for next month,...
% varargin{}{5} -- option type : call/ put
% ����1e4��Ϊδ������Լ�ĺ�Լ����
%% ��ȡ����
tradeables = OptDB.TradeableOptionField{I};
num = length(tradeables);
Datas = arrayfun(@(n) getfield(OptDB, tradeables{n}),1:num,'UniformOutPut',0);

% ����
daysLeft = arrayfun(@(n)Datas{n}.DaysUntilExpiration(I),1:num);%ʣ��ʱ��
uniqueDaysLeft = unique(daysLeft);
%����
type = arrayfun(@(n)char(Datas{n}.Info{1}),1:num,'UniformOutput',0);
%% selection
numOfVars = length(varargin);
targetedData = cell(numOfVars,1);
for i = 1: numOfVars
    % �ҵ�Ŀ�������
    if varargin{i}{4}<=length(uniqueDaysLeft)
        tar_expNum = daysLeft == uniqueDaysLeft(varargin{i}{4}); % ѡ����Ȩ��Լ�ĵ�����
    else
        tar_expNum = logical(false(1,length(daysLeft)));
    end
    % �ҵ�Ŀ�� call put
    tar_type = strcmp(type, varargin{i}{5});
    % �ҵ�Ŀ���Լ��
    thisData = Datas(tar_expNum&tar_type);
    % �ҵ�Ŀ���Լ��ı�ļ۸�
    Data_ = Datas{i};
    str = split(Data_.Info{3},'.');
    str = str{1};
    underlyingData = getfield(OptDB.Underlying,str);
    underlyingPriceSeries = getfield(underlyingData,varargin{i}{1});        % ���Ŀ��۸�����
    underlyingPrice = underlyingPriceSeries(I);
        
    strikes = arrayfun(@(n)thisData{n}.Strike(I),1:length(thisData));
    uniqueStrikes = unique(strikes);
    
    greaterThanUnderlying = uniqueStrikes>=underlyingPrice;
    smallerThanUnderlying = ~greaterThanUnderlying;
    
    moneyType = strcat(varargin{i}{5},varargin{i}{2});
    
    switch moneyType
        case 'callotm'
            flag_higherThanAtm = true;
        case 'callitm'
            flag_higherThanAtm = false;
        case 'putotm'
            flag_higherThanAtm = false;
        case 'putitm'
            flag_higherThanAtm = true;
        otherwise
            error('NoMoneyNessTypeFounded: FindOptionContractByExpMoney.m')
    end
    
    if flag_higherThanAtm
        tarStrikes = uniqueStrikes(greaterThanUnderlying);
    else
        tarStrikes = sort(uniqueStrikes(smallerThanUnderlying),'descend');
    end
    
    if length(tarStrikes)<varargin{i}{3}
        useStrike = [];
    else
        useStrike = tarStrikes(varargin{i}{3});
    end
    if ~isempty(useStrike)                                                  %���ڸ�����Լ�����ڵ����
        idx_tarStrike = strikes == useStrike;
        targetedData(i) = thisData(idx_tarStrike);
    else
        targetedData(i) = cell(1,1);                                        %�������򷵻ؿ�ֵ
    end
    
end
 Data = targetedData;
end
 