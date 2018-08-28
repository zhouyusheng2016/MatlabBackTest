function [ub, lb] = GetPriceBoundGivenIV(underlyingPrice, strike, r, t, type,ivupper,ivlower, vargin)

div = 0;
if nargin == 8
   div = vargin;
end

[cmax,pmax] = blsprice(underlyingPrice,strike,r,t,ivupper,div);
[cmin,pmin] = blsprice(underlyingPrice,strike,r,t,ivlower,div);

type = char(type);
if strcmp(type,'call')
    ub = cmax;
    lb = cmin;
elseif strcmp(type, 'put')
    ub = pmax;
    lb = pmin;
else
    error('GetPriceBoundGivenIV.m: no matching option type')
end
    
    
end

