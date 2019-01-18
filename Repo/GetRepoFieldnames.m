function fileds = GetRepoFieldnames(DB,TypeChar)
%查找数据struct中TypeChar（2char）打头的品种名称表
fieldnames_ = fieldnames(DB);
idx = arrayfun(@(i) strcmp(fieldnames_{i}(1:2),TypeChar),1:length(fieldnames_));
fileds = fieldnames_(idx);
end