function mPrecision= topNprecision(traingnd,testgnd,HammingRank, N)
[n,~] = size(testgnd);
precision = zeros(n,1);
for i=1:n
    temp = HammingRank(1:N, i);
    topNgnd = traingnd(temp);
    precision(i) = sum(topNgnd == testgnd(i))/N;
end
mPrecision = mean(precision);
end