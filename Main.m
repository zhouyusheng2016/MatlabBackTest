%% set path to backtest frame work folder
path(path,genpath('E:\Matlab2017a\bin\BackTestFrameWork'));                 % added
%% �ز�ģ��
% Version/Date:     0.2 / 2017.10.30
%% Options
clear;close all;clc
% ֤ȯ�����˻�ѡ������
Options.InitCash = 1000000;
Options.Benchmark = '600000.SH'; % ���û�׼
Options.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
Options.MinAmountPerHand = 100;
Options.RiskFreeReturn = 0.05; % �޷���������
Options.MinCommission = 5; % ��СӶ��
Options.Commission = 0.0008; % Ӷ��
Options.StampTax = 0.001; % ����ʱ���յ�ӡ��˰
Options.Slippage = 0.00246; % ����
Options.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
Options.Short = 1; % ����Խ��ױ�Ľ�������
Options.DelayDays = 3; % ����ʧ��������ӳٽ����������������������
% �ڻ������˻�ѡ������
FOptions.InitCash = 1000000;
FOptions.VolumeRatio = 0.25; % �ɽ������Ʋ��ó������ճɽ����Ĺ̶�����
FOptions.RiskFreeReturn = 0.05; % �޷���������
FOptions.MinCommission = 5; % ��СӶ��
FOptions.Commission = 0.0003; % Ӷ��
FOptions.StampTax = 0.001; % ����ʱ���յ�ӡ��˰
FOptions.Slippage = 0.00246; % ����
FOptions.Margin = 0.15; % ��֤�����
FOptions.PartialDeal = 1; % �����Զ����ֳɽ�ģʽ
FOptions.Short = 1; % ����Խ��ױ�Ľ�������
FOptions.DelayDays = 3; % ����ʧ��������ӳٽ����������������������
% Options.T_0 = 1; % ����T+0����

windcode = {'600000.SH','600300.SH'};
start_time = '2015-02-09';
end_time = '2018-07-18';

%% Test 1
Context.fast = 5;
Context.slow = 20;
[Asset1,DB1] = Backtest(@Strategy,Context,{'600000.SH','600300.SH'},start_time,end_time,Options);
filename = 'E:\Matlab2017a\bin\SSE_O510050_greek_ivhvlx_1day_201502to20180501.csv';
%% Test 2
Context.fast = 2;
Context.slow = 5;
[Asset2,DB2] = Backtest(@Strategy,Context,{'600000.SH','600300.SH'},'2014-12-02 09:00:00','2015-7-31 12:00:00',Options);
%% TEst
