function tumor = find_tumor(svs_filename, xml_filename, block_dimensions)
%more dimensions increases accuracy but also runtime
annotation_coordinate = getAnnotationsimp(xml_filename);
tumor = getOutline_v2(svs_filename, block_dimensions, annotation_coordinate(1).X, annotation_coordinate(1).Y);

inFileInfo=imfinfo(svs_filename); %need to figure out what the final output size should be to create the emtpy tif that will be filled in
inFileInfo=inFileInfo(1); %imfinfo returns a struct for each individual page, we again select the page we're interested in

flag_nuclei_cluster_finding = 0;

para_nuclei_scale_low  = 8; %smallest pixels of a nucleus
para_nuclei_scale_high = 18;
flag_have_nuclei_mask = 0; %1 if true
flag_epistroma = 0;  %flags are either 0 or 1
dbstop if error
idx = 1;
strSavePath = 'D:\AI_Lab\Images2\';
strEpiStrMaskPath = '';
LcreateFolder(strSavePath);

height = inFileInfo.Height; %pixels high of orig image
width = inFileInfo.Width;
failCount = 0;
successCount = 0;
block_dimensions = [2048 2048];
%function that writes each image into png format and stores row/column
%(what are these values?)
%%info of the block, allowing us to find tile again later
LcreateFolder(strSavePath);
    function block_fn_wrapper(block)
     if inpolygon(block.location(1), block.location(2), xBounds, yBounds)
         strPathIM = sprintf('%s%s_%d_%d.png', strSavePath, baseFileName,block.location(1),block.location(2));
         imwrite(block.data,strPathIM); %I only write if the top left of the block is in it. I might want to do middle block height + blockheight/2
       try
         Dextractfeature_v1(idx, idx, svs_filename, flag_epistroma, strPathIM, strSavePath, strEpiStrMaskPath, strEpiStrMaskPath, flag_have_nuclei_mask, flag_nuclei_cluster_finding,...
        image_format, 0, 0, 1, 0, para_nuclei_scale_low, para_nuclei_scale_high)
       catch 
       end
     end
 end

end