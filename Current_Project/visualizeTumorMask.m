function outlined_image = visualizeTumorMask(svs_filename, xml_filename, resize_amt, graph_dimensions)

inFileInfo=imfinfo(svs_filename); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
inFileInfo=inFileInfo(1); %imfinfo returns a struct for each individual page, we again select the page we're interested in
wsi_height = inFileInfo.Height; %pixels high of orig image
wsi_width = inFileInfo.Width;

%more dimensions increases accuracy 
block_dimensions = [10000, 10000]; %larger blocks = faster processing
%small_image = getOutlineSimple(svs_filename, block_dimensions, 1, resize_amt);

annotation_coordinate = getAnnotationsimp(xml_filename);
numCols = size(annotation_coordinate(1).X);
numRows = size(annotation_coordinate(1).Y); 

scaled_ac_x = annotation_coordinate(1).X .* resize_amt;
scaled_ac_y = annotation_coordinate(1).Y .* resize_amt;

A = zeros(numRows + numCols); %makes a single vector with alternating rows and columns
for index = 1:numRows %numRows should = numCols 
    A(2*index - 1) = scaled_ac_x(index);
    A(2*index) = scaled_ac_y(index);
end
B = A.';

outlined_image = insertShape(mask_shape, 'Polygon', B(1,:), 'LineWidth', 10, 'Color', 'yellow');
%%find tumor mask. This is no
tumor_mask = anno2mask(xml_filename, svs_filename, 1, 2);
[maskRows, maskCols] = size(tumor_mask);
heightReduction = round(wsi_height / maskRows);
widthReduction = round(wsi_width / maskCols); %this is the distance between pixels in each element of the tumor mask at the original size
scaled_mask_x = tumor_mask(1) .* resize_amt;
scaled_mask_y = tumor_mask .* resize_amt;

[rows,cols,~] = size(small_image); %retrieves number of pixels per row and column
xincrement = rows / graph_dimensions(1); %sets the distance between each graph line
%yincrement = cols / graph_dimensions(2); %this makes the graph uneven if the image isn't square 
yincrement=xincrement;
xincrement = round(xincrement); 
yincrement = round(yincrement);
for x = 1:xincrement:cols
   for y = 1:yincrement:cols 
       if (inpolygon(x, y, scaled_ac_y, scaled_ac_x)) %if the x,y point is within the polygon, we extend a black line from that point to the right and down
            outlined_image(x, y:y+yincrement-1, 1) = 255; 
            outlined_image(x:x+xincrement-1, y, 1) = 255; 
            outlined_image(x, y:y+yincrement-1, 2) = 255; 
            outlined_image(x:x+xincrement-1, y, 2) = 255;
            outlined_image(x, y:y+yincrement-1, 3) = 0; 
            outlined_image(x:x+xincrement-1, y, 3) = 0;     
        end
   end
end
hold off
end