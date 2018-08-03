function [Volume] = GetDealVolType(currentPos, lastPos, tradeVol)
% ȷ�����ղ�λ�仯�����Լ�����
% �����ֲ֡���֡�������
% �񿪲֡���ƽ�� struct
if sign(lastPos)*sign(tradeVol) == 1 %�����ַ�����ͬ
    openVol = tradeVol;
    closeVol = 0;
elseif sign(lastPos)*sign(tradeVol) == -1 % ��ָ���ַ����෴
    if sign(lastPos) == sign(currentPos) % ��ָ����ղ�λͬ��
        openVol = 0;
        closeVol = tradeVol;
    else % ��ָ����ղ�λͬ��
        closeVol = -lastPos;
        openVol = tradeVol - closeVol;
    end
else % ��ֻ����Ϊ0
    openVol = tradeVol;
    closeVol = 0;
end

Volume.open = openVol;
Volume.close = closeVol;
    
end

