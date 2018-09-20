function [ Asset ] = RecordFutureAssetValueAtBarClose(Asset,I)

cashAsset = Asset.Cash(I);                                                  %现金资产

forzenMargin = Asset.Margins{I};                                            %保证金

Asset.GrossAssets(I) = cashAsset+forzenMargin;
end

