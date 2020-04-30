function [qPoints, failedAttempts] = selectRandPoints(tumor_mask, queryPoints, patch_size, img_size)
%queryPoints is the number of points to be found IN EACH REGION, not total.
tumor_mask_dilated = tumor_mask;
%tumor_mask_dilated=imerode(tumor_mask,strel('disk',20));          
B = bwboundaries(tumor_mask_dilated,4); %boundary values
%% i could select random patches from each tumor or even amt for each tumor
%this one chooses even amt of each tumor
% tumor_point = floor(queryPoints / length(B));
% remainder_points = mod(queryPoints, length(B));
% for i = 1: length(B) %finds how many remaining points to select from each tumor block
%     tumor_points(i) = tumor_point;
%     if (remainder_points > 0)
%         remainder_points = remainder_points - 1;
%         tumor_points(i) = tumor_points(i) + 1;
%     end
% end
% tumor_points = queryPoints;
% totalElements = 0;
% qPoints = zeros(queryPoints, 2);
% for i = 1:length(tumor_points)
%      curB = B(i);
%      numericCells = curB;
%      numCell = cell2mat(numericCells);
%      minRow = min(numCell(:, 1));
%      minCol = min(numCell(:,2));
%      maxRow = max(numCell(:, 1)) - patch_size;
%      maxCol = max(numCell(:, 2)) - patch_size;
%      numElements = 0; % #elements found in current hole
%      failedAttempts = 0;
%      while(numElements < tumor_points(i) && failedAttempts < 1000)
%        failedAttempts = failedAttempts+1;
%         x = round(rand * (maxCol - minCol) + minCol);
%         y = round(rand * (maxRow - minRow) + minRow);
%         xv = x:x+patch_size - 1;
%         yv = y:y+patch_size - 1;
%         [in, on] = inpolygon(xv, yv, numCell(:, 2), numCell(:, 1));
%         if (sum(in(:)) + sum(on(:))) == patch_size   %if all the points in the patch are in within the tumor, save the coordinate in q
%            failedAttempts = 0; %reset failed attempts
%             numElements = numElements + 1;
%            totalElements = totalElements + 1;
%            qPoints(totalElements, 1) = y; %every row of qPoint is one coordinate
%            qPoints(totalElements, 2) = x;
%         end 
%      end
% end
% end

%% attempt using poly2mask
fullMask = zeros(img_size(1), img_size(2)); %combines all logical arrays found
totalElements = 0;
qPoints = zeros(queryPoints, 2);
for i = 1:length(B) %for every hole
     curB = B(i);
     numericCells = curB;
     numCell = cell2mat(numericCells);
     pixelsInPolygon = poly2mask(numCell(:,2), numCell(:,1), img_size(1), img_size(2)); %makes a mask sized to the tumor
     fullMask = or(fullMask, pixelsInPolygon); %adds to the binary mask
end
%we now have a binary mask with 1s at every point within the tumor
     [foundRow, foundCol] = find(fullMask==1); %vectors of the rows and column numbers where tumor is
     failedAttempts = 0;
     %while(queryPoints > 0 && failedAttempts < 100000)
     while(queryPoints > 0)
          failedAttempts = failedAttempts+1;
            idx = max([1,round(rand * length(foundRow))]); %selects a random row/column
            x = foundCol(idx(1)); %the x coord pixel of our guess
            y = foundRow(idx(1)); %the y coord pixel of our guess
            patch = sub2ind(size(fullMask),[y, y, y+patch_size, y+patch_size],...
            [x, x+patch_size, x, x+patch_size]); %gives the full patch based on what we selected
            if (all(fullMask(patch)))   %if all the points in the patch are in within the tumor, save the coordinate in q          
                failedAttempts = 0; %reset failed attempts
               queryPoints = queryPoints - 1; %updates how many remaining points we need
                totalElements = totalElements + 1;
                qPoints(totalElements, 1) = y; %every row of qPoint is one coordinate
                qPoints(totalElements, 2) = x;
            end 
      end
end
   
%end
%make sure there's no overlap!!
%% if i want to take the same patches from each tumor
%  for i=1:length(B) %length = number of different regions
%      curB=B{i}; %curB = Y x 2 array, where each row is a boundary pixel coordinate
%      %select a random point between the boundaries of the tumor mask
%      minRow = min(curB(:, 1));
%      minCol = min(curB(:, 2));
%      maxRow = max(curB(:, 1));
%      maxCol = max(curB(:, 2));
%      numElements = 0; % #elements found in current hole
%      while(numElements < queryPoints) 
%         x = round(rand * (maxCol - minCol) + minCol);
%         y = round(rand * (maxRow - minRow) + minRow);
%         xv = x:x+patch_size - 1;
%         yv = y:y+patch_size - 1;
%         [in, on] = inpolygon(xv, yv, curB(:, 2), curB(:, 1));
%         if (sum(in(:)) + sum(on(:))) == patch_size   %if all the points in the patch are in within the tumor, save the coordinate in q
%            numElements = numElements + 1;
%            qPoints(numElements + (i-1)*queryPoints, 1) = y; %every row of qPoint is one coordinate
%            qPoints(numElements + (i-1)*queryPoints, 2) = x;
%         end 
%      end
%  end