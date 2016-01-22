function normalized = normalize_matrix_by_row(unormalized)
[~, m] = size(unormalized);
unormalized_squared = unormalized .^ 2;
unormalized_squared_row_sum = sum(unormalized_squared, 2);
unormalized_squared_row_sum_sqrt = sqrt(unormalized_squared_row_sum);
normalized = unormalized ./ (unormalized_squared_row_sum_sqrt * ones(1, m));
end