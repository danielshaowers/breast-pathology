function [m1, m2, m3, m4, m5, m6] =anno2maskParts(anno_name,tissue_name,top_layer_ind,mask_layer_ind)
%% This function is to convert the annotation xml file acquired from ASAP to a binary tumor mask 
 % In case of annotation from ImageScope, should replace getAnnotationsimp
 % function with getAnnotationcomp function 
 
%% input arguments:
% anno_name: annotation file name in xml format including the absolute file path

% tissue_name: name of the wsi including the absolute file path

% top_layer_ind: index of the layer where the annotation was performed (highest resolution layer normally)

% mask_layer_ind: index of layer whose magnification is applied to the  mask

%parts: how many different parts the mask should be split into
%% output arguments

% tumor_mask: binary mask of annotated tumor area
%%  Revision history
% First version: Haojia Li. 2019-10-22.


%%
img_inform=imfinfo(tissue_name);  
downsamp=img_inform(top_layer_ind).Width/img_inform(mask_layer_ind).Width;

anno=getAnnotationsimp(anno_name);
tumor_mask_width=floor(img_inform(mask_layer_ind).Width / 6);
tumor_mask_height=floor(img_inform(mask_layer_ind).Height / 6);
m1=zeros(tumor_mask_height,tumor_mask_width);
m2 = zeros(tumor_mask_height, tumor_mask_width);
m3 = zeros(tumor_mask_height, tumor_mask_width);
m4 = zeros(tumor_mask_height, tumor_mask_width);
m5 = zeros(tumor_mask_height, tumor_mask_width);
m6 = zeros(tumor_mask_height, tumor_mask_width);
segment = length(anno)/6;
for roi_ind=1:segment
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m1=xor(m1,mask);
end

for roi_ind=segment+1:2*segment 
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m2=xor(m2,mask);
end
for roi_ind=2*segment+1:3*segment
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m3=xor(m3,mask);
end
for roi_ind=3*segment+1:4*segment
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m4=xor(m4,mask);
end
for roi_ind=4*segment+1:5*segment
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m5=xor(m5,mask);
end
for roi_ind=5*segment+1:6*segment
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
m6=xor(m6,mask);
end

