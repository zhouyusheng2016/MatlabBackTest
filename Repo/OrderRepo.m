function Asset = OrderRepo(DB, Asset, repo, principle, ratePrice, Options)
%�α�����
I = DB.CurrentK;
Data = getfield(DB,repo);

todayHigh = Data.High(I);
todayLow = Data.Low(I);
todayVol = Data.Volume(I);
% �жϼ۸��Ƿ����
flag_tooLow = ratePrice<todayLow;
flag_tooHigh = ratePrice>todayHigh;

%% �µ��ֶ�
if flag_tooHigh && Options.PriceAdjustOnHighLowOutRange
    ratePrice = todayHigh;
    display('rate price higher than HighBar, adjusted to Hihg')
end
if flag_tooLow && Options.PriceAdjustOnHighLowOutRange
    ratePrice = todayLow;
    display('rate price lower than LowBar, adjusted to Low')
end
% �µ�������
Asset.OrderPrinciple{I} = [Asset.OrderPrinciple{I}, principle];
% �µ�������
Asset.OrderRate{I} = [Asset.OrderRate{I}, ratePrice];
% �µ��������
Asset.OrderRepo{I} = [Asset.OrderRepo{I}, {repo}];
end

