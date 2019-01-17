function  Asset  = RecordOptionAssetValueAtBarClose(Asset,DB,I,Options)
cashAsset = Asset.Cash(I);                                                  %现金资产
position = Asset.Position{I};                                               %仓量
Stock = Asset.Stock{I};                                                     %名称
forzenMargin = Asset.Margins{I};                                            %保证金

close = [];                                                                 %按照股票名称获取当天收盘价
contractUnit = [];                                                          %期权合约乘数
for i = 1:length(Stock)
     Data = getfield(DB,code2structname(Stock{i}, Options.OptionType));
     close = [close Data.Close(I)];
     contractUnit = [contractUnit Data.ContractUnit(I)];
end
optionAsset = sum(close.*contractUnit.*position);                           %期权资产

optionMargins = sum(forzenMargin);                                          %期权保证金总和

Asset.GrossAssets(I) = cashAsset+optionAsset+optionMargins;                               %期权账户总资产记录
end

