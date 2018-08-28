function [ OrderOut ] = AdaptOrderOrder( OrderIn,CurrentStock, CurrentPosition )
% ���˳�����ʽ�Ϊ��
OrderOut = [];
ExitLong = [];%ƽ��
ExitShort = [];%ƽ��
EnterLong = [];%�࿪
EnterShort = [];%�տ�
% �����䵥˳��
len=length(OrderIn);
orderStock = arrayfun(@(i)OrderIn{i}.Stock, 1:len,'UniformOutput',0);
orderVol = arrayfun(@(i)OrderIn{i}.Volume, 1:len);

for i = 1:length(OrderIn)                                                   %����order��˳�����
    idx_orderInCurrent = strcmp(orderStock(i),CurrentStock);
    flag_notInCurrentPos = sum(idx_orderInCurrent) == 0;
%% �ص�����
    if ~flag_notInCurrentPos % Ŀǰ�ֲ��µ���Լ
        SplitedOrderVol = SplitOpenCloseOrder( CurrentPosition(idx_orderInCurrent),orderVol(i));
        % ƽ��
        if SplitedOrderVol.close~=0
            thisOrder = OrderIn{i};%��������Ϣ
            thisOrder.Volume = SplitedOrderVol.close;%����ƽ����
            if SplitedOrderVol.close < 0% ƽ��
                ExitLong = [ExitLong {thisOrder}];
            else %>0ƽ��
                ExitShort = [ExitShort {thisOrder}];
            end
        end
        %����
        if SplitedOrderVol.open~=0
            thisOrder = OrderIn{i};%��������Ϣ
            thisOrder.Volume = SplitedOrderVol.open;%����������
            if SplitedOrderVol.open > 0 %�࿪
                EnterLong = [EnterLong {thisOrder}];
            else % < 0  �տ�
                EnterShort = [EnterShort {thisOrder}];
            end
        end
    else % �˵�Ϊ�����ֲ�λ�ص�����
%% ���ص�����
        if OrderIn{i}.Volume~=0
            if OrderIn{i}.Volume > 0
                EnterLong = [EnterLong OrderIn(i)];
            else
                EnterShort = [EnterShort OrderIn(i)];
            end
        end
    end
end
OrderOut = [ExitLong, ExitShort, EnterLong, EnterShort];
end

