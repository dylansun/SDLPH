function eval_deep_SDH(gmap, Fmap, maxItr, nbits,hammRadius,  topN, debug)
% ---------- Argument defaults ----------
if ~exist('nbits','var') || isempty(nbits)
    nbits=8;
end
if ~exist('hammRadius','var') || isempty(hammRadius)
    hammRadius=2;
end
if ~exist('topN','var') || isempty(topN)
    topN=[10 20];
end

if ~exist('debug','var') || isempty(debug)
    debug=1;
end


addpath 'C:\Users\Administrator\Documents\MATLAB\liblinear-2.1/windows/'  % for hinge loss
%%  prepare_dataset(dataset);
load('data\lfw_vgg_updated');
[last_file, last_iter] = find_last_updated_result_file('result',nbits, hammRadius);

%traindata = normalize_matrix_by_row(gallery_data);
traindata = gallery_data;
traingnd = gallery_label;

%testdata = normalize_matrix_by_row(query_data);
testdata = query_data;
testgnd = query_label;

if sum(traingnd == 0) % if index from 0
    traingnd = traingnd + 1;
    testgnd = testgnd + 1;
end   

cateTrainTest = generate_cateTrainTest(traingnd , testgnd);

Ntrain = size(traindata,1);
Ntest = size(testdata, 1);
%% Use all the training data
label = double(traingnd);
X = [traindata, ones(Ntrain,1)];
Y = [testdata, ones(Ntest, 1)];

% learn G and F
% gmap.lambda = 1; 
% gmap.loss = 'L2';
% Fmap.nu = 1e-5; %  penalty parm for F term
% Fmap.lambda = 1e-2;

%% run supervised discrete hashing
% Init Z
randn('seed',3);
B_init=sign(randn(Ntrain,nbits));
if  ~isempty(last_file) && exist(['result\' last_file], 'file')
    disp(['Loading History Result: result\' last_file] );
    B_init = load(['result\' last_file], 'B_init');
    B_init = B_init.B_init;
end
tic;
[~, F, H, error] = SDH(X,label,B_init,gmap,Fmap,[],maxItr,debug);
toc;
B_init = H;
%% evaluation
display('Evaluation...');
AsymDist = 0; % Use asymmetric hashing or not
if AsymDist 
    H = H > 0; % directly use the learned bits for training data
else
    H = X*F.W > 0;
end
tH = Y*F.W > 0;
B = compactbit(H);
tB = compactbit(tH);
hammTrainTest = hammingDist(tB, B)';
%%  hash lookup: precision and reall
Ret = (hammTrainTest <= hammRadius+0.00001);
[Pre, Rec, precisions, recalls] = evaluate_macro(cateTrainTest, Ret);

% hamming ranking: MAP
[~, HammingRank]=sort(hammTrainTest,1);
MAP = cat_apcal(traingnd,testgnd,HammingRank);
mPrecision = [];
for i = 1:length(topN)
    mPrecision = [mPrecision topNprecision(traingnd,testgnd,HammingRank, topN(i))];
end

%% save result

result_file = ['result/deep_sdh_result_' num2str(nbits) '_bits_r_' num2str(hammRadius) '_iter_' num2str(last_iter + maxItr) '.mat'];
save(result_file, 'mPrecision', 'MAP', 'B','tB', 'hammTrainTest', 'Pre','Rec', 'precisions', 'recalls', 'B_init', 'error');
end