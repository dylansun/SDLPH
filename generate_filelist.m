lfw_path = 'C:\Users\Administrator\Documents\MATLAB\aligned_images_DB';
people_dir = dir(lfw_path);
[n, ~] = size(people_dir);
n_people = 0;
fid = fopen('filelist.txt','w');
%% 
for i = 1:n
    %% skip '.' and '..'
    if strcmp(people_dir(i).name, '.') || strcmp(people_dir(i).name, '..')
        disp('skip directory ''." or ".."');
        continue;
    end
    single_people_path = [lfw_path '\' people_dir(i).name];
    single_people_dir = dir(single_people_path);
    [m,~] = size(single_people_dir);
    for j = 1:m
        if strcmp(single_people_dir(j).name, '.')  ...
        || strcmp(single_people_dir(j).name, '..')
            disp('skip layer 2 directory ''." or ".."');
            continue;
        end
        %% loop in people dir
        single_people_sub_path = [single_people_path '\' ...
            single_people_dir(j).name '\'  ];
        single_people_sub_dir = dir(single_people_sub_path);
        [l, ~] = size(single_people_sub_dir);
        for k=1:l
            if strcmp(single_people_sub_dir(k).name, '.')  ...
        || strcmp(single_people_sub_dir(k).name, '..')
                disp('skip single people sub directory ''." or ".."');
                continue
            end
            single_people_sub_image_path = [single_people_sub_path ...
                single_people_sub_dir(k).name];
            single_people_sub_image_dir = dir(single_people_sub_image_path);
            [Q,~] = size(single_people_sub_image_dir);
            for q = 1:Q
                   if strcmp(single_people_sub_image_dir(q).name, '.')  ...
        || strcmp(single_people_sub_image_dir(q).name, '..')
                disp('skip single people sub directory ''." or ".."');
                continue
                   end
                % image_path = [single_people_sub_image_path '\' ...
                %  single_people_sub_image_dir(q).name];
                image_path = single_people_sub_image_path;
                disp(image_path);
                disp(['People ID: ' num2str(n_people)]);
                fprintf(fid, '%s , %d\n', image_path, n_people);
            end
        end
    end
    n_people = n_people + 1;
end
fclose(fid);