function [TDB flag] = LoadRepoRate(RateTable,RateType,start_time,end_time,Options)

%% ��ֹ����
start_datenum = datenum(start_time, 'yyyy-mm-dd');
end_datenum = datenum(end_time, 'yyyy-mm-dd');
DataDatenum = datenum(num2str(RateTable.date),'yyyymmdd');
cond1 = DataDatenum>=start_datenum;
cond2 = DataDatenum<=end_datenum;

RateTable = RateTable(cond1 & cond2,:);
RateTable = sortrows(RateTable,'date','ascend');%��������
w_wsd_times_0 =unique(datenum(num2str(RateTable.date),'yyyymmdd'));
timeLength = length(w_wsd_times_0);
% ������Ȩ����������
codes = unique(RateTable.code);
%�����α�
TDB = struct;
for code = codes'
    idx_code_opt = RateTable.code == code;
    thisGC = RateTable(idx_code_opt,:);
    thisGC = sortrows(thisGC,'date','ascend');%��������
   
    dataTime = datenum(num2str(thisGC.date),'yyyymmdd');
    DB.Times = w_wsd_times_0;
    DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�
    [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
    %��¼C/P ������ ��Ĵ���
    DB.Code = strcat(RateType,num2str(thisGC.code(1)));
    DB.Type = RateType;
    DB.Period = str2double(DB.Code(end-2:end));% 204001�к���λΪ����ʱ��
    % ��Ȩ������Ϣ
    DB.Open = nan(timeLength,1);
    DB.Open(idx_haveData) = thisGC.open;%��
    DB.High = nan(timeLength,1);
    DB.High(idx_haveData) = thisGC.high;%��
    DB.Low = nan(timeLength,1);
    DB.Low(idx_haveData) = thisGC.low;%��
    DB.Close = nan(timeLength,1);
    DB.Close(idx_haveData) = thisGC.close;%��
    DB.Volume = nan(timeLength,1);
    DB.Volume(idx_haveData) = thisGC.volume;%��
    DB.Turnover = nan(timeLength,1);
    DB.Turnover(idx_haveData) = thisGC.turnover;%��
    
    DB.NK = length(DB.Open);

    TDB=setfield(TDB,DB.Code,DB);
end
TDB.Times = w_wsd_times_0;
TDB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%�������ո�ʽ��ʱ����������գ�
TDB.NK = length(w_wsd_times_0);
TDB.CurrentK = 1;
flag = 1;

end