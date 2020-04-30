%42 images total. 
function extract_all_images_2
% addpath(genpath('/home/dxs765'));
% addpath(genpath('/home/dxs765/ChengCode'));
% addpath(genpath('/home/dxs765/Current_Project'));
% addpath(genpath('/home/dxs765/Feature_Extraction'));
% addpath(genpath('/home/dxs765/First_Project/Code'));
cd ..;
%cd 'D:\AI_Lab\Relevant_Matlab'
addpath(genpath(sprintf('%s/Current_Project', pwd)));
addpath(genpath(sprintf('%s/Feature_Extraction', pwd)));
addpath(genpath(sprintf('%s/First_Project/Code', pwd)));
addpath(genpath(sprintf('%s/ChengCode', pwd)));
addpath(sprintf('%s/ChengCode/Utilities-master', pwd));
path = '/mnt/rstor/CSE_BME_AXM788/data/ECOG_Breast';
%path = 'D:\AI_Lab\Repo\ECOG_Breast';
dirSVS = dir(sprintf('%s/**/*.svs', path)); %don't search subfolders, it finds this hidden one called appledouble that causes probs 
%dirXML = dir(sprintf('%s/**/*.xml', path));
dirXML = dir(sprintf('%s/new annotation/*.xml', path));
%I could do this with dir image, then checking the name
foundList = [1000625,  1000626,  1000627,  1000629,  1000630, 1000631, 1000639, 1000640, 1000641, 1000644,  1000659,  1000660,  1000661,  1000662,  1000663,  1000665,...
    1000668,  1000670,  1000698,  10006708, 1000940, 1000942, 1000966,  1000967,  1000968,  1000969,  1000970,  1000971,  1000972,  1000973,  1000974  1000975,  1000976,  1000977,  1000978,  1000979,  1000985];
errorFile = fopen('errors.txt', 'w');
%for y = 1: size(dirXML)
for y = 1:size(dirXML)
    %unwantedFolder = regexp(dirXML(y).folder, ('new annotation' | '.AppleDouble')); %finds first occurrence of either.
    unwantedFolder = regexp(dirXML(y).folder, '.AppleDouble');
        xml_name = extractBetween(dirXML(y).name, 1, strlength(dirXML(y).name) - 4);
        found = false;
        for x = 1: size(dirSVS)  
            svs_name = extractBetween(dirSVS(x).name, 1, strlength(dirSVS(x).name) - 4); %gets the image number without file type
            if (strcmp(svs_name, xml_name) & size(unwantedFolder) == 0) & ~any(foundList == str2double(xml_name)) %skip the new annotation folder
                try
                    found = true;
                    extractFeat_single(sprintf('%s/%s', dirSVS(x).folder, dirSVS(x).name), sprintf('%s/%s', dirXML(y).folder, dirXML(y).name), errorFile);
                catch ME
                    errorMessage = sprintf('error in extractFeat_single: %s\n%s\n%s found but feature extraction failed, skipping \n', ME.message, ME.identifier, dirSVS(x).name);
                    warning(errorMessage);
                    fprintf(errorFile, errorMessage);
                    continue
                end
            end
        end
     if ~found
       fprintf(errorFile,'svs of %s not found. Skipping\n', svs_name);
     end
    end


fclose(errorFile);

