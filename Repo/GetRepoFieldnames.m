function fileds = GetRepoFieldnames(DB,TypeChar)
%��������struct��TypeChar��2char����ͷ��Ʒ�����Ʊ�
fieldnames_ = fieldnames(DB);
idx = arrayfun(@(i) strcmp(fieldnames_{i}(1:2),TypeChar),1:length(fieldnames_));
fileds = fieldnames_(idx);
end