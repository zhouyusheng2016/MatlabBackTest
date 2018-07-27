function [ dealprice ] = OrderPirceWithSlippage(price, vol, Options)
    if vol > 0
        dealprice = price * (1+Options.Slippage);
    else
        dealprice = price * (1-Options.Slippage);
    end
end

