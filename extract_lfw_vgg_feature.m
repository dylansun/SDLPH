clc;clear;
%% initialize matconvnet
matconvnet_path = 'C:\Users\Administrator\Documents\MATLAB\matconvnet_test\matconvnet-1.0-beta17\';
initial_setupnn =  [matconvnet_path 'matlab\vl_setupnn.m'];
run(initial_setupnn)
modelPath =[matconvnet_path  'data/models/vgg-face.mat'];
net = load(modelPath) ;

%% extract feature by line 
query_fid = fopen('query_filelist.txt','r');
query_data = [];
query_label = [];
query_linecount = 0;
%% if exist temp file, load and skip 
if exist('query_lfw_vgg_0.mat','file')
    load('query_lfw_vgg_0.mat')
    [n_skip,~] = size(query_data);
    query_linecount = query_linecount + n_skip;
    for n_skiped = 1:n_skip
        s = fgetl(query_fid);
    end
    disp(['skip ' num2str(n_skip) ' lines']);
end

while ~feof(query_fid)
    line = fgetl(query_fid);
    query_linecount = query_linecount + 1;
    disp(['Processing Line : ' line]);
    tic;
    line_split = strsplit(line, ',');
    filename = line_split{1,1};
    people_id = str2double(line_split{1,2});
    im = imread(filename) ;
    [h,w,d] = size(im);
    if h > 250
        im = im(1:250,:,:) ; % crop
    end
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ;
    res = vl_simplenn(net, im_) ;
    fea = reshape(res(36).x, 1, 4096);
    toc;
    
    tic;
    query_data = [query_data; fea];
    query_label = [query_label; people_id];
    toc;
    
     if mod(query_linecount, 10)==0
        tempfilename = [ 'query_lfw_vgg_' num2str(mod(query_linecount,10)) '.mat'];
        save(tempfilename, 'query_data', 'query_label');
    end

end


%% extract feature by line 
gallery_fid = fopen('gallery_filelist.txt','r');
gallery_data = [];
gallery_label = [];
gallery_linecount = 0;
%% if exist temp file, load and skip 
if exist('gallery_lfw_vgg_0.mat','file')
    load('gallery_lfw_vgg_0.mat')
    [n_skip,~] = size(gallery_data);
    gallery_linecount = gallery_linecount + n_skip;
    for n_skiped = 1:n_skip
        s = fgetl(gallery_fid);
    end
    disp(['skip ' num2str(n_skip) ' lines']);
end

while ~feof(gallery_fid)
    line = fgetl(gallery_fid);
    gallery_linecount = gallery_linecount + 1;
    disp(['Processing Line : ' line]);
    tic;
    line_split = strsplit(line, ',');
    filename = line_split{1,1};
    people_id = str2double(line_split{1,2});
    im = imread(filename) ;
    [h,w,d] = size(im);
    if h > 250
        im = im(1:250,:,:) ; % crop
    end
    im_ = single(im) ; % note: 255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
    im_ = bsxfun(@minus,im_,net.meta.normalization.averageImage) ;
    res = vl_simplenn(net, im_) ;
    fea = reshape(res(36).x, 1, 4096);
    toc;
    
    tic;
    gallery_data = [gallery_data; fea];
    gallery_label = [gallery_label; people_id];
    toc;
    
     if mod(gallery_linecount, 100)==0
        tempfilename = [ 'gallery_lfw_vgg_' num2str(mod(gallery_linecount,100)) '.mat'];
        save(tempfilename, 'gallery_data', 'gallery_label');
    end

end


%% save to mat file
fclose(query_fid);
fclose(gallery_fid);
save('lfw_vgg.mat', 'query_data','query_label','gallery_data','gallery_label');