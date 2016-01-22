function cateTrainTest = generate_cateTrainTest(traingnd, testgnd)
[n, ~ ] = size(traingnd);
[m, ~] = size(testgnd);
cateTrainTest = false(n, m);
for i =1:n
    for j = 1:m
        cateTrainTest(i,j) = traingnd(i) == testgnd(j);
    end
end
end