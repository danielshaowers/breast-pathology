%% get all features into one mat file
%data struct formed from a cell vector of feature values
%traverse along the 2nd (row dimension) when using cell2struct
%rows=each patient, column=one feature
%% note: for this to work, the folder containing the features must not have any folders or files that are not feature values
% the final output, compilation, has the features and outcomes
% corresponding to the order they appear in my features folder, not the
% compiled_data folder
path = 'D:/Pathology/Features';
%dirFeatures = dir(sprintf('%s/**/*.mat', path));
idList = dir(path); 
%how do I get the values saved in features? figure it out when i'm not lazy
featVals = sprintf('note to self. get the values of the features all in one array');
dirPatients = 'D:/Pathology/Training_Data/Compiled_Data';
survivalCol = 16;
idCol = 2;
[numbers, strings, ~] = xlsread(dirPatients); %read the xlsx file for patient outcomes. strings is a cell array
map = containers.Map('KeyType', 'double', 'ValueType', 'double');
dbstop if error
for x = 1: length(numbers(:, idCol)) %we want the the second column which corresponds to the slide IDs
    if (isnan(numbers(x,idCol))) 
        fullString = strings{x+1,idCol}; %smooth parentheses gives a subcell array. curly gives the contents. strings has the labels of each, numbers doesn't so off by 1
        splitInd = regexp(fullString, ';'); %gives the index of every semicolon
        for y = 1: length(splitInd)
            id = extractBetween(fullString, splitInd(y) - splitInd(1), splitInd(y), 'Boundaries', 'exclusive'); 
            map(str2double(id)) = numbers(x, survivalCol); %key is the id, val is the health outcome
        end
        if (~isempty(fullString)) %there are some cases where no ID is provided
            id = extractBetween(fullString, splitInd(y), length(fullString)+1, 'Boundaries', 'exclusive'); %also adds the last id
            map(str2double(id)) = numbers(x, survivalCol);
        end
    else
       map(double(numbers(x, idCol))) = numbers(x, survivalCol);    
    end
end
compilation = struct('data', zeros(length(idList)-2, 4776), 'labels', zeros(length(idList)-2, 1)); %4776 is num features
for z = 3 : length(idList) %get the name and all 5 allFeats .m files for all slides. idList = dir of slides
    currSlide = idList(z); %start at 3 bc index 1 and 2 are just dots
    if (~strcmp(currSlide.name, '.') && ~strcmp(currSlide.name, '..') && currSlide.isdir)
        listAllFeats = dir(sprintf('%s/%s/**/*allFeats.mat', currSlide.folder, currSlide.name)); %struct all 5 allFeat files 
        one_allFeat = load(sprintf('%s/%s', listAllFeats(1).folder, listAllFeats(1).name)); %gets a struct of values in allFeats
        featLoad = zeros(length(one_allFeat(1).allFeats), length(listAllFeats)); %preallocate size for speed. num allFeats=cols. total feats = rows
        featLoad(:,1) = featLoad(:,1) + one_allFeat(1).allFeats; %transpose to row vector
        for y = 2:length(listAllFeats)
            one_allFeat = load(sprintf('%s/%s', listAllFeats(y).folder, listAllFeats(y).name));
            featLoad(:,y) = featLoad(:,y) + one_allFeat(1).allFeats; %add the allFeats to its corresponding column
        end
        compilation(1).data(z-2,:) = mean(featLoad, 2)'; %the average of each feature in a col vector, transposes to get a row vector
        compilation(1).labels(z-2, 1) = map(str2double(currSlide.name)); %adds as a row w/ semicolon. adds survival (0 or 1)
    else
        sprintf('deleted row %d', z) %this doesn't work sadly
        compilation(1).data(z,:) = [];
        compilation(1).labels(z,:) = [];
    end
end
save compilation.mat compilation
sprintf('completed')