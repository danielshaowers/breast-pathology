function defaultFeatureExtract(wsi, strSavePath, errorFile)
flag_nuclei_cluster_finding = 0;
para_nuclei_scale_low  = 8; %smallest pixels of a nucleus
para_nuclei_scale_high = 18;
flag_have_nuclei_mask = 0; %1 if true
flag_epistroma = 0; %flags are either 0 or 1
dbstop if error
idxBegin = 1; %which image we want to start with
%dirIM= dir (sprintf('%s/**/*.png', strSavePath)); %all png files within the current folder AND SUBFOLDERS
dirIM= dir (sprintf('%s*.png', strSavePath)); %for all .png files in the current folder
[idxEnd, ~] = size(dirIM); 
strEpiStrMaskPath = '';
[strPathIM, ~, imageType] = fileparts(wsi);
%% local device testing
% wsi = 'D:\AI_Lab\Relevant_Matlab\Images\Images_1I_1-4\1000629\';
% strSavePath = wsi;
% idxBegin =3;
% idxEnd=3;
%%
errorLine = 'none';
%try
    errorLine = Dextractfeature_v1(idxBegin, idxEnd, wsi, flag_epistroma, strSavePath, strSavePath, strEpiStrMaskPath, strEpiStrMaskPath, flag_have_nuclei_mask, flag_nuclei_cluster_finding,...
        '.png', 0, 0, 0, 0, para_nuclei_scale_low, para_nuclei_scale_high); %changed from 0010 to 0001
%catch ME
 %  error = sprintf('%s\nerror in Dextractfeature_v1 Line %s with image %s \n%s', ME.message, errorLine, wsi, ME.identifier);
  % warning(error);
   %fprintf(errorFile, error);
   return;
end
