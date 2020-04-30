%extract the features of a single image
function extractFeat_single_simple(svs_filename, xml_filename, errorFile) %wsi is the svs file of the imaage
%cd ..
path = 'C:/Users/danie/OneDrive/Desktop/Pathology';
path = '/home/dxs765';
path = pwd;
errorFile = fopen('errors.txt', 'w');
addpath(genpath(sprintf('%s/Current_Project', path)));
addpath(genpath(sprintf('%s/Feature_Extraction', path)));
addpath(genpath(sprintf('%s/First_Project/Code', path)));
addpath(genpath(sprintf('%s/ChengCode', path)));
addpath(sprintf('%s/ChengCode/Utilities-master', path));
%img = sprintf('%d', list(x));
%imgPath = ('/mnt/rstor/CSE_BME_AXM788/data/ECOG_Breast/2017-05-16_01/');

%% COMMENTED OUT TO MAKE FUNCTION
%svs_filename = sprintf('%s.svs', img);
%xml_filename = sprintf('%s.xml', img);

[imgPath, baseName, ~] = fileparts(svs_filename);
addpath(genpath(imgPath));
%addpath('D:\AI_Lab\Repo\ECOG_Breast'); not needed for hpc
%addpath(genpath('D:\AI_Lab\Relevant_Matlab\'));
%cd scratch_dir;

%xml_filename = sprintf('%s.xml', baseName);
writePath = sprintf('%s/Images/%s/',path, baseName);
fullPath = sprintf('%sfull/', writePath); %path of the full tumor to visualize what patches are extracted
LcreateFolder(writePath);
LcreateFolder(fullPath);
inFileInfo=imfinfo(svs_filename); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
inFileInfo=inFileInfo(1);
height = inFileInfo.Height; %pixels high of orig image
width = inFileInfo.Width;
numQueries = 5; %number of random points to select, per patch found. might want to change to total
xml_page = 5; %page# of the magnification we're using
tumor_mask = anno2mask(xml_filename, svs_filename, 1, xml_page);
outlined_image = saveTumorMask(imread(svs_filename,'Index', xml_page), tumor_mask, sprintf('%sfull', fullPath));

[height_mask, width_mask] = size(tumor_mask);
hRatio = height / height_mask;
wRatio = width / width_mask; %factor of magnification difference
avgResize = (hRatio + wRatio) / 2;

%% randomly select patches to extract
%[qPoints,failedAttempts] = selectRandPoints(tumor_mask, numQueries, round(2048 / avgResize), [height_mask, width_mask]); %qPoints are the coordinates on the smaller tumor mask.
[qPoints,failedAttempts] = selectPoints(tumor_mask, numQueries, round(2048 / avgResize), [height_mask, width_mask]); %qPoints are the coordinates on the smaller tumor mask.
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
%path of image, then path of save
end
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
