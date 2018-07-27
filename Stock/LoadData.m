function [DB flag] = LoadData(w,windcode,start_time,end_time,Options)

% ��������
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(windcode,'open,high,low,close,volume,vwap',start_time,end_time,'PriceAdj=F');
if w_wsd_errorid_0~=0
    disp(['!!! ����' windcode '�������ݴ���: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    flag=0;
    return;
end
% ֤ȯ������Ϣ
[w_wsd_data_1,w_wsd_codes_1,w_wsd_fields_1,w_wsd_times_1,w_wsd_errorid_1,w_wsd_reqid_1]= ...
    w.wsd(windcode,'sec_status,trade_status,pct_chg',start_time,end_time,'PriceAdj=F');
if w_wsd_errorid_1~=0
    disp(['!!! ����' windcode '������Ϣ���ݴ���: ' w_wsd_data_1{1} ' Code: ' num2str(w_wsd_errorid_1) ' !!!']);
    flag=0;
    return;
end
% ֤ȯ������Ϣ
[w_wsd_data_2,w_wsd_codes_2,w_wsd_fields_2,w_wsd_times_2,w_wsd_errorid_2,w_wsd_reqid_2]= ...
    w.wsd(windcode,'ipo_date,concept,industry_CSRC12,industry_gics',start_time,start_time,'industryType=1','PriceAdj=F');
if w_wsd_errorid_2~=0
    disp(['!!! ����' windcode '������Ϣ���ݴ���: ' w_wsd_data_2{1} ' Code: ' num2str(w_wsd_errorid_2) ' !!!']);
    flag=0;
    return;
end

% ����ƴ��
DB.Type = 'S';
DB.Code = windcode;
DB.Info = w_wsd_data_2;%�������ڣ������飨�ز⿪ʼ���ڸ��������֤�����ҵ���ƣ�����wind��ҵ����
DB.Times = w_wsd_times_0;%ʱ����������գ�
DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�
DB.Sec_status = w_wsd_data_1(:,1);%֤ȯ����״̬��L���У�Nδ������֤ȯ��D����
DB.Trade_status = w_wsd_data_1(:,2);%����״̬�����ף�ͣ��һ�죬��ʱͣ�Ƶ�
DB.Pct_chg = w_wsd_data_1(:,3);%�ǵ�����δ��ʾ�ٷֺţ�
DB.Open = w_wsd_data_0(:,1);%��
DB.High = w_wsd_data_0(:,2);%��
DB.Low = w_wsd_data_0(:,3);%��
DB.Close = w_wsd_data_0(:,4);%��
DB.Volume = w_wsd_data_0(:,5);%��
DB.Vwap = w_wsd_data_0(:,6);%��
DB.NK = length(DB.Open);%����������
% ������ϴ

%���ݼ��سɹ�
flag=1;