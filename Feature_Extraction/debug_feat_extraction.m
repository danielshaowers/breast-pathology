dbstop if error
%% debug Lextractfeature_v17 for bladder cases
addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous');
addpath(genpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Segmentation\veta_watershed'));
dbstop if error
strPathIM='Z:\UH_Bladder_Cancer_Project\ROIs\';
strSavePath='Z:\UH_Bladder_Cancer_Project\dl_features\';LcreateFolder(strSavePath);
strEpiStrMaskPath='Z:\UH_Bladder_Cancer_Project\ROIs\nuclei_mask_fit\';

% strPathIM='Z:\OSU_Oral_OropharyngealTMA\Ventana\4u0XTMAsAPR2019\TMAs_OralCavity\all_imgs\';
% strSavePath='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\ws_features\';%LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\ep_mask@5x_postprocessed\';

strNucleiMaskPath=strEpiStrMaskPath;
flag_nuclei_cluster_finding=0;
% image_format='.jpg';
image_format='.png';
para_nulei_scale_low=8;
para_nulei_scale_high=18;
flag_have_nulei_mask=1;
flag_epistroma=0;

idx=94;
Lextractfeature_v17(idx,idx,strWSIPath,flag_epistroma,strPathIM,strSavePath,...
    strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,...
    image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high);
%% debug Lextractfeature_v16 for oral cavity case
% addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous');
% addpath(genpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Segmentation\veta_watershed'));
% dbstop if error
% strPathIM='Z:\WUSTL_Oral_Histology\all_tma_images~~\';
% strSavePath='Z:\WUSTL_Oral_Histology\ws_features\';%LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\WUSTL_Oral_Histology\AllTMAwithEPMask_downby8\';
% 
% % strPathIM='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\all_imgs\';
% % strSavePath='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\ws_features\';%LcreateFolder(strSavePath);
% % strEpiStrMaskPath='Z:\OSU_Oral_OropharyngealTMA\Ventana\40XTMAsAPR2019\TMAs_OralCavity\ep_mask@5x_postprocessed\';
% 
% strNucleiMaskPath='';
% flag_nuclei_cluster_finding=0;
% % image_format='.jpg';
% image_format='.tif';
% para_nulei_scale_low=8;
% para_nulei_scale_high=18;
% flag_have_nulei_mask=0;
% flag_epistroma=1;
% 
% strWSIPath='';
% strWSI_format='.tif';
% % str_im='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% % str_epi='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% % str_nuclei='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_seg\';
% % str_nuclei_clumpsplit='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% idx=1;
% Lextractfeature_v17(idx,idx,strWSIPath,flag_epistroma,strPathIM,strSavePath,...
%     strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,...
%     image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high);
% 
% % Lextractfeature_v16(idx,idx,strWSIPath,strWSI_format,flag_epistroma,strPathIM,strSavePath,...
% %     strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,...
% %     image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high);
% % idxBegin,idxEnd,strWSIPath,flag_epistroma,strPath,...
% %     strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,...
% %     flag_nuclei_cluster_finding,image_format,flag_Hosoya,flag_haralick,...
% %     flag_CCM,flag_WSI,para_nulei_scale_low,para_nulei_scale_high

%% debug Lextractfeature_v15_get_im_on_the_fly
% addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous');
% dbstop if error
% strPath='Z:\CCF_OropharyngealCarcinoma\Ventana\CCF358_2048@40x_episeg\';
% strSavePath='Z:\CCF_OropharyngealCarcinoma\Ventana\CCF358_2048@40x_features\';%LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\CCF_OropharyngealCarcinoma\Ventana\CCF358_2048@40x_episeg\';
% strNucleiMaskPath='Z:\CCF_OropharyngealCarcinoma\Ventana\CCF358_2048@40x_cellseg_split\';
% flag_nuclei_cluster_finding=0;
% image_format='.png';
% para_nulei_scale_low=0;
% para_nulei_scale_high=0;
% flag_have_nulei_mask=1;
% 
% strWSIPath='Z:\CCF_OropharyngealCarcinoma\Ventana\';
% strWSI_format='.tif';
% % str_im='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% % str_epi='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% % str_nuclei='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_seg\';
% % str_nuclei_clumpsplit='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% idx=1;
% Lextractfeature_v15_get_im_on_the_fly_separate_folder(idx,idx,strWSIPath,strWSI_format,1,strPath,strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high)
%% debug Lextractfeature_v15_get_im_on_the_fly
% addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous');
% dbstop if error
% strPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% strSavePath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\features\';%LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% strNucleiMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% flag_nuclei_cluster_finding=0;
% image_format='.png';
% para_nulei_scale_low=0;
% para_nulei_scale_high=0;
% flag_have_nulei_mask=1;
% 
% strWSIPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\';
% 
% % str_im='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% % str_epi='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% % str_nuclei='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_seg\';
% % str_nuclei_clumpsplit='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% idx=162129;
% Lextractfeature_v15_get_im_on_the_fly(idx,idx,strWSIPath,1,strPath,strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high)
%%
% %% debug v15
% addpath('F:\Nutstore\Nutstore\PathImAnalysis_Program\Program\Miscellaneous');
% dbstop if error
% strPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% strSavePath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\features\';%LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% strNucleiMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% flag_nuclei_cluster_finding=0;
% image_format='.png';
% para_nulei_scale_low=0;
% para_nulei_scale_high=0;
% flag_have_nulei_mask=1;
% 
% % str_im='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% % str_epi='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% % str_nuclei='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_seg\';
% % str_nuclei_clumpsplit='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% idx=6128;
% Lextractfeature_v15(idx,idx,1,strPath,strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,image_format,0,0,1,0,para_nulei_scale_low,para_nulei_scale_high)

%% debug v13
% strPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% strSavePath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\features\';LcreateFolder(strSavePath);
% strEpiStrMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% strNucleiMaskPath='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% flag_nuclei_cluster_finding=0;
% image_format='.png';
% para_nulei_scale_low=0;
% para_nulei_scale_high=0;
% flag_have_nulei_mask=1;
% 
% % str_im='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\all_tiles\';
% % str_epi='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\epi_seg\';
% % str_nuclei='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_seg\';
% % str_nuclei_clumpsplit='Z:\JHU_WU_Oropharyngeal_WSI_ITH\tiles_2048@40x\nuclei_set_clump_split\';
% Lextractfeature_v13(1,1,1,strPath,strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,image_format,0,0,0,0,para_nulei_scale_low,para_nulei_scale_high)
% 
% 
% % strPath='Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\debug_purpose\';
% % strSavePath='Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\debug_purpose\';
% % strEpiStrMaskPath='Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\debug_purpose_EP\';
% % strNucleiMaskPath='Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\processed_nuclei_mask_by_zlDL\binary_output\';
% % flag_nuclei_cluster_finding=0;
% % image_format='.tif';
% % para_nulei_scale_low=0;
% % para_nulei_scale_high=0;
% % flag_have_nulei_mask=1;
% % Lextractfeature_v13(1,1,1,strPath,strSavePath,strEpiStrMaskPath,strNucleiMaskPath,flag_have_nulei_mask,flag_nuclei_cluster_finding,image_format,0,0,0,0,para_nulei_scale_low,para_nulei_scale_high)
% 
% 
% % I=imread('Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\debug_purpose\OP152_B.tif_tile4.tif');
% % bw=zeros(size(I,1),size(I,2));
% % bw(1:2000,1:2000)=1;%show(bw)
% % imwrite(bw,'Z:\Vanderbilt_Oroph_TMA_Lewis\New_extraction_TMA\TIFs\debug_purpose_EP\OP152_B.tif_tile4.png');
