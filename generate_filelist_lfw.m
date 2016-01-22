lfw_path = 'C:\Users\Administrator\Documents\MATLAB\lfw\';
people_dir = dir(lfw_path);
[n_people, ~] = size(people_dir);
n_people_list = [];
people_name_list = cell(n_people-2,1);
for i=1:n_people
    if strcmp(people_dir(i).name, '.') || ...
            strcmp(people_dir(i).name, '..')
        disp(['skip dir ' people_dir(i).name]);
        continue;
    end
    single_people_path = [lfw_path people_dir(i).name ];
    single_people_dir = dir(single_people_path);
    [single_n_people, ~] = size(single_people_dir);
    n_people_list = [n_people_list ; single_n_people-2];
    people_name_list{i-2,1} = people_dir(i).name;
    disp([people_dir(i).name  ' ' num2str(single_n_people -2)]);
end

%% 12 people have more than 50 images
idx = n_people_list > 50;
people_name_sub = people_name_list(idx);

%% 
query_fid = fopen('query_filelist.txt','w');
gallery_fid =fopen('gallery_filelist.txt','w');

for i=1:n_people
    if strcmp(people_dir(i).name, '.') || ...
            strcmp(people_dir(i).name, '..')
        disp(['skip dir ' people_dir(i).name]);
        continue;
    end
    single_people_path = [lfw_path people_dir(i).name ];
    single_people_dir = dir(single_people_path);
    [single_n_people, ~] = size(single_people_dir);
    put_in_query = 10;
    for j=1:single_n_people
            if strcmp(single_people_dir(j).name, '.') || ...
                    strcmp(single_people_dir(j).name, '..')
                disp(['skip dir ' people_dir(j).name]);
                continue;
            end
            image_path = [single_people_path '\' single_people_dir(j).name ];
            if strincell(people_dir(i).name, people_name_sub) && put_in_query > 0
                fprintf(query_fid, '%s , %d\n', image_path, i-2);
                disp(['Put in query: ' image_path ]);
                put_in_query = put_in_query -1;
                continue;
            else
                 fprintf(gallery_fid, '%s , %d\n', image_path, i-2);
                 disp(['Put in gallery: ' image_path ]);
            end
            
    end

end
fclose(query_fid);
fclose(gallery_fid);