function [ub,lb] = VanillaOptionBounds( Underlying,Strike, InterestRate, Time,varargin)
%欧式期权的无套利价格区间

% 输入量检测
if nargin < 5
   error('not enought argument') 
end

if nargin > 6
   error ('too many argument') 
end

if nargin == 5
    type = char(varargin{1});
    flag_isCall = strcmp(type,'call');
    flag_isPut = strcmp(type,'put');
end
Div = 0;
if nargin == 6
    Div = vargin{1};
    type = char(varargin{2});
    flag_isCall = strcmp(type,'call');
    flag_isPut = strcmp(type,'put');
end

if flag_isCall
    ub = Underlying-Div;
    lb = Underlying - Strike*exp(-InterestRate*Time)-Div;
    return
end

if flag_isPut
    ub = Strike*exp(-InterestRate*Time)+Div;
    lb = Strike*exp(-InterestRate*Time) - Underlying+Div;
    return
end

end

