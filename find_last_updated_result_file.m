function [last_filename, last_iter ]= find_last_updated_result_file(res_path,nbits, hammRadius)
results = dir(res_path);
[n,~] = size(results);
last_filename = [];
last_iter = 0;
for i = 1:n
    if strcmp(results(i).name, '.')|| strcmp(results(i).name, '..')
        continue;
    end
    filename = results(i).name;
    strs1 = strsplit(filename, '.');
    strs2 = strsplit(strs1{1,1}, '_');
    tmp_nbits = str2double(strs2{1,4});
    tmp_hammR = str2double(strs2{1,7});
    tmp_iter = str2double(strs2{1,9});
    if tmp_nbits == nbits && tmp_hammR == hammRadius && tmp_iter > last_iter
        last_filename = filename;
        last_iter = tmp_iter;
    end
end
end