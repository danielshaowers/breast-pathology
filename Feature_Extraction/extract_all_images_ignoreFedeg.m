%42 images total.
function extract_all_images_ignoreFedeg(strSavePath, strPathIM)
%cd ..;
%cd 'D:\AI_Lab\Relevant_Matlab'

%addpath(genpath('/mnt/pan/Data7/cxl884/'));
%addpath(genpath('ChengCode'));
%addpath(genpath(sprintf('%s/Feature_Extraction', pwd)));
%addpath(genpath(sprintf('%s/First_Project/Code', pwd)));
%path = '/mnt/rstor/CSE_BME_AXM788/data/ECOG_Breast';

%path = 'Q:/';
%path = 'D:\AI_Lab\Repo\ECOG_Breast';
%% get the patches of nuclei
%get_dense_nuclei(image_path, num_tile_to_get, xml_path, xml_page)
%dirXML = dir(sprintf('%s/new annotation/*.xml', path));
%foundList = [1000978, 1000970, 1000985];
%toFindList = [1000638, 1000653, 1000684, 1000685, 1000737]; %100910 problems. I think it's too small. removing
%took out 657 because of parse error, took out 771 because too slow still,
%took out 676 and 653

%% using the directories created by get_dense_nuclei, extract the features
flag_nuclei_cluster_finding = 0;
para_nuclei_scale_low  = 8; %smallest pixels of a nucleus
para_nuclei_scale_high = 18;
flag_have_nuclei_mask = 0; %1 if true
nucleiPath='';
strEpiStrMaskPath=''; %currDir3(1).folder
wsi='';
flag_epistroma = 0; %flags are either 0 or 1
dbstop if error
idxBegin = 1; %which image we want to start with
%dirIM= dir (sprintf('%s/**/*.png', strSavePath)); %all png files within the current folder AND SUBFOLDERS

%% set idxbegin and end to ignore the masks!!
%pass in the name/name folder to defaultFeat extract, BUT IGNORE THE MASK IMAGES SOMEHOW
if nargin > 0
    idxEnd  =1;
    Dextractfeature_ignoreFeDeg(idxBegin, idxEnd, wsi, flag_epistroma, strPathIM, strSavePath, strEpiStrMaskPath, nucleiPath, flag_have_nuclei_mask, flag_nuclei_cluster_finding,...
        '.png', 0, 0, 0, 0, para_nuclei_scale_low, para_nuclei_scale_high);
