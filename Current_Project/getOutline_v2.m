%block_size is a vector specifying x and y size, should be a multiple of 16
%page is the page of the svs file we're intnerested in loading
function tumorOutline = getOutline_v2(svs_filename, outputFolder, block_size, xBounds, yBounds)
addpath(genpath('D:\AI_Lab\Relevant Matlab'));
dbstop if error
addpath('D:\AI_Lab\Repo\ECOG_Breast');
addpath(genpath('D:\AI_Lab\Relevant Matlab\ChengCode'))
 [~,baseFileName,~] = fileparts(svs_filename);  
svs_adapter = PageTiffAdapter(svs_filename, 1); %use block image processing to load the large image by parts
%function that writes each image into png format and stores row/column
LcreateFolder(outputFolder);
function block_fn_wrapper(block)
    %if inpolygon(block.location(1), block.location(2), xBounds, yBounds)
     if inpolygon(block.location(1) + block_size(1)/2, block.location(2) + block_size(2)/2, xBounds, yBounds)
         strPathIM = sprintf('%s%s_%d_%d.png', outputFolder, baseFileName,block.location(1),block.location(2));
         imwrite(block.data,strPathIM); %I only write if the top left of the block is in it. I might want to do middle block height + blockheight/2
     end
 end
block_fn = @(block) block_fn_wrapper(block);
%if the operation changes depending on which block I am processing, I need
%to use the .location  field instead of .data
tumorOutline = blockproc(svs_adapter, block_size, block_fn); %perform the splitting. unsure what it returns

%% rewrites the split files if I want to analyze it as the actual size
%this would let me make blocks smaller than the patches i'm analyzing
% if imageSplit == 0
%     outFile=sprints('%s,%s',baseFileName,'.tif'); %desired output filename
%     outFileWriter = bigTiffWriter(outFile, inFileInfo.Height, inFileInfo.Width, tileSize(1), tileSize(1),true); %a new image adapter to write the file
% %enable compression as the last argument, otherwise the image will be quite
% %large
%     fun=@(block) imresize(repmat(imread(sprintf('%s_%d_%d_prob.png',baseFilename,block.location(1),block.location(2))),[1 1 3]),1.666666666); %load the output image, which has an expected filename (the two locations added). In this case my output is 60% smaller than the original image, so i'll scale it back up 
% %fun=@(block)
% %imread(sprintf('%s_%d_%d.png',baseFilename,block.location(1),block.location(2)));
% %commented out even in the original humpty dumpty
%     blockproc(svs_adapter,tileSize,fun,'Destination',outFileWriter); %do the blockproc again, which will result in the same row/column coordinates, except now we specify the output image adatper to write the flie outwards
%     outFileWriter.close(); %close the file when we're done
% end
end

