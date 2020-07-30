% this script assume that we have all the tiles from each WSI (in a single folder) and try to
% pick out 1 representative tile for each WSI, the image name list will be
% generated for downstream processing on HPC or local machine
% assumption: the folder contains only 20x or 40x images
%             save the 20x magnification tile
% 2018 Aug. 9, 2018 by Cheng Lu
function get_dense_nuclei(image_path, num_tile_to_get, xml_path, xml_page)
dbstop if error
errorFile = fopen('/home/dxs765/errors_getDense.txt', 'w');
%combine the epithelial mask with the tumor mask
addpath(genpath('/mnt/pan/Data7/cxl884/Code'));
addpath('/home/dxs765/Feature_Extraction');
addpath('/home/dxs765/First_Project');
addpath('/home/dxs765/Current_Project');
addpath(genpath('/home/dxs765/tools/tile_selection_Cheng_method/'));
addpath('/usr/local/openslide/3.4.1/include/openslide')
addpath('/usr/local/openslide/3.4.1/lib')
if ~ispc
    path = ('/mnt/rstor/CSE_BME_AXM788/data/ECOG_Breast');
    %path = '/mnt/rstor/CSE_BME_AXM788/data/UH_Breast_Histology/breast_odx_2019_8_1';
    path = ('/mnt/rstor/CSE_BME_AXM788/data/tcga_brca_svs/aacruzr-tcga-bca-7effd4ea4c86/');
else
    path = ('C:\Users\danie\OneDrive\Desktop\Pathology');
    path = ('F:\Pathology\tcga_images');
end
% specific1 = '2017-06-22_01';
% specific2 = '2017-05-16_01';
% specific3 = '2017-07-07_01';
% specific4 = 'new annotation';
dirSVS = dir(sprintf('%s/**/*.svs', path)); %finds all svs files in the current folder or subfolders of myfolder
%dirXML = dir(sprintf('%s/%s/**/*.xml', path, specific2));
%dirXML = dir(sprintf('%s/**/*.xml', path));
%foundList = {'.', '..', '1000801.xml','1000802.xml','1000804.xml','1000807.xml','1000808.xml','1000809.xml','1000810.xml','1000811.xml','1000812.xml','1000814.xml','1000816.xml','1000817.xml','1000818.xml','1000819.xml','1000820.xml','1000821.xml','1000823.xml','1000824.xml','1000825.xml','1000826.xml','1000827.xml','1000828.xml','1000834.xml','1000836.xml','1000837.xml','1000854.xml','1000856.xml','1000857.xml','1000858.xml','1000859.xml','1000861.xml','1000863.xml','1000864.xml','1000868.xml','1000869.xml','1000870.xml','1000871.xml','1000872.xml','1000874.xml','1000875.xml','1000876.xml','1000877.xml','1000878.xml','1000879.xml','1000890.xml','1000892.xml','1000893.xml','1000894.xml','1000895.xml','1000896.xml','1000897.xml','1000898.xml','1000899.xml','1000900.xml','1000901.xml','1000903.xml','1000904.xml','1000905.xml','1000906.xml','1000907.xml','1000908.xml','1000909.xml','1000910.xml','1000916.xml','1000920.xml','1000921.xml','1000922.xml','1000923.xml','1000924.xml','1000925.xml','1000927.xml','1000928.xml','1000929.xml','1000931.xml','1000932.xml','1000933.xml','1000934.xml','1000935.xml','1000936.xml','1000937.xml','1000938.xml','1000939.xml','1000941.xml','1000943.xml','1000944.xml','1000945.xml','1000946.xml','1000947.xml','1000948.xml','1000949.xml','1000950.xml','1000951.xml','1000953.xml','1000954.xml','1000955.xml','1000956.xml','1000957.xml','1000959.xml','1000961.xml','1000962.xml','1000963.xml','1000964.xml','1000965.xml','1000966.xml','1000967.xml','1000968.xml','1000969.xml','1000970.xml','1000971.xml','1000972.xml','1000973.xml','1000974.xml','1000975.xml','1000976.xml','1000977.xml','1000978.xml','1000979.xml','1000985.xml','1000900.xml', '1000901.xml','1000903.xml','1000904.xml','1000905.xml','1000906.xml','1000907.xml','1000908.xml','1000909.xml', '1000910.xml','1000916.xml','1000920.xml','1000921.xml','1000922.xml','1000923.xml','1000924.xml','1000925.xml','1000927.xml','1000928''1000929.xml','1000931.xml','1000932.xml','1000933.xml','1000934.xml','1000935.xml','1000936.xml','1000937.xml','1000938.xml','1000939.xml','1000940.xml','1000941.xml','1000942.xml','1000943.xml','1000944.xml','1000945.xml','1000946.xml','1000947.xml','1000948.xml','1000949.xml','1000950.xml','1000951.xml','1000953.xml','1000954.xml','1000955.xml','1000956.xml','1000957.xml','1000959.xml','1000961.xml','1000962.xml','1000963.xml','1000964.xml','1000965.xml','1000966.xml','1000967.xml','1000968.xml','1000969.xml','1000970.xml','1000971.xml','1000972.xml','1000973.xml','1000974.xml','1000975.xml','1000976.xml','1000977.xml','1000978.xml','1000979.xml','1000985.xml'};
if ispc
    dirFound = dir('F:/Pathology/tcga_images');
    load('F:/Pathology/Training_Data/TCGA_data.mat');
    % dirFound = dir('C:\Users\danie\OneDrive\Desktop\Pathology\UH_Images');
