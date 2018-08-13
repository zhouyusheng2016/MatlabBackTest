function Asset = InitFutureAsset(DB,Options)
NT = DB.NK;
% 时间轴
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
% 当前持仓量
Asset.CurrentPosition = 0;
Asset.CurrentStock = [];
Asset.CurrentMargins = [];
% 下单量序列
Asset.OrderVolume = cell(NT,1);
% 下单价序列
Asset.OrderPrice = cell(NT,1);
% 下单标的序列
Asset.OrderStock = cell(NT,1);
% 成交量序列
Asset.DealVolume = cell(NT,1);
% 成交价序列
Asset.DealPrice = cell(NT,1);
% 成交标的序列
Asset.DealStock = cell(NT,1);
% 成交手续费序列
Asset.DealFee = cell(NT,1);
% 持仓量序列
Asset.Position = cell(NT,1);
% 持仓标的序列
Asset.Stock = cell(NT,1);
% 可用现金序列
Asset.Cash = zeros(NT,1);
% 各合约已用保证金
Asset.Margins = cell(NT,1);
% 上次计算可用保证金以及已用保证金的证券代码
Asset.SettleCode = cell(NT,1);
% 上次计算可用保证金以及已用保证金的结算价格
Asset.Settle = cell(NT,1);
% 已用保证金总和
Asset.FrozenCash = zeros(NT,1);
% 总资产序列
Asset.GrossAssets = zeros(NT,1);
% 初始资金量
Asset.InitCash = Options.InitCash;
% 保证金催缴数额
Asset.MarginCall = zeros(NT,1);
% 保证金催缴品种
Asset.MarginCallStock = cell(NT,1);
% 保证金催缴数额，单个合约
Asset.MarginCallAmount = cell(NT,1);
% 持仓至到期合约
Asset.ExpiredContract = cell(NT,1);
% 持仓至到期合约数量
Asset.ExpiredContractPosition = cell(NT,1);
% 持仓至到期合约价格
Asset.ExpiredContractSettlePrice = cell(NT,1);
end