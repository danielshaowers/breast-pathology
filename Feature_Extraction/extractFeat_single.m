%extract the features of a single image
function extractFeat_single(svs_filename, xml_filename, errorFile) %wsi is the svs file of the imaage
%%try
[imgPath, baseName, ~] = fileparts(svs_filename);
addpath(genpath(imgPath));
%addpath('D:\AI_Lab\Repo\ECOG_Breast'); not needed for hpc
%addpath(genpath('D:\AI_Lab\Relevant_Matlab\'));
%cd scratch_dir;

%xml_filename = sprintf('%s.xml', baseName);
writePath = sprintf('%s/Images/%s/',pwd, baseName);
fullPath = sprintf('%sfull/', writePath); %path of the full tumor to visualize what patches are extracted
LcreateFolder(writePath);
LcreateFolder(fullPath);
disp('opening svs file');
inFileInfo=imfinfo(svs_filename);
inFileInfo=inFileInfo(1);
height = inFileInfo.Height; %pixels of full image
width = inFileInfo.Width;
numQueries = 5; %number of random points to select, per patch found. might want to change to total
xml_page = 5; %page# of the magnification we're using
tumor_mask = anno2mask(xml_filename, svs_filename, 1, xml_page);
disp('saving tumor mask outline with saveTumorMask');
outlined_image = saveTumorMask(imread(svs_filename,'Index', xml_page), tumor_mask, sprintf('%sfull', fullPath));

[height_mask, width_mask] = size(tumor_mask);
hRatio = height / height_mask;
wRatio = width / width_mask; %factor of magnification difference
avgResize = (hRatio + wRatio) / 2;

%% randomly select patches to extract
disp('selecting random points');
[qPoints,~] = selectRandPoints(tumor_mask, numQueries, round(2048 / avgResize), [height_mask, width_mask]); %qPoints are the coordinates on the smaller tumor mask.
for idx = 1: size(qPoints, 1) %for some reason this is giving me 0,0
    outlined_image = insertShape(outlined_image, 'Rectangle', ([qPoints(idx,2), qPoints(idx,1), 2047/avgResize,...
        2047/avgResize]), 'LineWidth', 10, 'Color', 'green');
end
qPoints = [round(qPoints(:,1) .* avgResize), round(qPoints(:,2) .* avgResize)]; %convert back to size of WSI
for idx = 1: size(qPoints, 1)
  A = imread(svs_filename, 'PixelRegion', {[qPoints(idx,1), qPoints(idx,1) + 2047],[qPoints(idx,2), qPoints(idx,2) + 2047]});
    imwrite(A, sprintf('%s/%s_%d_%d.png', writePath, baseName, qPoints(idx,1), qPoints(idx,2)));
end %I may want feature extract included, depending on whether it reads all images in the file or just the one i specify

imwrite(outlined_image, sprintf('%sallRegions.png', fullPath));
defaultFeatureExtract(sprintf('%s', writePath), writePath, errorFile);

% [qPoints] = selectRandPoints(tumor_mask, numQueries, round(2048 / avgResize)); %qPoints are the coordinates on the smaller tumor mask.
% if size(qPoints) == 0
%     warning('unable to find points within tumor. Check tumor outline');
%     return;
% end
% for idx = 1: size(qPoints, 1)
%     outlined_image = insertShape(outlined_image, 'Rectangle', ([qPoints(idx,2), qPoints(idx,1), 2047/avgResize,...
%         2047/avgResize]), 'LineWidth', 10, 'Color', 'green');
% end
% qPoints = [round(qPoints(:,1) .* avgResize), round(qPoints(:,2) .* avgResize)]; %convert back to size of WSI
% for idx = 1: size(qPoints, 1)
%   A = imread(svs_filename, 'PixelRegion', {[qPoints(idx,1), qPoints(idx,1) + 2047],[qPoints(idx,2), qPoints(idx,2) + 2047]});
%     imwrite(A, sprintf('%s/%s_%d_%d.png', writePath, baseName, qPoints(idx,1), qPoints(idx,2)));
% end 
disp('extracting feature with defaultFeatureExtract');
imwrite(outlined_image, sprintf('%sallRegions.png', fullPath));
defaultFeatureExtract(sprintf('%s', writePath), writePath, errorFile);
%path of image, then path of save
% catch ME
%     errorMessage = sprintf('Problem in extractFeat_single. \n%s', ME.message);
%     warning(errorMessage);
%     fprintf(errorFile, errorMessage);
%     return;
% end
%% code for if I want to analyze ever block of every image
% imgFolder = 'D:\AI_Lab\Images4\'; %the folder that each image should be in
% LcreateFolder(imgFolder);
% imagesAlreadyClipped = 0; 
% if imagesAlreadyClipped == 0
%     tumor = getOutline_v2(wsi, imgFolder, block_dimensions, annotation_coordinate(1).X, annotation_coordinate(1).Y);
% end
% [~,baseFileName,~] = fileparts(wsi);
% inFileInfo=imfinfo(wsi); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
% inFileInfo=inFileInfo(1);
% height = inFileInfo.Height; %pixels high of orig image
% width = inFileInfo.Width;
% %% keep this commented out if it turns out we do automatically analyze everything
% % for x = 1:block_dimensions(1):height
% %     for y = 1:block_dimensions(2):width
% %         if inpolygon(x, y, annotation_coordinate(1).X, annotation_coordinate(1).Y)
% try
%     defaultFeatureExtract(sprintf('%s%s_%d_%d.png', imgFolder, baseFileName), imgFolder); 
% catch
% end
%         end
%     end
% end
