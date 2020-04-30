
%block_size is a vector specifying x and y size, should be a multiple of 16
%page is the page of the svs file we're intnerested in loading
function tumorOutline = getOutlineSimple(svs_filename, block_size, page, resize)

%fileparts separates a file into its directory, name, and suffix, allowing
%you to write a new file name later
%[~,baseFileName,~] = fileparts(svs_filename);

svs_adapter = PageTiffAdapter(svs_filename, page); %reads the image by parts, unlike imread which can't handle such a large image
%use block image processing to load the large image by parts
%anon function that accepts block struct and returns processed data
%block_fn  = @(block_struct) imresize(block_struct.data, resize_val);
block_fn = @(block_struct) imresize(block_struct.data, resize); %save time by using imwrite instead
%the operation changes depending on which block I am processing, I need
%to use the .location  field instead of .data
tumorOutline = blockproc(svs_adapter, block_size, block_fn); %perform the splitting
 
end


