%% initialize matconvnet
matconvnet_path = 'C:\Users\Administrator\Documents\MATLAB\matconvnet_test\matconvnet-1.0-beta17\';
initial_setupnn =  [matconvnet_path 'matlab\vl_setupnn.m'];
run(initial_setupnn)
modelPath =[matconvnet_path  'data/models/vgg-face.mat'];
net = load(modelPath) ;

%% extract feature by line 
fid = fopen('filelist.txt','r');
data = [];
label = [];
linecount = 0;
%% if exist temp file, load and skip 
if exist('lfw_vgg_0.mat','file')
    load('lfw_vgg_0.mat')
    [n_skip,~] = size(data);
    linecount = linecount + n_skip;
    for n_skiped = 1:n_skip
        s = fgetl(fid);
    end
    disp(['skip ' num2str(n_skip) ' lines']);
end

while ~feof(fid)
    line = fgetl(fid);
    linecount = linecount + 1;
    disp(['Processing Line : ' line]);
    tic;
    line_split = strsplit(line, ',');
    filename = line_split{1,1};
    people_id = uint8(str2double(line_split{1,2}));
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
    data = [data; fea];
    label = [label; people_id];
    toc;
    
     if mod(linecount, 100)==0
        tempfilename = [ 'lfw_vgg_' num2str(mod(linecount,100)) '.mat'];
        save(tempfilename, 'data', 'label');
    end

end

%% save to mat file
fclose(fid);
save('lfw_vgg.mat', 'data','label');