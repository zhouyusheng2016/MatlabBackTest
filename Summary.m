function Asset = Summary(Asset,DB,Options)
%ʱ����
Asset.Times = DB.Times;
Asset.TimesStr = DB.TimesStr;
%��׼������
Asset.BenchmarkReturns = (DB.Benchmark - DB.Benchmark(1))/DB.Benchmark(1);
Asset.BenchmarkStock = DB.BenchmarkStock;
%��׼ÿ��������
Asset.BenchmarkDailyReturns = [0;(DB.Benchmark(2:end) - DB.Benchmark(1:end-1))./DB.Benchmark(1:end-1)];
%��׼�껯������
Asset.BenchmarkAnnualReturns = (1+Asset.BenchmarkReturns(end))^(250/DB.NK) - 1;
%���ʲ�
Asset.GrossAssets = zeros(DB.NK,1);
for k=1:DB.NK
    Asset.GrossAssets(k) = Asset.Cash(k);
    for p=1:length(Asset.Position{k})
        Data = getfield(DB,[Asset.Stock{k}{p}(8:9) Asset.Stock{k}{p}(1:6)]);
        Asset.GrossAssets(k) = Asset.GrossAssets(k) + Asset.Position{k}(p)*Data.Close(k);
    end
end
%��λ����
Asset.PositionsRatio = (Asset.GrossAssets - Asset.Cash)./Asset.GrossAssets;
%������
Asset.Returns = (Asset.GrossAssets - Asset.GrossAssets(1))/Asset.GrossAssets(1);
%�껯������
Asset.AnnualReturns = (1+Asset.Returns(end))^(250/DB.NK) - 1;
%ÿ��������
Asset.DailyReturns = [0;(Asset.GrossAssets(2:end)-Asset.GrossAssets(1:end-1))./Asset.GrossAssets(1:end-1)];
%��������
Asset.ExcessReturns = Asset.Returns - Asset.BenchmarkReturns;
%���س�
Drawdown = zeros(DB.NK,1);
DrawdownTopInd = zeros(DB.NK,1);
for k = 1:DB.NK
    [top DrawdownTopInd(k)] = max(Asset.GrossAssets(1:k));
    Drawdown(k) = (Asset.GrossAssets(k) - top)/top;
end
[Asset.MaxDrawdown Asset.DrawdownBottomInd] = min(Drawdown);%���س������س������Ҷ˵�
Asset.DrawdownTopInd = DrawdownTopInd(Asset.DrawdownBottomInd);%���س�������˵�
%Beta
Asset.Beta = cov(Asset.DailyReturns,Asset.BenchmarkDailyReturns);
Asset.Beta = Asset.Beta(1,2)/var(Asset.DailyReturns);
%Alpha
Asset.Alpha = Asset.AnnualReturns - Options.RiskFreeReturn - Asset.Beta * ( Asset.BenchmarkAnnualReturns - Options.RiskFreeReturn );
%Volatility
Asset.Volatility = std(Asset.DailyReturns) * sqrt(250);
%Sharpe
Asset.Sharpe = (Asset.AnnualReturns - Options.RiskFreeReturn) / Asset.Volatility;
%% plot
figure;
set(gcf,'position',[100 100 1000 500]);
% colnames = {'�ز�����', '�ز��껯����', '��׼����', '��׼�껯����', 'Alpha', 'Beta', 'Sharpe', 'Volatility', '���س�'};
% t = uitable(gcf, 'Data', ...
%     [Asset.Returns(end) Asset.AnnualReturns Asset.BenchmarkReturns(end) Asset.BenchmarkAnnualReturns Asset.Alpha Asset.Beta Asset.Sharpe Asset.Volatility Asset.MaxDrawdown], ...
%     'ColumnName', colnames, 'Position', [20 20 960 50]);
subplot(2,1,1)
%���ʲ�����
h1=plot(1:DB.NK,1+Asset.Returns,'b');
hold on
h2=plot(1:DB.NK,1+Asset.BenchmarkReturns,'r');
legend([h1 h2],{'User',Asset.BenchmarkStock},'location','northwest')
%���س�����
plot(Asset.DrawdownTopInd,1+Asset.Returns(Asset.DrawdownTopInd),'r.','markersize',20);
plot(Asset.DrawdownBottomInd,1+Asset.Returns(Asset.DrawdownBottomInd),'r.','markersize',20);

title('���ʲ�����')
xtick=get(gca,'xtick')+1;
xtick=xtick(xtick<=size(Asset.Times,1));
set(gca,'xtick',xtick,'xticklabel',datestr(Asset.Times(xtick),'yymmdd'));

subplot(2,1,2)
plot(1:DB.NK,100*Asset.PositionsRatio,'b.-')
title('��λ')
xtick=get(gca,'xtick')+1;
xtick=xtick(xtick<=size(Asset.Times,1));
set(gca,'xtick',xtick,'xticklabel',datestr(Asset.Times(xtick),'yymmdd'));

h=gca;
labels=get(h,'yticklabel'); % ��ȡY��
for i=1:size(labels,1)
   labels_modif2(i,:)=[labels(i,:) '%']; % ����%����
end
set(h,'yticklabel',labels_modif2); % Y���ɰٷ���
%% Report
fprintf('=== �زⱨ�� ===\n')
fprintf('���׼�¼��\n')
TradeHis = cell(DB.NK,1);
for i=1:size(TradeHis,1)
    if ~isempty(Asset.DealStock{i})
        TradeHis{i} = Asset.TimesStr(i,:);
        for j=1:size(Asset.DealStock{i},2)
            TradeHis{i} = [TradeHis{i} ' // ' Asset.DealStock{i}{j} ' ' num2str(Asset.DealVolume{i}(j)) '@' num2str(Asset.DealPrice{i}(j)) ];
        end
        TradeHis{i} = [TradeHis{i} '\n'];
        fprintf(TradeHis{i})
    end
end
fprintf(['�ز����棺    \t' num2str(Asset.Returns(end)) '\n'])
fprintf(['�ز��껯���棺\t' num2str(Asset.AnnualReturns) '\n'])
fprintf(['��׼���棺    \t' num2str(Asset.BenchmarkReturns(end)) '\n'])
fprintf(['��׼�껯���棺\t' num2str(Asset.BenchmarkAnnualReturns) '\n'])
fprintf(['Alpha��      \t' num2str(Asset.Alpha) '\n'])
fprintf(['Beta��       \t' num2str(Asset.Beta) '\n'])
fprintf(['Sharpe��     \t' num2str(Asset.Sharpe) '\n'])
fprintf(['Volatility�� \t' num2str(Asset.Volatility) '\n'])
fprintf(['���س���   \t' num2str(Asset.MaxDrawdown) '\n'])