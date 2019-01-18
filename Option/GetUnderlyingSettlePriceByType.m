function [ price ] = GetUnderlyingSettlePriceByType( Data, I, type )
price  = GetOptionContractSettlePriceByType( Data, I, type );
end