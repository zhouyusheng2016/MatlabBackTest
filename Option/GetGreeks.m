function [ Greeks ] = GetGreeks(Data, I, UnderlyingPriceList, sig, rf, timeAdj,varargin)
Greeks = struct;
switch_delta = false;
switch_gamma = false;
switch_vega = false;
switch_theta = false;
switch_rho = false;

if nargin < 7
    error(message('MatlabBackTest: GetGreeks.m: TooFewInputs'))
end

if nargin >11
    error(message('MatlabBackTest: GetGreeks.m: TooManyInputs'))
end

for i =1 :length(varargin)
    switch varargin{i}
        case 'Delta'
            switch_delta = true;
        case 'Gamma'
            switch_gamma = true;
        case 'Vega'
            switch_vega = true;
        case 'Theta'
            switch_theta = true;
        case 'Rho'
            switch_rho = true;
        otherwise
            error(message('MatlabBackTest: GetGreeks.m: InvaildFields'))    
    end
end

undelrying = UnderlyingPriceList(I);
strike = Data.Strike(I);
t = Data.TimeUntilExpiration(I)+timeAdj;
type = Data.Info{1};
flag_isCall = type == 'call';
if switch_delta
    if flag_isCall
        [Greeks.Delta, ~]= blsdelta(undelrying, strike, rf, t, sig);
    else
        [~,Greeks.Delta]= blsdelta(undelrying, strike, rf, t, sig);
    end
end
if switch_gamma
    Greeks.Gamma = blsgamma(undelrying, strike, rf, t, sig);
end
if switch_vega
    Greeks.Vega = blsvega(undelrying, strike, rf, t, sig);
end
if switch_theta
    if flag_isCall
        [Greeks.Theta, ~]= blstheta(undelrying, strike, rf, t, sig);
    else
        [~,Greeks.Theta]= blstheta(undelrying, strike, rf, t, sig);
    end
end
if switch_rho
    if flag_isCall
        [Greeks.Rho, ~]= blsrho(undelrying, strike, rf, t, sig);
    else
        [~,Greeks.Rho]= blsrho(undelrying, strike, rf, t, sig);
    end
end

end