else
    dirFound = dir('/home/dxs765/tcga_images'); %images already done
    load('/home/dxs765/Training_Data/TCGA_data.mat');
end
foundList={};
%% skip directories with 13 png images already. save in cell array
for i=3:length(dirFound)
    pngs = dir(sprintf('%s/%s/**/*.png', dirFound(i).folder, dirFound(i).name));
    if length(pngs) == 13
        foundList(length(foundList)+1) = {[dirFound(i).name '.xml']};
    end
end

%dirFound = dir('F:/Pathology/Features3');
if ~ispc
   % dirXML = dir('/home/dxs765/Features2/**/*.xml'); %where can we find the xmls
    dirXML = dir('/mnt/rstor/CSE_BME_AXM788/data/UH_Breast_Histology/breast_odx_2019_8_1');
    dirXML = dirXML(~ismember({dirXML(:).name}, foundList));
    svsFolder = ('/mnt/rstor/CSE_BME_AXM788/data/tcga_brca_svs/');%('/mnt/rstor/CSE_BME_AXM788/data/UH_Breast_Histology/breast_odx_2019_8_1/');
    xmlFolder = ('/mnt/rstor/CSE_BME_AXM788/data/tcga_brca_svs/aacruzr-tcga-bca-7effd4ea4c86/XML_TCGA_HG/');
else
    dirXML = dir('F:/Pathology/**/*.xml');
    dirXML = dir(sprintf('%s/**/*.xml', path));
    temp = dir('F:\Pathology\TCGA\masks\**/*_tumor_mask.png');
    
    xmlFolder = 'F:/Pathology/tcga_images/';
    svsFolder = xmlFolder;
