function [DB flag] = LoadFutureData(w,windcode,start_time,end_time,isRealContract,Options)
% 期货行情数据
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(windcode,'open,high,low,close,volume,vwap,settle,pre_settle,adjfactor',start_time,end_time);
if w_wsd_errorid_0~=0
    disp(['!!! 加载' windcode '行情数据错误: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    flag=0;
    return;
end
% 期货交易信息
[w_wsd_data_1,~,w_wsd_fields_1,w_wsd_times_1,w_wsd_errorid_1,w_wsd_reqid_1]= ...
    w.wsd(windcode,'sec_status,pct_chg,chg',start_time,end_time);
if w_wsd_errorid_1~=0
    disp(['!!! 加载' windcode '交易信息数据错误: ' w_wsd_data_1{1} ' Code: ' num2str(w_wsd_errorid_1) ' !!!']);
    flag=0;
    return;
end
% 期货基本信息
[w_wsd_data_2,~,w_wsd_fields_2,w_wsd_times_2,w_wsd_errorid_2,w_wsd_reqid_2]= ...
    w.wsd(windcode,'lasttrade_date,lastdelivery_date,dlmonth,margin,punit,changelt,mfprice,contractmultiplier,ftmargins',...
    start_time,end_time,'industryType=1');
if w_wsd_errorid_2~=0
    disp(['!!! 加载' windcode '基本信息数据错误: ' w_wsd_data_2{1} ' Code: ' num2str(w_wsd_errorid_2) ' !!!']);
    flag=0;
    return;
end

% 数据拼接
DB.Type = 'F';
DB.Code = windcode;
DB.isRealContract = isRealContract;
DB.Info = w_wsd_data_2(end,:);%最后交易日,最后交割日,交割月份,保证金比例,单位,涨跌限制,最小变动价位,合约乘数,最初交易保证金
if isnan(DB.Info{8}) && length(DB.Code)==8
    DB.Info{8} = 300;
    sprintf('期货连续合约合约乘数不存在：已自动填写为 300')
end
DB.Times = w_wsd_times_0;%时间戳（交易日）
DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）

DB.Sec_status = w_wsd_data_1(:,1);%证券存续状态：L上市，N未上市新证券，D退市
DB.Pct_chg = w_wsd_data_1(:,2);%涨跌幅（未显示百分号）
DB.chg = w_wsd_data_1(:,3);%涨跌

DB.Open = w_wsd_data_0(:,1);%开
DB.High = w_wsd_data_0(:,2);%高
DB.Low = w_wsd_data_0(:,3);%低
DB.Close = w_wsd_data_0(:,4);%收
DB.Volume = w_wsd_data_0(:,5);%量
DB.Vwap = w_wsd_data_0(:,6);%vwap
DB.Settle = w_wsd_data_0(:,7);%结算价
DB.PreSettle = w_wsd_data_0(:,8);%前结算价
DB.AdjFactor = w_wsd_data_0(:,9);%赋权因子 
DB.NK = length(DB.Open);%行情数据量
% 数据清洗
%数据加载成功
flag=1;