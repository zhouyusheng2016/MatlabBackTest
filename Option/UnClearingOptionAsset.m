function [ Asset ] = UnClearingOptionAsset(Asset,I)
% �������������ڻ���ʱΪ�˻�ȡƽ�ֺ��˻���Ϣ�������Clearing֮��
% �����������Clearing������Ӱ��

% deal�ֶ�
Asset.DealStock{I} = [];
Asset.DealVolume{I} = [];
Asset.DealPrice{I} = [];
Asset.DealFee{I} = [];
% �����ֶ�
Asset.Cash(I) = 0;
Asset.FrozenCash(I) = 0;
Asset.Stock{I} = [];
Asset.Position{I} = [];
Asset.Margins{I} = []; 
Asset.MarginStock{I} = [];
end

