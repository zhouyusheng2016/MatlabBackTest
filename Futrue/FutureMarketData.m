function [DB flag] = FutureMarketData(w,windcode,start_time,end_time,Options)
% ��һ����
if ischar(windcode)
    % ��λ�α�λ�õ���һ��K��
    DB.CurrentK = 1;
    isRealContract = length(windcode) == 10; % ������ԼΪ8λ,
    [Data, flag] = LoadFutureData(w,windcode,start_time,end_time,isRealContract,Options);
    DB=setfield(DB,code2structname(windcode,'F'),Data);
    if flag==0
        disp('=== Back test shutting down! ===')
        return;
    end
end
% ��������
if iscell(windcode)
    % ��λ�α�λ�õ���һ��K��
    DB.CurrentK = 1;
    for i=1:max(size(windcode))
        isRealContract = length(windcode{i}) == 10;
        [Data flag] = LoadFutureData(w,windcode{i},start_time,end_time,isRealContract,Options);
        DB=setfield(DB,code2structname(windcode{i},'F'),Data);
        if flag==0
            disp('=== Back test shutting down! ===')
            return;
        end
    end
end
% ʱ����
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%�������ո�ʽ��ʱ����������գ�
% K������
DB.NK = length(Data.Open);
flag = 1;
end

