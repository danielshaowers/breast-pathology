%block_size is a vector specifying x and y size, should be a multiple of 16
%page is the page of the svs file we're intnerested in loading
function tumorOutline = getOutline(svs_filename, block_size, page, xBounds, yBounds)
 [~,baseFileName,~] = fileparts(svs_filename);  
 %this returns tumorOutline, but what does blockproc actually return? it stitched together for imreading?  
%fileparts separates a file into its directory, name, and suffix
        svs_adapter = PageTiffAdapter(svs_filename, page); %reads the image by parts, unlike imread which can't handle such a large image
%use block image processing to load the large image by parts
%anon function that accepts block struct and returns processed data
%block_fn  = @(block_struct) imresize(block_struct.data,0.01);
%function that writes each image into png format and stores row/column
%(what are these values?)
%%info of the block, allowing us to find tile again later
%%function block_fn (block)
  %  if inshape(block.location(1), block.location(2), xBounds, yBounds)
   % Lcreatefolder(baseFileName);
    %imwrite(block.data,sprintf('%s_%d_%d.png',baseFileName,block.location(1),block.location(2))); %I only write if the top left of the block is in it. I might want to do middle block height + blockheight/2
    %end
%end 
block_fn = @(block_struct) imresize(block_struct.data, resize);
%the operation changes depending on which block I am processing, I need
%to use the .location  field instead of .data
        tumorOutline = blockproc(svs_adapter, block_size, block_fn); %perform the splitting
  
inFileInfo=imfinfo(svs_filename); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
inFileInfo=inFileInfo(page); %imfinfo returns a struct for each individual page, we again select the page we're interested in
%
height = inFileInfo.Height; %pixels high of orig image
width = inFileInfo.Width;
%individual panel data
pause
%%do work on individual pane here
%nested for loop that runs through all the filenames from 0 to
%width/size...? the row/column is the pixel location, increases by block
%size each time
%for i  = 1:block_size(1):width
 %   for j = 1:block_size(2):height
  %      fileBlock = sprintf('%s_%d_%d.xml',baseFileName,i,j);
   %     DextractFeature(fileBlock, fileBlock, block_size); %probable issue: these are png files, not svs 
   % end
%end



%% rewrites the split files if I want to analyze it as the actual size
%this would let me make blocks smaller than the patches i'm analyzing

    outFile=sprints('%s,%s',baseFileName,'.tif'); %desired output filename
    outFileWriter = bigTiffWriter(outFile, inFileInfo.Height, inFileInfo.Width, tileSize(1), tileSize(1),true); %a new image adapter to write the file
%enable compression as the last argument, otherwise the image will be quite
%large
    fun=@(block) imresize(repmat(imread(sprintf('%s_%d_%d_prob.png',baseFilename,block.location(1),block.location(2))),[1 1 3]),1.666666666); %load the output image, which has an expected filename (the two locations added). In this case my output is 60% smaller than the original image, so i'll scale it back up 
%fun=@(block)
%imread(sprintf('%s_%d_%d.png',baseFilename,block.location(1),block.location(2)));
%commented out even in the original humpty dumpty
    blockproc(svs_adapter,tileSize,fun,'Destination',outFileWriter); %do the blockproc again, which will result in the same row/column coordinates, except now we specify the output image adatper to write the flie outwards
    outFileWriter.close(); %close the file when we're done

end