function [ iv ] = BlsimpvAssignNaNToBound( s,k,rf,t,p,div,type,ivub,ivlb)
%
iv = blsimpv(s,k,rf,t,p,ivub,div,[],{char(type)});
if isnan(iv)
    [ub, lb] = GetPriceBoundGivenIV(s, k, rf, t, type,ivub,ivlb,div);
    if p >= ub
        iv = ivub;
        return
    end
    if p<=lb
       iv = ivlb;
       return
    end
end
end

