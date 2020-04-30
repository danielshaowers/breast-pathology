addpath('D:\AI_Lab\Repo\ECOG_Breast');
addpath(genpath('D:\AI_Lab\Relevant Matlab'));
xml = '1000698.xml';
svs = '1000698.svs';
queryPoints = 3;
%block_size = [10000 10000]; %I could also calculate a good size based on svs image size
%outline = visualizeTumor(svs, xml, resize_amt, graph_dimensions);
dbstop if error;
outline = writeTumorMask(svs, xml, queryPoints);
imshow(outline);
imwrite(outline, 'D:\AI_Lab\Images\1000698_4_1.png');