function [tumor_mask, qPoints] = writeTumorMask(svs_filename, xml_filename, queryPoints, writePath, xmlPage)
%% finds the tumor mask at a lower magnification (page 5 of xml file), and returns randomly selected points in the tumor
%queryPoints = number of randomly selected points to use

%%find tumor mask. I don't know how to resize a binary mask. 
tumor_mask = anno2mask(xml_filename, svs_filename, 1, 5);
qPoints = selectRandPoints(tumor_mask, queryPoints);
[~,imageName, ~] = fileparts(svs_filename);

im_snap=imread(svs_filename,5); figure; imwrite(im_snap, sprintf('%s/%s.png', writePath, imageName));
im_snap_rz=imresize(im_snap,[size(tumor_mask,1),size(tumor_mask,2)]); %sets the rows/cols to the rows and cols of the mask

end
% inFileInfo=imfinfo(svs_filename); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
% inFileInfo=inFileInfo(5); %imfinfo returns a struct for each individual page, we again select the page we're interested in
% wsi_height = inFileInfo.Height; %pixels high of orig image
% wsi_width = inFileInfo.Width;
%% finds the new magnification of the tumor mask
% heightReduction = maskRows/wsi_height;
% widthReduction = maskCols/wsi_width; %this is the distance between pixels in each element of the tumor mask at the original size
% numBlocks = max(ceil(wsi_height/block_dimensions(1)), ceil(wsi_width/block_dimensions(2)));
% blockHeight = maskRows / numBlocks;
% blockWidth = maskCols / numBlocks;
% %mask_added = blkwrite_tumor_mask(svs_filename, block_dimensions, (heightReduction + widthReduction)/2);
%% make an outline of tumor based on Annotationsimp
% annotation_coordinate = getAnnotationsimp(xml_filename);
% numCols = size(annotation_coordinate(1).X);
% numRows = size(annotation_coordinate(1).Y); 
% scaled_ac_y = zeros(numRows);
% scaled_ac_x = zeros(numCols);
% for idx = 1: numRows
%    scaled_ac_y(idx) = annotation_coordinate(1).Y(idx) * heightReduction;
%    scaled_ac_x(idx) = annotation_coordinate(1).X(idx) * widthReduction;
% end
% A = zeros(numRows + numCols);
% for index = 1:numRows %numRows should = numCols 
%     A(2*index - 1) = scaled_ac_x(index);
%     A(2*index) = scaled_ac_y(index);
% end
% B = A.';
% mask_added = insertShape(mask_added, 'Polygon', B(1,:), 'LineWidth', 10, 'Color', 'green');
% %yBounds = annotation_coordinate(2).Y; %ohh if this is actual X then this corresponds to rows, not columns
% imwrite(mask_added, 'D:\AI_Lab\Images\1000698_4.png');
% %%paint pixels yellow within the tumor mask
% size(mask_added)
% [rows,cols,~] = size(mask_added); %retrieves number of pixels per row and column. what is the size?
% for col = 1:maskCols
%     for row = 1:maskRows      
%         if tumor_mask(row,col)
%             mask_added(row, col, 1) = 255;          
%             mask_added(row, col, 2) = 255; 
%             mask_added(row, col, 3) = 0; 
%         end
%     end
% 
% 
% end