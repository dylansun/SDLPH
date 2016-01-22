clc;clear;
gmap.lambda = 1; 
gmap.loss = 'L2';
Fmap.nu = 1e-5; %  penalty parm for F term
Fmap.lambda = 1e-2;
for i = 1:20
eval_deep_SDH(gmap, Fmap, 1, 8,2,  [10 20]);
eval_deep_SDH(gmap, Fmap, 1, 16,2,  [10 20]);
eval_deep_SDH(gmap, Fmap, 1, 32,2,  [10 20]);
eval_deep_SDH(gmap, Fmap, 1, 64,2,  [10 20]);
eval_deep_SDH(gmap, Fmap, 1, 128,2,  [10 20]);
end