function [ Asset ] = UnClearingOptionAsset(Asset,I)
% 本方法用于日内换仓时为了获取平仓后账户信息进行虚假Clearing之后
% 消除本次虚假Clearing带来的影响

% deal字段
Asset.DealStock{I} = [];
Asset.DealVolume{I} = [];
Asset.DealPrice{I} = [];
Asset.DealFee{I} = [];
% 结算字段
Asset.Cash(I) = 0;
Asset.FrozenCash(I) = 0;
Asset.Stock{I} = [];
Asset.Position{I} = [];
Asset.Margins{I} = []; 
Asset.MarginStock{I} = [];
end

