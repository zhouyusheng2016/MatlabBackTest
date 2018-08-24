function [DB flag] = LoadFutureData(w,windcode,start_time,end_time,isRealContract,Options)
% �ڻ���������
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(windcode,'open,high,low,close,volume,vwap,settle,pre_settle,adjfactor',start_time,end_time);
if w_wsd_errorid_0~=0
    disp(['!!! ����' windcode '�������ݴ���: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    flag=0;
    return;
end
% �ڻ�������Ϣ
[w_wsd_data_1,~,w_wsd_fields_1,w_wsd_times_1,w_wsd_errorid_1,w_wsd_reqid_1]= ...
    w.wsd(windcode,'sec_status,pct_chg,chg',start_time,end_time);
if w_wsd_errorid_1~=0
    disp(['!!! ����' windcode '������Ϣ���ݴ���: ' w_wsd_data_1{1} ' Code: ' num2str(w_wsd_errorid_1) ' !!!']);
    flag=0;
    return;
end
% �ڻ�������Ϣ
[w_wsd_data_2,~,w_wsd_fields_2,w_wsd_times_2,w_wsd_errorid_2,w_wsd_reqid_2]= ...
    w.wsd(windcode,'lasttrade_date,lastdelivery_date,dlmonth,margin,punit,changelt,mfprice,contractmultiplier,ftmargins',...
    start_time,end_time,'industryType=1');
if w_wsd_errorid_2~=0
    disp(['!!! ����' windcode '������Ϣ���ݴ���: ' w_wsd_data_2{1} ' Code: ' num2str(w_wsd_errorid_2) ' !!!']);
    flag=0;
    return;
end

% ����ƴ��
DB.Type = 'F';
DB.Code = windcode;
DB.isRealContract = isRealContract;
DB.Info = w_wsd_data_2(end,:);%�������,��󽻸���,�����·�,��֤�����,��λ,�ǵ�����,��С�䶯��λ,��Լ����,������ױ�֤��
if isnan(DB.Info{8}) && length(DB.Code)==8
    DB.Info{8} = 300;
    sprintf('�ڻ�������Լ��Լ���������ڣ����Զ���дΪ 300')
end
DB.Times = w_wsd_times_0;%ʱ����������գ�
DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�

DB.Sec_status = w_wsd_data_1(:,1);%֤ȯ����״̬��L���У�Nδ������֤ȯ��D����
DB.Pct_chg = w_wsd_data_1(:,2);%�ǵ�����δ��ʾ�ٷֺţ�
DB.chg = w_wsd_data_1(:,3);%�ǵ�

DB.Open = w_wsd_data_0(:,1);%��
DB.High = w_wsd_data_0(:,2);%��
DB.Low = w_wsd_data_0(:,3);%��
DB.Close = w_wsd_data_0(:,4);%��
DB.Volume = w_wsd_data_0(:,5);%��
DB.Vwap = w_wsd_data_0(:,6);%vwap
DB.Settle = w_wsd_data_0(:,7);%�����
DB.PreSettle = w_wsd_data_0(:,8);%ǰ�����
DB.AdjFactor = w_wsd_data_0(:,9);%��Ȩ���� 
DB.NK = length(DB.Open);%����������
% ������ϴ
%���ݼ��سɹ�
flag=1;