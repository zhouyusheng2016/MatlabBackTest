function Asset = UpdateAccountGrossAsset(Asset,DB)
%% �����˻���ֵ
Asset.GrossAssets(DB.CurrentK) = Asset.Cash(DB.CurrentK)+Asset.OutStandingPrinciple;
end