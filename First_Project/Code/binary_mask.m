function [nuclei_range] = binary_mask(image_array, row, col)

%binary_mask segments nuclei and creates a binary mask outlining tumor region

%%segment nuclei, then apply binary mask
% turn black into white to reduce the normolization effect, from line 169
% Lextractfeature17


%%nuclei segmentation portion


 % turn black into white to reduce the normolization effect
 %in original code, I = curTile. here we replace I with the entire image

    bbw=image_array(:,:,1)<2;%show(bbw);
    r=image_array(:,:,1);g=image_array(:,:,2);b=image_array(:,:,3);
    r(bbw)=255;g(bbw)=255;b(bbw)=255;
   image_array=cat(3,r,g,b);
    [image_array_norm, ~, ~] = normalizeStaining(I);
   image_array_normRed=image_array_norm(:,:,1);
    p.scales=[2:2:16];
%  p.scales=[para_nulei_scale_low:2:para_nulei_scale_high];
              
    disp('begin nuclei segmentation;');
    [nuclei, properties] = nucleiSegmentationV2(image_array_normRed,p);  
    [nuclei, properties]=LremoveFalsePositive_from_contour_v2(nuclei,properties,image_array);
                %%% ommitted code to save results
     [m,n,k]=size(image_array);
                    bwNuclei=zeros(m,n);
                    for kk = 1:length(nuclei)
                        nuc=nuclei{kk};
                        for kki=1:length(nuc) %square
                            bwNuclei(nuc(kki,1),nuc(kki,2))=1;
                        end
                    end
                    bwNuclei = imfill(bwNuclei,'holes');
                             show(bwNuclei);
                    save(strSave,'bwNuclei');
                    disp('nuclei binary image file saved');
     %%find the max and min pixels where the nuclei are
     
      nuclei_epi=nuclei(nuclei_label);
                    bwNuclei_epi= false(m,n);
                    for tt=1:length(nuclei_epi)
                        curN=nuclei{tt};
                        for ttt=1:length(curN)
                            bwNuclei_epi(curN(ttt,1),curN(ttt,2))=1;
                        end
                    end
                    bwNuclei_epi = imfill(bwNuclei_epi,'holes');    %         show(bwNuclei_epi);
                    
                    bwNuclei_stroma=bwNuclei-bwNuclei_epi;
              
        
       
                
end
            