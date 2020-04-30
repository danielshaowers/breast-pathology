%returns this with saveName of "full"
function outlined_image = saveTumorMask(wsi, tumor_mask, saveName)
bounds = bwboundaries(tumor_mask,4);
%bounds = bwboundaries(tumor_mask,8);
outlined_image = wsi;
B = [];
%% generate row vector of xy coordinates
%seems like there's a problem with the bounds being calcualted, since I
%draw a separate polygon for each hole. it's not finding enough holes?
%for index = 1:5 %
for index = 1:length(bounds) %for each hole
    numCell = cell2mat(bounds(index));
    B = []; %reset B
    A = zeros(length(numCell) * 2,1);
    for i = 1:length(numCell) %for all boundary pixels in the hole
        A(2*i - 1) = numCell(i, 2);
        A(2*i) = numCell(i, 1);
    end
    B = [B A.']; %keeps adding A as a row vector
    %B = [B A];
    if (length(B(1,:)) > 5)
        outlined_image = insertShape(outlined_image, 'Polygon', B(1,:), 'LineWidth', 10, 'Color', 'yellow');
    end
end
imwrite(outlined_image, sprintf('%s.png',saveName));
