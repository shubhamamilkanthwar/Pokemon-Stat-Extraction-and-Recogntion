% Feel free changing any thing in this script except the interface of
% pokemon_stats and the name of "model.mat". The final test script will be
% almost the same as this. The only thing you need to submit is
% pokemon_stats.m and model.mat.
clear; clc; close all;
% model = 'a';
% save('model.mat','model')
img_path = './train/';
img_dir = dir([img_path,'*CP*']);
img_num = length(img_dir);
ID_gt = zeros(img_num,1);
CP_gt = zeros(img_num,1);
HP_gt = zeros(img_num,1);
stardust_gt = zeros(img_num,1);
ID = zeros(img_num,1);
CP = zeros(img_num,1);
HP = zeros(img_num,1);
stardust = zeros(img_num,1);

for i = 1:img_num
% for i = 11
    close all;
    
    img = imread([img_path,img_dir(i).name]);
    
    % get ground truth annotation from image name
    name = img_dir(i).name;
    ul_idx = findstr(name,'_'); 
    ID_gt(i) = str2num(name(1:ul_idx(1)-1));
     label_train(i,:) = ID_gt(i);
    feat_train(i,:) = feature_extraction(img);
     
   
    imshow(img); hold on;
%     plot(level(1),level(2),'b*');
%     plot(cir_center(1),cir_center(2),'g^');
    
end

save('model.mat','label_train','feat_train');