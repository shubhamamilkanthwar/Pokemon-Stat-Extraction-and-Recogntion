function [ID, CP, HP, stardust, level, cir_center] = pokemon_stats (img, model)
% Please DO NOT change the interface
% INPUT: image; model(a struct that contains your classification model, detector, template, etc.)
% OUTPUT: ID(pokemon id, 1-201); level(the position(x,y) of the white dot in the semi circle); cir_center(the position(x,y) of the center of the semi circle)
% Replace these with your code 
% img = rgb2gray(img);
baseimg = img;
img = imresize(img, [1280,720]);

%HP DETECTION-------------------------------------------------------------
[baserows, col, numberOfColorChannels] = size(img);
HPimg= img+20;
HPimg = rgb2gray(HPimg);
HPimg = imadjust(HPimg, [0.4,1]);
hproi = [131.75 588 471 132];
ocrResults = ocr(HPimg,hproi);
recognizedText = ocrResults.Text;
hptext = recognizedText;
if(contains(hptext,"/"))
hptext = extractAfter(hptext,"/"); 
end
%code doen not work because OPR library thinks | = 1
if(contains(hptext,"|"))
hptext=extractAfter(hptext,"|");
end
hptext = strrep(hptext,"S","5");
hptext = strrep(hptext,"s","5");
hptext = strrep(hptext,"B","8");
hptext = strrep(hptext,"o","0");
hptext = strrep(hptext,"O","0");
hptext = regexprep(hptext,'[^0-9]','');
hptext=convertCharsToStrings(hptext);

%incases of lines 24-26 remove |
if(hptext == "1010")
hptext = 10;
end

%STARDUST DETECTION-----------------------------------------------------
STimg=img;
STimg = rgb2gray(STimg);
STimg = imadjust(STimg, [0.3,1]);
STimg = imsharpen(STimg, 'Amount', 1.2);
StarProi=[358.25 1008 106.5 73.5];%best result 
ocrResults = ocr(STimg,StarProi);
recognizedText = ocrResults.Text;
sttext = recognizedText;
sttext = erase(sttext,"0W");
sttext = strrep(sttext,"S","5");
sttext = strrep(sttext,"s","5");
sttext = strrep(sttext,"B","8");
sttext = strrep(sttext,"o","0");
sttext = strrep(sttext,"O","0");
sttext = regexprep(sttext,'[^0-9]','');
sttext = convertCharsToStrings(sttext);
%%%---CP---%%%-----------------------------------------------------------
cpimg = imresize(img,[1100,720]);
cpimg= cpimg - 20;
cpimg=imgaussfilt(cpimg);
cpimg=rgb2gray(cpimg);
cpimg=imadjust(cpimg,[0.7,0.9]);
cpimg=wiener2(cpimg,[5,5]);
cpimg=im2bw(cpimg);
cpimg=bwareaopen(cpimg,100);
roi2=[253.25 74.2499 205.5 70.5];
ocrResults = ocr(cpimg,roi2);
recognizedText = ocrResults.Text;    
cpText=erase(recognizedText,"cP");
cpText = strrep(cpText,"S","5");
cpText = strrep(cpText,"s","5");
cpText = strrep(cpText,"B","8");
cpText = strrep(cpText,"o","0");
cpText = strrep(cpText,"O","0");
cpText=regexprep(cpText,'[^0-9]','');
cpText=convertCharsToStrings(cpText);
%ID DETETION---------------------------------------------------------------
% load('model.mat','feat_train','label_train');
feat_train = model.feat_train;
label_train = model.label_train;
imgID = rgb2gray(img);
imgID = imcrop(imgID,[7.25 212.25 702 280.5]);
lbpFeatures = extractLBPFeatures(imgID,'CellSize',[64 64],'Interpolation','Nearest');
numBins = 10;
lbpCellHists = reshape(lbpFeatures,numBins,[]);
lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists));
lbpFeatures = reshape(lbpCellHists,1,[]);
feat = lbpFeatures;
X=feat;
Z= feat_train;
L = label_train;
Mdl = fitcknn(Z,L);
predict_label= predict(Mdl,X);                                                                  
% %Circle_Center------------------------------------------------------------------------
cenimg = baseimg;
[rows, columns, numberOfColorChannels] = size(cenimg);
cenimg = imcrop(cenimg, [1, 1, columns, floor(rows/2)]);
cenimg = rgb2gray(cenimg);
cenimg= cenimg-65;
cenimg = imadjust(cenimg, [.1,.8]);
cenimg = im2bw(cenimg);
[centers, radii] = imfindcircles(cenimg,[225 650], 'Sensitivity', .99, 'EdgeThreshold', .75);
[r,c] = size(centers);
if(c > 0)
centersStrong1 = centers(1,:); 
radiiStrong1 = radii(1:1);
cir_cen1=centersStrong1(1);
cir_cen2=centersStrong1(2);
else
[rows,columns] = size(cenimg);
cir_cen1 = (rows+20) / 2;
cir_cen2 = (columns-5) / 2;
centersStrong1 =[cir_cen1,cir_cen2]; 
radiiStrong1 = 0;
end

%Level----------------------------------------------------------------- 
[baserows, basecolumns, numberOfColorChannels] = size(baseimg);
halfimg = imcrop(baseimg, [1, 1, basecolumns, floor(baserows/2)]);
[rows, col, numberOfColorChannels] = size(halfimg);
imglevel= insertShape(baseimg,'FilledCircle',[(rows+50)/2 (col+50)/2 (rows*2)/6],'Color','black','Opacity',1);
rect=[0 , 0 , col*1 , rows*.205];
rect2= [0 , rows*.73,col*1 , baserows];  
imglevel= insertShape(imglevel,'FilledRectangle',rect,'Color','black','Opacity',1);
imglevel= insertShape(imglevel,'FilledRectangle',rect2,'Color','black','Opacity',1);
imglevel=rgb2gray(imglevel);
imglevel = imglevel>225;
imshow(imglevel);hold on;
[centers, radii] = imfindcircles(imglevel,[5 15], 'Sensitivity', 0.95, 'EdgeThreshold', 0.90,'ObjectPolarity','bright');
viscircles(centers,radii,'EdgeColor','b');
[r,c] = size(centers);
if(c > 0)
centersStrong2 = centers(1,:); 
lvl1 = centersStrong2(1);
lvl2= centersStrong2(2);
else
lvl1= 0;
lvl2=0;
end
%Results--------------------------------------------------------------
ID = predict_label;
CP = cpText;
HP = hptext;
stardust = sttext;
level = [lvl1 lvl2];
cir_center = [cir_cen1 cir_cen2];

end
