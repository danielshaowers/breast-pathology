function tumor_mask=anno2mask(anno_name,tissue_name,top_layer_ind,mask_layer_ind)
%% This function is to convert the annotation xml file acquired from ASAP to a binary tumor mask 
 % In case of annotation from ImageScope, should replace getAnnotationsimp
 % function with getAnnotationcomp function 
 
%% input arguments:
% anno_name: annotation file name in xml format including the absolute file path

% tissue_name: name of the wsi including the absolute file path

% top_layer_ind: index of the layer where the annotation was performed (highest resolution layer normally)

% mask_layer_ind: index of layer whose magnification is applied to the  mask

%% output arguments

% tumor_mask: binary mask of annotated tumor area
%%  Revision history
% First version: Haojia Li. 2019-10-22.


%%
img_inform=imfinfo(tissue_name);  
downsamp=img_inform(top_layer_ind).Width/img_inform(mask_layer_ind).Width;

anno=getAnnotationsimp(anno_name);
tumor_mask_width=img_inform(mask_layer_ind).Width;
tumor_mask_height=img_inform(mask_layer_ind).Height;
tumor_mask=zeros(tumor_mask_height,tumor_mask_width);
for roi_ind=1:length(anno)
mask=poly2mask(anno(roi_ind).X/downsamp,anno(roi_ind).Y/downsamp,tumor_mask_height,tumor_mask_width);
tumor_mask=xor(tumor_mask,mask);
end

