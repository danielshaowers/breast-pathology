svs_filename = 'D:\AI_Lab\Repo\ECOG_Breast\1000698.svs';
addpath('D:\AI_Lab\Repo\ECOG_Breast');
addpath(genpath('D:\AI_Lab\Relevant Matlab\ChengCode'));
xml_filename = '1000698.xml';
find_tumor(svs_filename, xml_filename, [2048 2048]);