%% set path to backtest frame work folder
backtestDicPath = strcat(matlabroot,'\bin\MatlabBackTest\');
futrueDicPath = strcat(backtestDicPath,'Future');
optionDicPath = strcat(backtestDicPath,'Option');
stockDicPath = strcat(backtestDicPath,'Stock');
dataPath = strcat(backtestDicPath,'DataExample\OptionDataExample.csv');

path(path,genpath(backtestDicPath));
path(path,genpath(futrueDicPath));                 % added �ڻ�path
path(path,genpath(optionDicPath));                 % added 
path(path,genpath(stockDicPath));                 % added

% �˻�����
% ֤ȯ�����˻�ѡ������
Options.InitCash = 1000000;
Options.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
Options.MinAmountPerHand = 100;
Options.MinCommission = 5; % ��СӶ��
Options.Commission = 0.0008; % Ӷ��
Options.StampTax = 0.001; % ����ʱ���յ�ӡ��˰
Options.Slippage = 0.00246; % ����
Options.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
Options.Short = 1; % ����Խ��ױ�Ľ�������
Options.DelayDays = 3; % ����ʧ��������ӳٽ����������������������


% this could take a while
start_time = '2015-02-09';
end_time = '2018-04-30';
[DB flag] = LoadOptionData_Local(dataPath,start_time,end_time,Options);

%% ���ݵ���
