addpath(genpath('D:\Pathology'));
xml_path = 'D:\AI_Lab\Repo\ECOG_Breast\1000698.xml';
svs_path = 'D:\AI_Lab\Repo\ECOG_Breast\1000.svs';
[~, baseFileName, image_format] = fileparts(xml_path); 
%baseName = sprintf('annotated_%s%s',baseFileName, image_format);
baseName = sprintf('annotated_%s.png',baseFileName);
annotation_coordinate = getAnnotationsimp(xml_path);
%we use a single value, the min of the annotation coordinate to get square
tissue_patch=imread(svs_path,'PixelRegion', {[max(annotation_coordinate(1).Y) - 2047, (max(annotation_coordinate(1).Y))],[max(annotation_coordinate(1).X) - 2047, (max(annotation_coordinate(1).X))]});
fullFileName = fullfile('D:\AI_Lab\Images', baseName);
imshow(tissue_patch)
imwrite(tissue_patch, fullFileName); %saves the annotated image with name "annotated_wsi_name" to my external drive's image folder
strSavePath = 'D:\AI_Lab\Images';
%strPathIM = 'Z:\2017-05-16_01'; %folder storing all svs images
strPathIM = sprintf('D:\\AI_Lab\\Images\\');
strEpiStrMaskPath = 'Z:\2017-05-16_01'; %should point to mask path, but i don't know where that is
LcreateFolder(strSavePath);
flag_nuclei_cluster_finding = 0;
%image_format = '.xml';567
para_nuclei_scale_low  = 8; %smallest pixels of a nucleus
para_nuclei_scale_high = 18;
flag_have_nuclei_mask = 0; %1 if true
flag_epistroma = 0; %flags are either 0 or 1
dbstop if error
idx = 1;
Lextractfeature_v17(idx, idx, svs_path, flag_epistroma, strPathIM, strSavePath, strEpiStrMaskPath, strEpiStrMaskPath, flag_have_nuclei_mask, flag_nuclei_cluster_finding,...
    image_format, 0, 0, 1, 0, para_nuclei_scale_low, para_nuclei_scale_high); %epistr and nuclei mask paths don't matter here because I set the flags to 0 for now

