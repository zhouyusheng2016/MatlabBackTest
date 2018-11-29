function Asset = UpdateAccountGrossAsset(Asset,DB)
%% 更新账户净值
Asset.GrossAssets(DB.CurrentK) = Asset.Cash(DB.CurrentK)+Asset.OutStandingPrinciple;
end