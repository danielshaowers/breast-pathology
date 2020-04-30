%block_size is a vector specifying x and y size, should be a multiple of 16
%page is the page of the svs file we're intnerested in loading
function tumorOutline = blkwrite_tumor_mask(svs_filename, block_size, new_size)
addpath(genpath('D:\AI_Lab\Relevant Matlab'));
addpath('D:\AI_Lab\Repo\ECOG_Breast');
addpath(genpath('D:\AI_Lab\Relevant Matlab\ChengCode'));
 [~,baseFileName,~] = fileparts(svs_filename);  
svs_adapter = PageTiffAdapter(svs_filename, 1); %use block image processing to load the large image by parts
block_fn = @(block_struct) imresize(block_struct.data, new_size);
tumorOutline = blockproc(svs_adapter, block_size, block_fn); %perform the splitting
 
end



% distX = distX * resizeFactor;
% distY = distY * resizeFactor;
% 
% 
% 
% 
% %% draw grid lines in areas within the tumor mask and within the area outlined by annotationsimp
% LcreateFolder(outputFolder);
% function block_fn_wrapper(block) 
%   block.data = imresize(block.data, size(tumorMask) .* resizeFactor);
%     strPathIM = sprintf('%s%s_%d_%d.png', outputFolder, baseFileName,block.location(1)/distY,block.location(2)/distY);
%     y=block.location(1); %this doesn't change after resize since it's the top left point
%     x=block.location(2);
%     block_size = [block_size(1)/distY, block_size(2)/distX];
%      if inpolygon(block.location(1) + block_size(1)/2, block.location(2) + block_size(2)/2, xBounds, yBounds)
%           block.data(x:(x + floor(distX/2)), y:y+block_size(2), 1) = 255; 
%             block.data(x:x+block_size(1)-1, (y+ floor(distY/2)), 1) = 255; 
%             block.data((x + floor(distX/2)), y:y+block_size(2)-1, 2) = 255; 
%             block.data(x:x+block_size(1)-1, y:(y+floor(distY/2)), 2) = 255;
%             block.data((x + floor(distX/2)), y:y+block_size(2)-1, 3) = 0; 
%             block.data(x:x+block_size(1)-1, y:(y+floor(distY/2)), 3) = 0;     
%      end
%      %%for some reason this increments by 1, then suddnely jumps 16-746
% %      for idx = block.location(1):binaryDistanceX:block.location(1) + block_size(1) %rows
% %          for idy = block.location(2):binaryDistanceY:block.location(2) + block_size(2) %cols
% %              if tumorMask(ceil(idx/binaryDistanceX), ceil(idy/binaryDistanceY)) %we divide by binaryDistance to get corresponding index of tumor mask
% %                  block.data(idx, idy:idy+binaryDistanceY, 3) = 100;
% %                  block.data(idx:idxx+binaryDistanceX, idy, 3) = 100;
% %              end
% %          end
% %      end
% 
% %if tumorMask(ceil((y + block_size(1)/2)/distY), ceil((x + block_size(2)/2)/distX))
% if tumorMask(ceil(y/distY), ceil(x/distX))
%                     block.data(x:(x + floor(distX/2)), y:y+block_size(2), 1) = 0;
%                     block.data(x:x+block_size(1), y:(y + floor(distY/2)), 1) = 0;
%                     block.data(x:(x + floor(distX/2)), y:y+block_size(2), 2) = 255;
%                     block.data(x:x+block_size(1), (y + floor(distY/2)), 2) = 255;
%                     block.data(x:(x + floor(distX/2)), y:y+block_size(2), 3) = 255;
%                     block.data(x:x+block_size(1), (y + floor(distY/2)), 3) = 255;
% end
% 
%    % block.data = imresize(block.data, size(tumorMask)); %resizes the image to have numRows/numCols of tumor mask
%    % imwrite(block.data,strPathIM);
% end
% block_fn = @(block) block_fn_wrapper(block);
% %perform the splitting. sadly parallel doesn't work for image adapters
% %tumorOutline = blockproc(svs_adapter, block_size, block_fn, 'UseParallel',true); 
% tumorOutline = blockproc(svs_adapter, block_size, block_fn); 
% %% rewrites the split files if I want to analyze it as the actual size
% %this would let me make blocks smaller than the patches i'm analyzing
% % 
% inFileInfo=imfinfo(svs_filename); inFileInfo=inFileInfo(1);
% combinedDest =(sprintf('%s_combined',outputFolder));
% LcreateFolder(combinedDest);
%      outFile=sprintf('%s%s_combined.tif',outputFolder, baseFileName); %desired output filename
%      outFileWriter = bigTiffWriter(outFile, inFileInfo.Height/distY, inFileInfo.Width/distX, tileSize(1), tileSize(1),true); %a new image adapter to write the file
% % %enable compression as the last argument, otherwise the image will be quite
% % %large
% fun=@(block) repmat(imread(strPathIM),[1 1 3]); %load the output image, which has an expected filename (the two locations added). In this case my output is 60% smaller than the original image, so i'll scale it back up 
% 
%  blockproc(svs_adapter,tileSize,fun,'Destination',outFileWriter); %do the blockproc again, which will result in the same row/column coordinates, except now we specify the output image adatper to write the flie outwards
%      outFileWriter.close(); %close the file when we're done
% 
% end

