function outlined_image = visualizeTumor(svs_filename, xml_filename, resize_amt, graph_dimensions)
%more dimensions increases accuracy 
annotation_coordinate = getAnnotationsimp(xml_filename);
numCols = size(annotation_coordinate(1).X);
numRows = size(annotation_coordinate(1).Y); 

block_dimensions = [10000, 10000]; %larger blocks = faster processing
%directImage = '1000685.svs';
scaled_ac_x = annotation_coordinate(1).X .* resize_amt;
scaled_ac_y = annotation_coordinate(1).Y .* resize_amt;

A = zeros(numRows + numCols);
for index = 1:numRows %numRows should = numCols 
    A(2*index - 1) = scaled_ac_x(index);
    A(2*index) = scaled_ac_y(index);
end
B = A.';

small_image = getOutlineSimple(svs_filename, block_dimensions, 1, 0, resize_amt);
outlined_image = insertShape(small_image, 'Polygon', B(1,:), 'LineWidth', 10, 'Color', 'yellow');

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
        elseif (20 < sum(outlined_image(x,y,:)) < 230*3) %ignores black and white space
       %elseif    (outlined_image(x,y,1) > 50)
            outlined_image(x, y:y+yincrement-1,:) = 0; %gives a black graph
            outlined_image(x:x+xincrement, y, :) =  0;
        end
   end
end
hold off
end