end
openslide_load_library();
disp(['OpenSlide version: ',openslide_get_version()])
%dirXML = dir(sprintf('%s/new annotation/*.xml', path));
%I could do this with dir image, then checking the name
%for y = 1: size(dirXML)
%for y = 1:size(dirXML, 1)
quarter = floor(length(final_xml)/4);
for y= 3*quarter+3: length(final_xml)
    %xml_name = extractBetween(dirXML(y).name, 1, strlength(dirXML(y).name) - 4);
    xml_name = final_xml{y}; 
    %      if ismember(xml_name, foundList)
    %          sprintf('slide %s already filled', dirXML(y).name)
    %          continue
    %      end
    %
       
        svs_name = xml_name;
        %if (strcmp(svs_name, xml_name) && isempty(unwantedFolder)) %skip the new annotation folder
           % sprintf('matched xml %s to svs', cell2mat(xml_name))
            %xml_filename=sprintf('%s/%s', dirXML(y).folder, dirXML(y).name);
            xml_filename = [xmlFolder xml_name '.xml'];
            %svs_filename=sprintf('%s/%s', dirSVS(x).folder, dirSVS(x).name);
            svs_filename = [svsFolder xml_name '.svs'];
            [~, name, ~] = fileparts(svs_filename);
            xml_page =  5;%8 if it's a tiff
            if ~ispc
                %saveDir = sprintf('/home/dxs765/Features3/%s/', name);
                saveDir = sprintf('/home/dxs765/tcga_images/%s/', name);
            else
                saveDir = sprintf('F:/Pathology/tcga_images/');
                %saveDir = sprintf('C:\Users\danie\OneDrive\Desktop\Pathology\UH_Images');
            end
            LcreateFolder(saveDir);
         %   dirSVS(x) = []; %delete the svs so we don't search it any more
            %str_image_local='/home/dxs765/Features2/';
            %str_mask_local='/home/dxs765/Features2/';
            
            epi_filename = sprintf('/mnt/pan/Data7/hxl735/IDC_QH_collagen_outcome/WSI_epi_mask/ecog/%s_epi_mask.png', name);
            str_filename = sprintf('/mnt/pan/Data7/hxl735/IDC_QH_collagen_outcome/WSI_epi_mask/ecog/%s_str_mask.png', name);
            
            %% ------------------------------------------------------
            topLayer= 1; %3 if it's a tif
            tumor_mask = anno2mask(xml_filename, svs_filename, topLayer, xml_page); %this ensures the tumor mask is the same size as the svs we're analyzing
            %tumor_mask2 = imread(epi_filename);
            %ratio = size(tumor_mask, 1) / size(tumor_mask2, 2);
            
            %if ratio >= 1 %scale mask2 up
            %   tumor_mask2 = imresize(tumor_mask, [size(tumor_mask, 1), size(tumor_mask, 2)], 'nearest');
            %else %scale mask up
            %    tumor_mask = imresize(tumor_mask, [size(tumor_mask2, 1), size(tumor_mask2, 2)], 'nearest');
            %end
            %saveTumorMask(imread(svs_filename,'Index', xml_page), and(tumor_mask > 0.1, tumor_mask2 > 0.1), sprintf('%s%s_epi_tumor_mask', str_mask_local, name));
            saveTumorMask(imread(svs_filename,'Index', xml_page), tumor_mask, sprintf('%s%s_tumor_mask', saveDir, name));
          
            set(0, 'DefaultFigureVisible', 'off');
            str_folder_eye_check = saveDir; %directory to save results for "checking by eye"
            num_tile_size=[2000 2000];% the size of the tile to be saved 
            num_tile_to_get=10;
            mask_extension = '_tumor_mask_bw.png'; %this corresponds to the mask created through saveTumorMask
            num_mag_to_save=20; % the magnification of the tile to be saved, now only support 20x
            str_folder_save = saveDir; %sprintf('%s/Patches', saveDir);
            full_epi =[];
            full_str=[];
            %             if exist(epi_filename) ~= 0
            %                 full_epi = imread(epi_filename);
            %                 sprintf('epi mask fund at %s', epi_filename)
            %             end
            %dir_mask=dir([saveDir mask_extension]);
            dir_mask=dir([saveDir sprintf('*%s', mask_extension)]);
            for i=1:length(dir_mask)
                %new folders for each group of sliced images
                folder_save_child = fullfile(str_folder_save,sprintf('%s', name));
                fprintf('Processing %s \n', folder_save_child);
                LcreateFolder(folder_save_child);
                fprintf('on %d/%d image\n',i,length(dir_mask)); %reports current progress vs total images in folder
                idx_mag=[];
                curID=dir_mask(i).name;
                %tmp=strsplit(curID,'_mask');
                tmp = strsplit(curID, '_');
                %curID=tmp{1};
                curID = tmp{1};
                %     im_info=imfinfo([str_image_local curID]);
                
                % Open whole-slide image
                slidePtr = openslide_open(svs_filename);
                % Get whole-slide image properties
                [mppX, mppY, width, height, numberOfLevels, ...
                    downsampleFactors, objectivePower] = openslide_get_slide_properties(slidePtr);
                downsampleFactors=round(downsampleFactors);
                % Display properties
                %     disp(['mppX: ',num2str(mppX)])
                %     disp(['mppY: ',num2str(mppY)])
                %     disp(['width: ',num2str(width)])
                %     disp(['height: ',num2str(height)])
                %     disp(['number of levels: ',num2str(numberOfLevels)])
                % %     disp(['downsample factors: ',num2str(downsampleFactors)])
                %     disp(['objective power: ',num2str(objectivePower)])
                if objectivePower==40 || mppX<0.26 %~isempty(idx_mag)% this is a 40x image I uesed | because of the mistake of the image information regarding the objective power (example: TCGA-05-4244-01Z-00-DX1.d4ff32cd-38cf-40ea-8213-45c2b100ac01.svs)%~isempty(idx_mag)% this is a 40x image
                    if numberOfLevels>3
                        [ARGB] = openslide_read_whole_level_im(slidePtr,'level',3); %changed by daniel from 3 at first
                        %             factor_tilepicing=8;
                        factor_tilepicing=downsampleFactors(4); %changed from 4 originally
                    end
                    if numberOfLevels==3
                        [ARGB] = openslide_read_whole_level_im(slidePtr,'level',2);
                        %             factor_tilepicing=4;
                        factor_tilepicing=downsampleFactors(3);
                    end
                    
                    if numberOfLevels<3
                        continue;
                    end
                else% this is a 20x image % i=127
                    if numberOfLevels==3
                        [ARGB] = openslide_read_whole_level_im(slidePtr,'level',2);
                        factor_tilepicing=downsampleFactors(3);
                    else
                        if numberOfLevels == 9
                            [ARGB] = openslide_read_whole_level_im(slidePtr,'level',3);
                            factor_tilepicing = downsampleFactors(4);
                        else
                            continue;
                        end
                    end
                end
                
                cur_im_lowres=ARGB(:,:,2:4);
                % Display RGB part
                %     figure(1)
                %     imshow(cur_im_lowres);
                %     set(gcf,'Name','WSI','NumberTitle','off')
                
                % read the mask_use
                %cur_im_bw_QC=imread([str_esMask_hpc curID '_mask_use.png']);
                cur_im_bw_QC=imread([saveDir curID mask_extension]);
                cur_im_bw_QC=imresize(cur_im_bw_QC,[size(cur_im_lowres,1) size(cur_im_lowres,2)]);
                %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,1),1);
                %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,2));
                %         LshowBWonIM(cur_im_bw_QC,cur_im_lowres(:,:,3));
                
                % begin to pick a tile and save it
                flag_s=1;
                %     I_show
                R=cur_im_lowres(:,:,1);
                %get ink mask
                bw_R_ink=R<100;%show(bw_R_ink)
                bw_R=R<180;%show(bw_R)%show(R) show(cur_im_bw_QC)
                bw_R=cur_im_bw_QC&bw_R&~bw_R_ink;
                % LshowBWonIM(bw_R,R,2);
                %%% save the high mag tile into folder
                bw_tile_out=bw_R;
                set_tiles_HH_all=[];
                idx_tiles=0;
                counter = 1;
                while idx_tiles<num_tile_to_get
                    %         num_tile_to_get=num_tile_to_get-1;
                    %try
                    idx_tiles=idx_tiles+1;
                    bw_R=bw_R&bw_tile_out;
                    if objectivePower==40 || mppX<0.26 %~isempty(idx_mag)% this is a 40x image I uesed | because of the mistake of the image information regarding the objective power (example: TCGA-05-4244-01Z-00-DX1.d4ff32cd-38cf-40ea-8213-45c2b100ac01.svs)%~isempty(idx_mag)% this is a 40x image
                        if num_mag_to_save==20
                            [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing*2),cur_im_lowres,0);
                            set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
                            %                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
                            bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
                            %                 saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                            close all;
                            set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                            set_tiles_HH_save(3:4)=num_tile_size*2;
                            
                            if set_tiles_HH_save(1) + set_tiles_HH_save(3)- 1 >= width
                                set_tiles_HH_save(1)= width-set_tiles_HH_save(3);
                            end
                            if set_tiles_HH_save(2) + set_tiles_HH_save(4) - 1 >= height
                                set_tiles_HH_save(2)= height-set_tiles_HH_save(4);
                            end
                            
                            [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
                            cur_tile_2_save=ARGB(:,:,2:4);
                            cur_tile_2_save=imresize(cur_tile_2_save,0.5);
                            set_tiles_HH_save(3:4)=num_tile_size;
                        else
                            [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing),cur_im_lowres,0);
                            set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
                            %                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
                            bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
                            %                 saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                            close all;
                            set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                            set_tiles_HH_save(3:4)=num_tile_size;
                            %             set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                            %             set_tiles_HH_save(3:4)=num_tile_size;
                            [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
                            cur_tile_2_save=ARGB(:,:,2:4); %sets it to 20 magnification no matter what, which corresponds to our tumor size!
                        end
                    else% this is a 20x image
                        [set_tiles_HH,protion_HH]=LselectBestTile_sliding_window_method_v2(bw_R,cur_im_bw_QC,round(num_tile_size(1)/factor_tilepicing),cur_im_lowres,0);
                        set_tiles_HH_all(idx_tiles,:)=set_tiles_HH;
                        %                 bw_tile_out=ones(size(bw_R,1),size(bw_R,2));
                        bw_tile_out(set_tiles_HH(2):set_tiles_HH(2)+set_tiles_HH(3)-1,set_tiles_HH(1):set_tiles_HH(1)+set_tiles_HH(4)-1)=0;
                        %             saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                        close all;
                        set_tiles_HH_save=set_tiles_HH*factor_tilepicing;
                        set_tiles_HH_save(3:4)=num_tile_size;
                        [ARGB] = openslide_read_region(slidePtr,set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),'level',0);
                        cur_tile_2_save=ARGB(:,:,2:4);
                    end
                    % catch ME
                    %    fprintf(errorFile, sprintf('%s image has length %d\n', length(set_tiles_HH_save))); %s\n %s\n %s\n%s\n\n', name, length(set_tiles_HH_save), ME.identifier, ME.message, ME.cause, ME.stack));
                    %    continue
                    % end
                    %     show(cur_tile_2_save)
                    newFolder=sprintf('%s/%s_%d_%d/', folder_save_child, name, set_tiles_HH_save(1), set_tiles_HH_save(2));
                    LcreateFolder(newFolder); %this one is weird
                    fullfile_name = fullfile(newFolder, sprintf('%s_%d_%d.png', name, set_tiles_HH_save(1), set_tiles_HH_save(2)));
                    if ~exist(fullfile_name, 'file')
                        %imwrite(cur_tile_2_save,sprintf('%s%s_xpos%d_ypos%d_w%d_h%d_@%dx.png',folder_save_child,curID(1:12),set_tiles_HH_save(1),set_tiles_HH_save(2),set_tiles_HH_save(3),set_tiles_HH_save(4),num_mag_to_save));
                        imwrite(cur_tile_2_save, fullfile_name);
                    else
                        continue
                    end
                    %actual tile size/shrunken tile size gives the ratio that things were shrunk.
                    %adjustedRowInd = num_tile_size(1)/set_tiles_HH_save(3) * set_tiles_HH_save(1);
                    %adjustedColInd = num_tile_size(2)/set_tiles_HH_save(4) * set_tiles_HH_save(2);
                    adjustedRowInd=set_tiles_HH_save(1);
                    adjustedColInd=set_tiles_HH_save(2);
                    %                     try
                    %                         if size(full_epi, 1) > 10 %issue would arise when there was no epi mask, but it still tried going into this if statement
                    %                             full_epi= imresize(full_epi, [size(cur_im_bw_QC, 1), size(cur_im_bw_QC, 2)]);
                    %                             %full_epi= imresize(full_epi, [gca.ylim, gca.xlim]);
                    %                             %full_epi = imresize(full_epi, [size(cur_im_bw_QC,1) size(cur_im_bw_QC,2)]); %we want to resize based on the image that the main dude is BASED on. not sure where to actually find that though
                    %                             imwrite(full_epi(adjustedRowInF:adjustedRowInd+num_tile_size(1), adjustedColInF:adjustedColInd + num_tile_size(2)), sprintf('%s/epi_mask_%s_%d_%d.png', newFolder, name, set_tiles_HH_save(1), set_tiles_HH_save(2)));
                    %                         end
                    %                     catch ME
                    %                         sprintf('OUT OF BOUNDS. rows of epi %d, largest requested row %d. cols of epi %d, largest requested col %d', size(full_epi, 1), adjustedColInd+num_tile_size(1), size(full_epi, 2), adjustedColInd+num_tile_size(2))
                    %                     end
                    counter = counter + 1;
                end
                show(cur_im_lowres);
                hold on;
                for k=1:size(set_tiles_HH_all,1)
                    set_tiles_HH=set_tiles_HH_all(k,:);
                    %       -plot(cc,cr,'b*','MarkerSize',8);
                    rectangle('Position',set_tiles_HH,'EdgeColor','b','LineWidth',3);
                end
                hold off;
                saveas(gca,[str_folder_eye_check curID '_tile_selection.png']);
                %}
                % Close whole-slide image, note that the slidePtr must be removed manually
                openslide_close(slidePtr)
                clear slidePtr
          
        end
%     if (~found)
%         sprintf('no svs found for xml %s', dirXML(y).name)
%     end
end
fclose(errorFile);
% Unload library
openslide_unload_library
