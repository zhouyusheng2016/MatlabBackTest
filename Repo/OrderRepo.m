function Asset = OrderRepo(DB, Asset, repo, principle, ratePrice, Options)
%游标设置
I = DB.CurrentK;
Data = getfield(DB,repo);

todayHigh = Data.High(I);
todayLow = Data.Low(I);
todayVol = Data.Volume(I);
% 判断价格是否合适
flag_tooLow = ratePrice<todayLow;
flag_tooHigh = ratePrice>todayHigh;

%% 下单字段
if flag_tooHigh && Options.PriceAdjustOnHighLowOutRange
    ratePrice = todayHigh;
    display('rate price higher than HighBar, adjusted to Hihg')
end
if flag_tooLow && Options.PriceAdjustOnHighLowOutRange
    ratePrice = todayLow;
    display('rate price lower than LowBar, adjusted to Low')
end
% 下单量序列
Asset.OrderPrinciple{I} = [Asset.OrderPrinciple{I}, principle];
% 下单价序列
Asset.OrderRate{I} = [Asset.OrderRate{I}, ratePrice];
% 下单标的序列
Asset.OrderRepo{I} = [Asset.OrderRepo{I}, {repo}];
end

