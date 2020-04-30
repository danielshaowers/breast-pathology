function extract_key_features(blocks_formed, svs_filename, xml_filename, graph_dimensions)
%more dimensions increases accuracy 
annotation_coordinate = getAnnotationsimp(xml_filename);
numCols = size(annotation_coordinate(1).X);
numRows = size(annotation_coordinate(1).Y); 

block_dimensions; %larger blocks = faster processing
scaled_ac_x = annotation_coordinate(1).X;
scaled_ac_y = annotation_coordinate(1).Y;

A = zeros(numRows + numCols); %this creates a vector that alternates between x and y
for index = 1:numRows %numRows should = numCols 
    A(2*index - 1) = annotation_coordinate(1).X(index);
    A(2*index) = annotation_coorinate(1).Y(index);
end
B = A.';
if (blocks_formed == 0)
    small_image = getOutline(svs_filename, block_dimensions, 1, annotation_coordinate(1).X, annotation_coordinate(1).Y);
end

[rows,cols,~] = size(small_image); %retrieves number of pixels per row and column
xincrement = rows / graph_dimensions(1); %sets the distance between each graph line
%yincrement = cols / graph_dimensions(2); %this makes the graph uneven if the image isn't square 
yincrement=xincrement;
xincrement = round(xincrement); 
yincrement = round(yincrement);
for x = 1:xincrement:cols
   for y = 1:yincrement:cols 
       if (inpolygon(x, y, scaled_ac_y, scaled_ac_x)) %if the x,y point is within the polygon, we extend a black line from that point to the right and down
            %Lextractfeature
        end
   end
end
hold off
end