else
    if ~ispc
        % fullDir = dir('/home/dxs765/Features3');
        addpath(genpath('/mnt/pan/Data7/cxl884/'));
        addpath(genpath('/home/dxs765'));
        errorFileName = '/home/dxs765/extract_all_errors.txt';
        %fullDir = dir('/home/dxs765/Features3');
        fullDir = dir('/home/dxs765/tcga_images');
        fullDir3 = dir('/home/dxs765/images');
        fullDir2  =dir('/mnt/rstor/CSE_BME_AXM788/data/tcga_brca_svs/salendra/images');
        fullDir = [fullDir; fullDir2; fullDir3];
    else
        %fullDir = dir('F:/Pathology/Features3');
        errorFileName = 'F:/Pathology/ExtractedFeats/extract_all_errors.txt';
        fullDir = dir('F:/Pathology/TCGA/images');
    end
    errorFile = fopen(errorFileName, 'w');
    
    
    
    % foundList={};
    % for i=3:length(fullDir)
    %     pngs = dir(sprintf('%s/%s/**/*.png', fullDir(i).folder, fullDir(i).name));
    %     if length(pngs) > 9
    %         foundList(length(foundList)+1) = {fullDir(i).name}; %list of folders with all 10 images
    %     end
    % end
    % %fullDir=dir('Features');
    
    %fullDir = dir('/home/dxs765/Features3');
    fullDir = fullDir([fullDir(:).isdir]); %only retrieve directories
    fullDir = fullDir(~ismember({fullDir(:).name}, {'.', '..'}));
    %fullDir = fullDir(ismember({fullDir(:).name}, foundList)); %only get the folders with all the images
    
    feat3flag=1;
    %for each slide, run Dextractfeature
    %for z=1:length(fullDir)
    start = 1;
    
    quarter = ceil(length(fullDir)/4); %break loop down into four parts so we can run in parallel
    mult = 1;
    skipCount = 50;
    toSkip = skipCount * 1;
    for z=1:length(fullDir)
        try
            
            %obtain the folders for each slide (should only be one)
            patientID = extractBetween(fullDir(z).name, 1, min(12, length(fullDir(z).name)));
            currDir = dir(sprintf('%s/%s', fullDir(z).folder, fullDir(z).name));
            currDir = currDir([currDir(:).isdir]); %only retrieve directories
            currDir = currDir(~ismember({currDir(:).name}, {'.', '..'}));
            for y=1:length(currDir) %within this folder, get the folder of each patch one last time
                currDir2 = dir(sprintf('%s/%s', currDir(y).folder, currDir(y).name)); %currDir(y) gives the list of all patches. currDir2 stores this list of patches
                currDir2 = currDir2([currDir2(:).isdir]); %only retrieve directories
                currDir2 = currDir2(~ismember({currDir2(:).name}, {'.', '..'}));
                %finally, within this folder, get the image and not the masks
                for q=1:(length(currDir2))
                    currDir3 = dir(sprintf('%s/%s/*.png', currDir2(q).folder, currDir2(q).name));
                    for a=1:length(currDir3)
                        if feat3flag %then there's only one feature
                            if ~strcmp(currDir3(a).name, sprintf('%s.png', currDir2(q).name)) %find the index of the image with the exact matching name to the folder name
                                continue
                            end
                        end
                        idxBegin=a;
                        idxEnd=idxBegin;
                        short_name = extractBetween(currDir3(a).name, length(currDir3(a).name)-9, length(currDir3(a).name) - 4);
                        strPathIM = sprintf('%s/', currDir3(1).folder); %this is the actual png
                        
                        strSavePath = sprintf('F:/Pathology/TCGA/features/%s', patientID{:});
                        if ~ispc
                            strSavePath = sprintf('/home/dxs765/TCGA/features/%s' , patientID{:});
                        end
                        
                        
                        
                        LcreateFolder(strSavePath);
                        strSavePath = sprintf('%s/%s/', strSavePath, short_name{:});
                        LcreateFolder(strSavePath);
                        already_extracted = dir([strSavePath '**/*allFeats']);
                        if isempty(already_extracted)
                            toSkip = toSkip - 1;
                            if toSkip > 0
                                continue
                            elseif toSkip < -skipCount
                                break
                            end
                            %% once I figure out how the e/s masks work, I might want to move them to a separate folder and pass that in as the directory
                            nucleiPath='';
                            strEpiStrMaskPath=''; %currDir3(1).folder
                            wsi='';
                            
                            Dextractfeature_ignoreFeDeg(idxBegin, idxEnd, wsi, flag_epistroma, strPathIM, strSavePath, strEpiStrMaskPath, nucleiPath, flag_have_nuclei_mask, flag_nuclei_cluster_finding,...
                                '.png', 0, 0, 0, 0, para_nuclei_scale_low, para_nuclei_scale_high);
                            
                        end
                    end
                end
            end
        catch ME
            errorMessage = sprintf('error: %s\n%s\n%s found but feature extraction failed, skipping \n', ME.message, ME.identifier, strPathIM);
            warning(errorMessage);
            %fprintf(errorFile, errorMessage);
            continue
        end
    end
end
%fclose(errorFile);
%dirIM= dir (sprintf('%s*.png', strSavePath)); %for all .png files in the current folder
%[idxEnd, ~] = size(dirIM);
%   %strEpiStrMaskPath = '/mnt/pan/Data7/hxl735/IDC_QH_collagen_outcome/WSI_epi_mask/ecog';
%strEpiStrMaskPath = '/mnt/pan/Data7/hxl735/IDC_QH_collagen_outcome/WSI_epi_mask/ecog/'; %make sure I know how this is being used so I can format it proeprly
%[strPathIM, name, imageType] = fileparts(wsi);
%% local device testing
%wsi = 'D:\Pathology\Features2';
%strSavePath = wsi;
% idxBegin =3; idxEnd=3;
%%
%for y = 1: size(dirXML)
% for y = size(dirXML):-1:1
%         xml_name = extractBetween(dirXML(y).name, 1, strlength(dirXML(y).name) - 4);
%         found = false;
%         for x = 1: size(dirSVS)
%             unwantedFolder = regexp(dirSVS(x).folder, 'AppleDouble');
%             svs_name = extractBetween(dirSVS(x).name, 1, strlength(dirSVS(x).name) - 4); %gets the image number without file type
%              if (strcmp(svs_name, xml_name) & size(unwantedFolder) == 0) %& any(toFindList == str2double(xml_name))) %skip the new annotation folder
%                % try
%                     sprintf('matched xml %s to svs without unwanted folder. folder at %s', xml_name, dirSVS(x).folder)
%                     found = true;
%
%                    % extractFeat_single_simple(sprintf('%s/%s',
%                    % dirSVS(x).folder, dirSVS(x).name), sprintf('%s/%s',
%                    % dirXML(y).folder, dirXML(y).name), errorFile); %if we
%                    % want random selection
%               %  catch ME
%               %      errorMessage = sprintf('error in extractFeat_single:
%               %      %s\n%s\n%s found but feature extraction failed,
%               %      skipping \n', ME.message, ME.identifier,
%               %      dirSVS(x).name);
%               %       warning(errorMessage); fprintf(errorFile,
%               %       errorMessage);
%                %     continue
%             %    end
%             end
%         end
%      if ~found
%        fprintf(errorFile,'svs of %s not found. Skipping\n', svs_name);
%      end
%     end
%
%
%fclose(errorFile);

