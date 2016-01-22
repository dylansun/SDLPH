clc;clear;
load('lfw_vgg.mat');
%% extract feature by line 
query_fid = fopen('query_filelist.txt','r');
query_label = [];

while ~feof(query_fid)
    line = fgetl(query_fid);
    disp(['Processing Line : ' line]);
    line_split = strsplit(line, ',');
    people_id = str2double(line_split{1,2});
    query_label = [query_label; people_id];
end


%% extract feature by line 
gallery_fid = fopen('gallery_filelist.txt','r');
gallery_label = [];

while ~feof(gallery_fid)
    line = fgetl(gallery_fid);
    disp(['Processing Line : ' line]);
    line_split = strsplit(line, ',');
    people_id = str2double(line_split{1,2});
    gallery_label = [gallery_label; people_id];
end


%% save to mat file
fclose(query_fid);
fclose(gallery_fid);
save('lfw_vgg_updated.mat', 'query_data','query_label','gallery_data','gallery_label');