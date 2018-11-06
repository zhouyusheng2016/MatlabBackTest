function [ Data ] = FindOptionContractByExpMoney( OptDB, I,varargin);
% OptDB -- ��Ȩ���ݽṹ
% varargin{}{1} -- undelryign price type�� close/open
% varargin{}{2} -- option moneyness : otm/ itm
% varargin{}{3} -- number of strikes divegerd from underlying price
% varargin{}{4} -- expiraiton: 1 for current monty, 2for next month,...
% varargin{}{5} -- option type : call/ put

%% data gethering
tradeables = OptDB.TradeableOptionField{I};
num = length(tradeables);
Datas = arrayfun(@(n) getfield(OptDB, tradeables{n}),1:num,'UniformOutPut',0);
%% extract Info
contractunit = arrayfun(@(n)Datas{n}.ContractUnit(I),1:num);
idx_adjContract = contractunit==1e5; %������Լ
Datas(idx_adjContract) = {};%�����ǵ�����Լ
% ����
daysLeft = arrayfun(@(n)Datas{n}.DaysUntilExpiration(I),1:num);%ʣ��ʱ��
uniqueDaysLeft = unique(daysLeft);
%����
type = arrayfun(@(n)char(Datas{n}.Info{1}),1:num,'UniformOutput',0);

%% selection
numOfVars = length(varargin);
targetedData = cell(numOfVars,1);

for i = 1:numOfVars
    % ��ȡ��ļ۸�
    underlyingPriceSeries = getfield(OptDB.Underlying,varargin{i}{1});
    underlyingPrice = underlyingPriceSeries(I);
    % ��ȡ���������ͷ��������ı�־
    if varargin{i}{4}<=length(uniqueDaysLeft)
        tar_expNum = daysLeft == uniqueDaysLeft(varargin{i}{4}); % ѡ����Ȩ��Լ�ĵ�����
    else
        tar_expNum = logical(false(1,length(daysLeft)));
    end
    tar_type = strcmp(type, varargin{i}{5});
    % ��ȡĿ������
    thisData = Datas(tar_expNum&tar_type);
    % ��ȡ
    strikes = arrayfun(@(n)thisData{n}.Strike(I),1:length(thisData));
    uniqueStrikes = unique(strikes);
    
    greaterThanUnderlying = uniqueStrikes>=underlyingPrice;
    smallerThanUnderlying = ~greaterThanUnderlying;
    
    moneyType = strcat(varargin{i}{5},varargin{i}{2});
    
    %% �жϲ���ƽֵ�ϻ���ƽֵ��
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
        useStrike = find(false);
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

