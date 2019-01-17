function [ Data ] = FindCommodityOptionContractByExpMoney( OptDB, I,varargin)
% OptDB -- 期权数据结构
% varargin{}{1} -- undelryign price type： close/open
% varargin{}{2} -- option moneyness : otm/ itm
% varargin{}{3} -- number of strikes divegerd from underlying price
% varargin{}{4} -- expiraiton: 1 for current monty, 2for next month,...
% varargin{}{5} -- option type : call/ put
% 采用1e4作为未调整合约的合约乘数
%% 获取数据
tradeables = OptDB.TradeableOptionField{I};
num = length(tradeables);
Datas = arrayfun(@(n) getfield(OptDB, tradeables{n}),1:num,'UniformOutPut',0);

% 期限
daysLeft = arrayfun(@(n)Datas{n}.DaysUntilExpiration(I),1:num);%剩余时限
uniqueDaysLeft = unique(daysLeft);
%类型
type = arrayfun(@(n)char(Datas{n}.Info{1}),1:num,'UniformOutput',0);
%% selection
numOfVars = length(varargin);
targetedData = cell(numOfVars,1);
for i = 1: numOfVars
    % 找到目标的期限
    if varargin{i}{4}<=length(uniqueDaysLeft)
        tar_expNum = daysLeft == uniqueDaysLeft(varargin{i}{4}); % 选择期权合约的到期日
    else
        tar_expNum = logical(false(1,length(daysLeft)));
    end
    % 找到目标 call put
    tar_type = strcmp(type, varargin{i}{5});
    % 找到目标合约组
    thisData = Datas(tar_expNum&tar_type);
    % 找到目标合约组的标的价格
    Data_ = Datas{i};
    str = split(Data_.Info{3},'.');
    str = str{1};
    underlyingData = getfield(OptDB.Underlying,str);
    underlyingPriceSeries = getfield(underlyingData,varargin{i}{1});        % 标的目标价格序列
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
    if ~isempty(useStrike)                                                  %存在给定合约不存在的情况
        idx_tarStrike = strikes == useStrike;
        targetedData(i) = thisData(idx_tarStrike);
    else
        targetedData(i) = cell(1,1);                                        %不存在则返回空值
    end
    
end
 Data = targetedData;
end
 