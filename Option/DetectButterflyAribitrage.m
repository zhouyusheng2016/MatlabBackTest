function [ArbitrageMethod, flag] = DetectButterflyAribitrage(Triplet,I,varargin)

%% ��Ⲣ�����ʽ����
defaultPriceType = 'Open';
expectedPriceType = {'Open','Close'};
p = inputParser;
addRequired(p,'I',@(x)isnumeric(x)&&x>0&&floor(x)==x);                      %���������
addParameter(p,'PriceType',defaultPriceType,@(x) any(validatestring(x,expectedPriceType)));
parse(p, I, varargin{:});
% �������
Triplet = Triplet(:);
%����Ƿ�Ϊ������Լ
if(length(Triplet) ~= 3) error('Option Data should input in cell 3'); end
%����Լ��Ϣ�Ƿ�Ϊ��
if sum(arrayfun(@(i)isempty(Triplet{i}),1:3)) ~= 0 error('input Option Data shoukd not be empty'); end
% ����Լ�Ƿ�ͬΪcall or put
if sum(arrayfun(@(i)Triplet{i}.Info{1}~=Triplet{1}.Info{1},2:3))~=0
    error('input Option Data should be of one type, put or call')
end
% ��ȡ����
strikes = arrayfun(@(i)Triplet{i}.Strike(I),1:3);
priceFields = arrayfun(@(i)getfield(Triplet{i},p.Results.PriceType),1:3,'UniformOutput',0);
price = arrayfun(@(i) priceFields{i}(I),1:3);

% ���ݲ����Լ���ʱ
flag_nan = sum(isnan(price) | isnan(strikes)) ~= 0;
if flag_nan
    ArbitrageMethod = [];
    flag = false;
   return 
end

codes = arrayfun(@(i)Triplet{i}.Code,1:3,'UniformOutput',0);
stopList = [price', strikes'];
table = array2table(stopList,'VariableNames',{'price','strike'});
table.code = codes';
table = sortrows(table,'strike','ascend');

%% �����ʽ����
lowStrikeOpt.strike = table(1,:).strike;
lowStrikeOpt.price = table(1,:).price;

midStrikeOpt.strike = table(2,:).strike;
midStrikeOpt.price = table(2,:).price;

highStrikeOpt.strike = table(3,:).strike;
highStrikeOpt.price = table(3,:).price;

longButterflyCallSpreadPayoff = @(s,k1,k2,k3) max(s-k1,0) - 2*max(s-k2,0) + max(s-k3,0);
longButterflyPutSpreadPayoff = @(s,k1,k2,k3) max(k1-s,0) - 2*max(k2-s,0) + max(k3-s,0);

if Triplet{1}.Info{1} == 'call'
    longSpread.cost = lowStrikeOpt.price - 2*midStrikeOpt.price + highStrikeOpt.price;
    longSpread.payoff1 = longButterflyCallSpreadPayoff(lowStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
    longSpread.payoff2 = longButterflyCallSpreadPayoff(midStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
    longSpread.payoff3 = longButterflyCallSpreadPayoff(highStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
elseif Triplet{1}.Info{1} == 'put'
    longSpread.cost = lowStrikeOpt.price - 2*midStrikeOpt.price + highStrikeOpt.price;
    longSpread.payoff1 = longButterflyPutSpreadPayoff(lowStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
    longSpread.payoff2 = longButterflyPutSpreadPayoff(midStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
    longSpread.payoff3 = longButterflyPutSpreadPayoff(highStrikeOpt.strike ,lowStrikeOpt.strike,midStrikeOpt.strike,highStrikeOpt.strike);
else
    error('Option Type Error: call or put')
end
payoffs = [longSpread.payoff1,longSpread.payoff2,longSpread.payoff3];
maxPayoff = max(payoffs);
minPayoff = min(payoffs);

%% �������butterfly��cost С�� ����С�ر�
if longSpread.cost <= minPayoff
    flag = true;
    ArbitrageMethod = struct();
    ArbitrageMethod.Long{1}.Code = table(1,:).code;
    ArbitrageMethod.Long{1}.price = lowStrikeOpt.price;
    
    ArbitrageMethod.Short{1}.Code = table(2,:).code;
    ArbitrageMethod.Short{1}.price = midStrikeOpt.price;
    
    ArbitrageMethod.Long{2}.Code = table(3,:).code;
    ArbitrageMethod.Long{2}.price = highStrikeOpt.price;
    
    ArbitrageMethod.MaxPayoff = maxPayoff;
    ArbitrageMethod.MinPayoff = minPayoff;
    ArbitrageMethod.Cost = longSpread.cost;
    ArbitrageMethod.Type = 'LongButterfly';
    return
end
%% �������butterfly��cost С���� ��С�ر�
if -longSpread.cost <= -maxPayoff
    flag = true;
    ArbitrageMethod = struct();
    ArbitrageMethod.Short{1}.Code = table(1,:).code;
    ArbitrageMethod.Short{1}.price = lowStrikeOpt.price;
    
    ArbitrageMethod.Long{1}.Code = table(2,:).code;
    ArbitrageMethod.Long{1}.price = midStrikeOpt.price;
    
    ArbitrageMethod.Short{2}.Code = table(3,:).code;
    ArbitrageMethod.Short{2}.price = highStrikeOpt.price;
    
    ArbitrageMethod.MaxPayoff = -minPayoff;
    ArbitrageMethod.MinPayoff = -maxPayoff;
    ArbitrageMethod.Cost = -longSpread.cost;
    ArbitrageMethod.Type = 'ShortButterfly';
    return
end
flag = false;
ArbitrageMethod = [];
end
