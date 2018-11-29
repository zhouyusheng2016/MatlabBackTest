function Asset = ClearRepo(Asset, DB, Options)
%% 游标
I = DB.CurrentK;
%% 获取账户状态
if I == 1
    AvaCash = Asset.InitCash ;
    TransCash = Asset.InitCash;
else
    AvaCash = Asset.Cash(I);
    TransCash = Asset.CashTransAble(I);
end

%% 订单撮合
for i = 1:length(Asset.OrderRepo{I})
    %获取交易数据
    Data = getfield(DB, Asset.OrderRepo{I}{i});
    %获取交易量限制
    VolumeLimit = Options.VolumeRatio * Data.Volume(I);
    dealPrinciplie = Asset.OrderPrinciple{I}(i);
    if dealPrinciplie > VolumeLimit
        if Options.PartialDeal
            dealPrinciplie = VolumeLimit;
        else
            error('OrderVolumeHigherThanLimitError')
        end
    end
    %% 账户资金结算
    AvaCash = AvaCash - dealPrinciplie;
    TransCash = TransCash - dealPrinciplie;
    
    commission = GetGCCommission(dealPrinciplie, Data.Period);
    interest = InterestByNominalRate(dealPrinciplie, Asset.OrderRate{I}(i), Data.Period);
    pnL = interest-commission;
    %% 更新交易记录
    Asset.DealRepo{I} = [Asset.DealRepo{I}, Asset.OrderRepo{I}(i)];
    Asset.DealRate{I} = [Asset.DealRate{I},Asset.OrderRate{I}(i)];
    Asset.DealVolume{I} = [Asset.DealVolume{I}, dealPrinciplie];
    Asset.DealFee{I} = [Asset.DealFee{I}, commission];
    %% 更新借款状态
    Asset.OutStandingPrinciple = Asset.OutStandingPrinciple+dealPrinciplie;
    %% 确定回款
    BackDate = DB.Times(I)+Data.Period;                                     %回款自然日
    TansDate = BackDate+1;                                                  %回款可转日
    
    idx_FirstTradeDate = find(DB.Times>=BackDate,1);               %回款交易日
    idx_FirstTransDate = find(DB.Times>=TansDate,1);               %回款可转交易日
    % 回款记录
    Asset.RepoBack{idx_FirstTradeDate} = [Asset.RepoBack{idx_FirstTradeDate}, Asset.OrderRepo{I}(i)];
    Asset.InterestGetBack{idx_FirstTradeDate} = [Asset.InterestGetBack{idx_FirstTradeDate}, pnL];
    Asset.PrincipleGetBack{idx_FirstTradeDate} = [Asset.PrincipleGetBack{idx_FirstTradeDate}, dealPrinciplie];
    % 可用本金回款
    Asset.PrincipleReceivable(idx_FirstTradeDate) = Asset.PrincipleReceivable(idx_FirstTradeDate)+dealPrinciplie;
    % 可用利息回款
    Asset.InterestReceivable(idx_FirstTradeDate) = Asset.InterestReceivable(idx_FirstTradeDate)+pnL;
    % 可转
    Asset.CashTransReceivables(idx_FirstTransDate) = Asset.CashTransReceivables(idx_FirstTransDate)+dealPrinciplie+pnL;
end
%% 更新现金状态
Asset.Cash(I) = AvaCash;
Asset.CashTransAble(I) = TransCash;
end