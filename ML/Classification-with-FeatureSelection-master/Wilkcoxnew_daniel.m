function [a b] = Wilkcoxnew_daniel(datafile, trainlabel)
%   This file prints an array of the discriminatory features
%   datafile = 'ovarian_61902.data'
%   xvalues = 'ovarian_61902.names2.csv'

i1 = min(trainlabel);
i2 = max(trainlabel);
ind1 = find(trainlabel ==i1); %changed by Daniel Shao from 1 and 2 to fit 0 and 1 labels
ind2 = find(trainlabel ==i2);
controldata = datafile;
cancerdata = datafile;
controldata(ind1,:) = []; %deletes these columns
cancerdata(ind2,:) = []; %deletes these columns

% nanIdx = find(all(isnan(controldata),2)); %find all nan columns in controldata. 
% controldata(:, nanIdx) = []; %do I need to delete the corresponding values in cancerdata? i think i do
% cancerdata(:, nanIdx) = [];
%nanIdx = find(all(isnan(cancerdata), 2)); 


%lx = size(controldata);
lx = size(datafile, 2);
s1 = zeros(1,lx);
for i=1:lx
    try
    [P,H, stat] = ranksum(controldata(:,i),cancerdata(:,i));
    catch ME
       controldata(:,i)
       cancerdata(:,i)
    end
    [P,H, stat2] = ranksum(cancerdata(:,i),controldata(:,i));

    s1(i) = min(stat.ranksum,stat2.ranksum);
    %s1(i) = P.*-1;
    s1(i) = P;
end
[a b] = sort(s1,'ascend');
%[a b] = sort(s1,'descend');