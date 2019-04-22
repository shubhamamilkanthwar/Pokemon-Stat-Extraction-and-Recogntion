function feat = feature_extraction(img)
% Output should be a fixed length vector [1*dimension] for a single image. 
% Please do NOT change the interface.
% load('categoryClassifier');
% s=categoryClassifier;
img = imresize(img, [1280,720]);
img = rgb2gray(img);
img = imcrop(img,[7.25 212.25 702 280.5]);
lbpFeatures = extractLBPFeatures(img,'CellSize',[64 64],'Interpolation','Nearest');
% numNeighbors = 10;
% numBins = numNeighbors*(numNeighbors-1);
numBins = 10;
lbpCellHists = reshape(lbpFeatures,numBins,[]);
lbpCellHists = bsxfun(@rdivide,lbpCellHists,sum(lbpCellHists));
lbpFeatures = reshape(lbpCellHists,1,[]);
feat = lbpFeatures;


  
