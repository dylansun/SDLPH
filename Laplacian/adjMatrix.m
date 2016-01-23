function [A,D,L  ]= adjMatrix(label)
[n, ~ ] = size(label);
A = false(n, n);
for i =1:n
    for j = 1:n
        A (i,j) = (label(i) == label(j) && i~=j);
    end
end
A = sparse(logical(A));
D = diag(sum(A));
L = D - A;
end