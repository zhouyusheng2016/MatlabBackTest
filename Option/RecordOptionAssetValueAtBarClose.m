function  Asset  = RecordOptionAssetValueAtBarClose(Asset,DB,I,Options)
cashAsset = Asset.Cash(I);                                                  %�ֽ��ʲ�
position = Asset.Position{I};                                               %����
Stock = Asset.Stock{I};                                                     %����
forzenMargin = Asset.Margins{I};                                            %��֤��

close = [];                                                                 %���չ�Ʊ���ƻ�ȡ�������̼�
contractUnit = [];                                                          %��Ȩ��Լ����
for i = 1:length(Stock)
     Data = getfield(DB,code2structname(Stock{i}, Options.OptionType));
     close = [close Data.Close(I)];
     contractUnit = [contractUnit Data.ContractUnit(I)];
end
optionAsset = sum(close.*contractUnit.*position);                           %��Ȩ�ʲ�

optionMargins = sum(forzenMargin);                                          %��Ȩ��֤���ܺ�

Asset.GrossAssets(I) = cashAsset+optionAsset+optionMargins;                               %��Ȩ�˻����ʲ���¼
end

