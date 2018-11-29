function Asset = InitRepoAsset(DB,Options)
NT = DB.NK;
% 时间轴
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
Asset.InitCash = Options.InitCash;                                          %初始资金
Asset.OutStandingPrinciple = 0;
%% 下单记录
% 下单量序列
Asset.OrderPrinciple = cell(NT,1);
% 下单价序列
Asset.OrderRate = cell(NT,1);
% 下单标的序列
Asset.OrderRepo = cell(NT,1);
%% 成交记录
% 成交量序列
Asset.DealVolume = cell(NT,1);
% 成交价序列
Asset.DealRate = cell(NT,1);
% 成交标的序列
Asset.DealRepo = cell(NT,1);
% 成交手续费序列
Asset.DealFee = cell(NT,1);
% 结算手续费序列
Asset.SettlementFee = cell(NT,1);
%% 持仓记录

%% 本息到账时间
% 利息
Asset.RepoBack = cell(NT,1);
Asset.InterestGetBack = cell(NT,1);
Asset.PrincipleGetBack = cell(NT,1);
%% 现金状态
% 可用现金序列
Asset.Cash = zeros(NT,1);
Asset.InterestReceivable = zeros(NT,1);
Asset.PrincipleReceivable = zeros(NT,1);
% 可转现金序列
Asset.CashTransAble = zeros(NT,1);
Asset.CashTransReceivables =zeros(NT,1);
%% 总资产记录
Asset.GrossAssets = zeros(NT,1);
end