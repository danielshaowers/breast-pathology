annotation_coordinate = getAnnotationsimp('1000685.xml');
numCols = size(annotation_coordinate(1).X);
numRows = size(annotation_coordinate(1).Y); 
image_1000685 = 'Z:\2017-05-16_01\1000685.svs';
   
resize_val = 0.05;
block_dimensions = [10000, 10000]; %larger blocks = faster processing
directImage = '1000685.svs';
scaled_ac_x = annotation_coordinate(1).X .* resize_val;
scaled_ac_y = annotation_coordinate(1).Y .* resize_val;
tissue_patch=imread(image_1000685,'PixelRegion',{[min(annotation_coordinate(1).Y) (min(annotation_coordinate(1).Y) +2000)],[min(annotation_coordinate(1).X) (min(annotation_coordinate(1).X) +2000)]});
tissue_patch = imresize(tissue_patch, resize_val);
tissue_patch(10:10:end,:,:) = 'y';  %%this is just proof of concept I think. unless I show tissue_patch on top of the full image, which is v possible
%imread pixelregion gives the amorphous shape specified by the annotation.
%so i can just plot yellow there, and then the full thing can be grey
tissue_patch(:,10:10:end,:) = 'y';    %hopefully turns every tenth row and column to yellow. multidimensional stuff https://stackoverflow.com/questions/575475/how-can-i-save-an-altered-image-in-matlab/575519#575519
%see here how to superimpose. I expect this will be easiest solution
%https://www.mathworks.com/matlabcentral/answers/100086-how-do-i-superimpose-images-in-matlab~
hold on;
%plot([scaled_ac_x], [scaled_ac_y])  this works but I don't know how to
%overlay an image on it
%outline = polyshape([scaled_ac_x], [scaled_ac_y]); %this currently doesn't do anything
%insert shape requires the format x1, y1, x2, y2
A = zeros(numRows + numCols);
for index = 1:numRows %numRows should = numCols 
    A(2*index - 1) = scaled_ac_x(index);
    A(2*index) = scaled_ac_y(index);
end

B = A.';

small_image = getOutlineSimple(directImage, block_dimensions, 1, resize_val);
outlined_image = insertShape(small_image, 'Polygon', B(1,:), 'LineWidth', 10, 'Color', 'yellow');
graph_dimensions = [400 400];    %more dimensions increases accuracy 
[rows,cols,~] = size(small_image); %retrieves number of pixels per row and column
xincrement = rows / graph_dimensions(1); %sets the distance between each graph line
%yincrement = cols / graph_dimensions(2); %this makes the graph uneven if
%the image isn't square 
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
        elseif (20 < sum(outlined_image(x,y,:)) < 230*3) %ignores black and white space
       %elseif    (outlined_image(x,y,1) > 50)
            outlined_image(x, y:y+yincrement-1,:) = 0; %gives a black graph
            outlined_image(x:x+xincrement, y, :) =  0;
        end
   end
end
imshow(outlined_image)
hold off





