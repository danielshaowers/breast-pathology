function [qPoints, failedAttempts] = selectPoints(tumor_mask, queryPoints, patch_size, img_size)
    tumor_mask_dilated = tumor_mask;
%tumor_mask_dilated=imerode(tumor_mask,strel('disk',20));          
B = bwboundaries(tumor_mask_dilated,4); %boundary values
fullMask = zeros(img_size(1), img_size(2)); %combines all logical arrays found
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
     totalElements = 0;
     %while(queryPoints > 0 && failedAttempts < 100000)
     while (totalElements < queryPoints)
         changeFlag = totalElements; %tracks if total elements changes or not
         idx = ceil((totalElements * length(foundRow)/ queryPoints + 1)); %selects a random row/column
         idx2 = idx;
         x = foundCol(idx(1)); %the x coord pixel of our guess
         y = foundRow(idx(1)); %the y coord pixel of our guess
         patch = sub2ind(size(fullMask),[y, y, y+patch_size, y+patch_size],...
         [x, x+patch_size, x, x+patch_size]); %gives the full patch based on what we selected
          %  if (all(fullMask(patch)))   %if all the points in the patch are in within the tumor, save the coordinate in q          
            if (nnz(fullMask(patch)) >= (0.8*numel(fullMask(patch)))) 
               failedAttempts = 0; %reset failed attempts
               queryPoints = queryPoints - 1; %updates how many remaining points we need
                totalElements = totalElements + 1;
                qPoints(totalElements, 1) = y; %every row of qPoint is one coordinate
                qPoints(totalElements, 2) = x;
            else
                while (nnz(fullMask(patch)) < (0.8*numel(fullMask(patch))) && idx2 < length(foundRow))
                    idx2 = idx2 + 1; %selects a new row/column
                    x = foundCol(idx2); %the x coord pixel of our guess
                    y = foundRow(idx2); %the y coord pixel of our guess
                    patch = sub2ind(size(fullMask),[y, y, y+patch_size, y+patch_size],...
                    [x, x+patch_size, x, x+patch_size]); %gives the full patch based on what we selected
                    if (nnz(fullMask(patch)) >= (0.8*numel(fullMask(patch))))   %if all the points in the patch are in within the tumor, save the coordinate in q          
                        failedAttempts = 0; %reset failed attempts
                        queryPoints = queryPoints - 1; %updates how many remaining points we need
                        totalElements = totalElements + 1;
                        qPoints(totalElements, 1) = y; %every row of qPoint is one coordinate
                        qPoints(totalElements, 2) = x;
                    end      
                end
                if (totalElements == changeFlag) %if the total elements still hasn't changed
                    idx2 = idx - 1;
                    while (idx2 > 1 && nnz(fullMask(patch)) < (0.8*numel(fullMask(patch))))
                        if (~ismember(foundRow(idx2), qPoints(:,1)))
                        x = foundCol(idx2); %the x coord pixel of our guess
                        y = foundRow(idx2); %the y coord pixel of our guess
                        patch = sub2ind(size(fullMask),[y, y, y+patch_size, y+patch_size],...
                        [x, x+patch_size, x, x+patch_size]); %gives the full patch based on what we selected
                        if (nnz(fullMask(patch)) >= (0.9*numel(fullMask(patch))))   %if all the points in the patch are in within the tumor, save the coordinate in q          
                            failedAttempts = 0; %reset failed attempts
                            queryPoints = queryPoints - 1; %updates how many remaining points we need
                            totalElements = totalElements + 1;
                            qPoints(totalElements, 1) = y; %every row of qPoint is one coordinate
                            qPoints(totalElements, 2) = x;
                        end
                        end
                        idx2 = idx2 - 1;
                    end
                end
            end
     end
end