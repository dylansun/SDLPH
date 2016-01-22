clc;clear;
load('lfw_vgg_updated');
query_data = normalize_matrix_by_row(query_data);
gallery_data = normalize_matrix_by_row(gallery_data);
QG = query_data * gallery_data';
%% for each row find the max 10 elements index
[m,n] = size(QG);
topN = 10;
precsionAtTopN = zeros(m,1);
for i = 1:m
    k = QG(i,:);
    [ii, iii] = sort(k);
    precsionAtTopN(i) = sum(query_label(i) == gallery_label(iii((end-topN+1):end))) / topN;
end

mean(precsionAtTopN)