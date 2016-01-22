function ret = strincell(str, cell_set)
    [n,~] = size(cell_set);
    ret = 0;
    for i = 1:n
        ret = ret || strcmp(str, cell_set{i});
    end
end