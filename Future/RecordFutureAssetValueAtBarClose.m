function [ Asset ] = RecordFutureAssetValueAtBarClose(Asset,I)

cashAsset = Asset.Cash(I);                                                  %�ֽ��ʲ�

forzenMargin = Asset.Margins{I};                                            %��֤��

Asset.GrossAssets(I) = cashAsset+forzenMargin;
end

