dbstop if error
addpath(genpath(pwd)); % add dependency path
%load crossVal.mat %variable named all
load compilation.mat %variable named compilation
load d:/pathology/features/1000647/1000647_54615_55767/allFeatsNames.mat %variable called allDescription
%if ~exist('crossVal.mat')
data = compilation.data;
labels = compilation.labels;
survival = compilation.survival;
nans = [];
for i=1:length(data)
    standard = std(data(:,i));
    if any(isnan(data(:,i))) || all(data(1,i) == data(:,i)) || standard <=(length(data) * eps(standard)) || length(find(data(1,i) == data(:,i))) >= 0.75*length(data(:,i)) %daniel: completely removed one feature family, which gives me some problems. 
        nans = [nans i];
    end
end
data(:,nans) = []; %should do ~all but that might still give me problems
alldescription(nans) = [];
groups = ["BasicShape-", "CRL", "FeDeG", "FD", "Voronoi", "Delaunay", "MST", "Arch", "Morph", "CGT", "CCG", "Harralick"]; %daniel: BasicShapeinCCG was removed!!

for i=1:length(groups)
    out = strncmp(groups(i), alldescription, strlength(groups(i))); 
    findout = find(out); %nonzero entries
    data_struct(i).group = groups(i);
    data_struct(i).data = data(:, findout); %all rows, but only the columns for our current group
    data_struct(i).names = (alldescription(findout)); %this one is a column vector (unfortunately, we want it as a row vector i think?)
end
%generate struct for training data

%% 1**** try different classifier and feature combination in cross validation
para.intFolds=3;
para.intIter=10;
para.num_top_feature=3;
para.get_balance_sens_spec=1;
para.balanced_trainset=1;

% para.set_classifier={'LDA','BaggedC45'};
% para.set_featureselection={'ttest','mrmr'};
% commented out  by daniel so that we use every combination
%para.set_classifier={'LDA','QDA','BaggedC45'}; 
%para.set_featureselection={'wilcoxon','ttest','mrmr'};
para.set_classifier={'LDA','QDA','BaggedC45'};
para.set_featureselection={'wilcoxon','mrmr','rf','ttest'};

para.correlation_factor=0.9;

% -data should be a m x n matrix, in which m is the patient number and n is
% the feature number
% -labels is a vector to indicate the outcome, normally set to 0 or 1
% 
%labels = classes;
%feature_list=ones(1,size(data,2));%dummy one if unavaliable
feature_list = alldescription;
[resultACC,resultAUC,result_feat_ranked,result_feat_scores,result_feat_idx_ranked]=Leveluate_feat_using_diff_classifier_feature_selection(data,labels,feature_list,para);
T=Lget_classifier_feature_slection_performance_table(resultACC,resultAUC,para);
T=table2array(T);
adjustedT(:,1)= T(:,1);
for i=1:12 
     adjustedT(i,2) = strrep(T(i,2),'$\pm$',' +/- ');
     adjustedT(i,3) = strrep(T(i,3),'$\pm$',' +/- '); 
     adjustedT(i,4) = strrep(T(i,4),'$\pm$',' +/- '); 
     adjustedT(i,5) = strrep(T(i,5),'$\pm$',' +/- '); 
end
save table.mat adjustedT
step1_findtop.para = para;
step1_findtop.resultACC = resultACC;
step1_findtop.resultAUC = resultAUC;
step1_findtop.result_feat_ranked=result_feat_ranked;
step1_findtop.result_feat_scores = result_feat_scores;
step1_findtop.result_feat_idx_ranked = result_feat_idx_ranked;
step1_findtop.performance_table = T;
save crossVal.mat step1_findtop

sprintf('look at T to see your result !!')
%% 2**** if you want to use leave one out to get the predicted labels, use the code below
% para.featureranking='mrmr';
% para.num_top_feature=5;
% para.classifier_name='LDA';
% para.T_on_predicted_pro=0.5;
% para.feature_selection_mode='cross-validation';%'one-shot'; %
% para.feature_list=feature_list;
% 
% [labels_pred,probability_pred,result]=Lgenerate_Predicted_Label_leave_one_out(data,labels,para);

%% %%%%%%%%%%%%%%%% test these groups of features in terms of mean AUC, for all eipstroma combined classifiers C_epistroma
% set_feature_group_name={'basicgraph','morph','CGT','CCG','BS','BSinCCG','CRL','fractal','oriCCM','CCM','FeDeG'};
set_feature_group_name={'basicgraph','morph','CGT','CCG','BS','BSinCCG','CRL','HarralickNuWise','cCCM48','cCCM44','CCM48','FeDeG'};
index_POI_indata_all=~isnan(labels);

set_feature_group_meanAUC=[];
set_feature_group_scores=[];% record the feature score within each feature group
set_feature_group_result=[];% record the AUC within each feature group
set_feature_group_top_feature_idx=[];
set_feature_group_top_feature_names=[];

num_top_feature=4;
 
para.feature_score_method='addone'; %do I want addone?
% para.classifier='LDA';
%para.classifier='LDA';
 para.classifier='BaggedC45';
%para.featureranking='wilcoxon';
para.featureranking ='mrmr';
para.correlation_factor=.9; %what is correlation factor?
para.balanced_trainset=0;
para.get_balance_sens_spec=1;
intIter=10;%run number
intFolds=3;%fold number
num_top_features2keepinrecord=30;% top features keep in record

% sum(isnan(cur_data));
%create an array with the index corresponding to the feature group name
for i=1:length(data_struct)
    cur_feature_group=groups(i);
    cur_data = data_struct(i).data; %maybe these will fix things?
    cur_feature = data_struct(i).names;
   % cur_feature_list=eval(sprintf('feature_list_%s',cur_feature_group));
    if ~strcmp(cur_feature_group,'fractal')
         para.num_top_feature=num_top_feature;
          [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5_daniel(cur_data,...
              labels(index_POI_indata_all), cur_feature,para,1,intFolds,intIter);

         cur_score=set_feature_group_scores{i};
         [val,idx]=sort(cur_score,'descend'); %gives us the index of the top features that we want to keep
         set_feature_group_top_feature_idx{i}=idx(1:min(num_top_features2keepinrecord, length(idx)));
         set_feature_group_top_feature_names{i}=cur_feature(idx(1: min(length(idx), num_top_features2keepinrecord)))'; %gets top feature names
    else
        para.num_top_feature=min(num_top_feature,3);
        [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5_daniel( cur_data(index_POI_indata_all,:),...
            labels(index_POI_indata_all), cur_feature_list,para,1,intFolds,intIter);
        cur_score=set_feature_group_scores{i};
        [val,idx]=sort(cur_score,'descend');
        set_feature_group_top_feature_idx{i}=idx(1:para.num_top_feature); %index 85 is the one causing a problem
        set_feature_group_top_feature_names{i}=cur_feature_list(idx(1:para.num_top_feature))';
    end
    set_feature_group_meanAUC(i)=mean([set_feature_group_result{i}.AUC]);
end
%% commented out because i don't understand the purpose and eval is giving me probelms
% for i=1:length(set_feature_group_name)
%     cur_feature_group=set_feature_group_name{i};
%    cur_data=eval(sprintf('data_%s',cur_feature_group));
%    cur_feature_list=eval(sprintf('feature_list_%s',cur_feature_group));
%     if ~strcmp(cur_feature_group,'fractal')
%          para.num_top_feature=num_top_feature;
%          [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5_daniel( cur_data(index_POI_indata_all,:),...
%              labels(index_POI_indata_all), cur_feature_list,para,1,intFolds,intIter);
% 
%          cur_score=set_feature_group_scores{i};
%          [val,idx]=sort(cur_score,'descend');
%          set_feature_group_top_feature_idx{i}=idx(1:num_top_features2keepinrecord);
%          set_feature_group_top_feature_names{i}=cur_feature_list(idx(1:num_top_features2keepinrecord))';
%     else
%         para.num_top_feature=min(num_top_feature,3);
%         [set_feature_group_result{i},set_feature_group_scores{i}] = nFold_AnyClassifier_withFeatureselection_v5( cur_data(index_POI_indata_all,:),...
%             labels(index_POI_indata_all), cur_feature_list,para,1,intFolds,intIter);
%         cur_score=set_feature_group_scores{i};
%         [val,idx]=sort(cur_score,'descend');
%         set_feature_group_top_feature_idx{i}=idx(1:para.num_top_feature);
%         set_feature_group_top_feature_names{i}=cur_feature_list(idx(1:para.num_top_feature))';
%     end
%     set_feature_group_meanAUC(i)=mean([set_feature_group_result{i}.AUC]);
% end
%% check the top features in each feature family
idx_good_family=find(set_feature_group_meanAUC>0.5); %daniel: changed from 0.59 -> this gets only the families that are good enough on average. 0.48 is v inclusive
%%idx_good_family(idx_good_family(:) == 2) = [];
set_feature_group_top_feature_idx_good=set_feature_group_top_feature_idx(idx_good_family); %the _idx on the rhs is cell array of all families, we get the good ones only
set_feature_group_top_feature_names_good=set_feature_group_top_feature_names(idx_good_family); %specific top 30 features in each good feature family
%%% plot out the top features, each family has one figure
%set_feature_group_name_good=set_feature_group_name(idx_good_family);
set_feature_group_name_good=groups(idx_good_family); %now we have the top feature families
%not sure what the diff between names and name is.
%figure(11);


for i=1:length(set_feature_group_name_good) %go through all the feature families with a high enough AUC
    figure(i);
    cur_feature_group=set_feature_group_name_good{i};
    title(sprintf('%s', cur_feature_group));
    for j=1:num_top_feature
        %subplot(length(set_feature_group_name_good),num_top_feature,num_top_feature*(i-1)+j);
        subplot(2, num_top_feature/2,j);
        curfeatidx=set_feature_group_top_feature_idx_good{i}; %does this select the top feature? or just the first four features
        cur_data = data_struct(idx_good_family(i)).data;
%         cur_data=eval(sprintf('data_%s',cur_feature_group));
        curfeat=cur_data(:,curfeatidx(j));
        curfeat_valid=curfeat(index_POI_indata_all);
        label_valid=logical(labels(index_POI_indata_all));
        vs = violinplot(curfeat_valid, label_valid);
        ylabel(set_feature_group_top_feature_names_good{i}{j});
        
        % misc

%         [h,p]=ttest2(v_PCA(group==1),v_PCA(group==2));
        [p,~] = ranksum(curfeat_valid(label_valid),curfeat_valid(~label_valid));
        if p>0.00001
            xlabel(sprintf('N=%d, p=%f',length(label_valid),p));
        else
            xlabel(sprintf('N=%d, p<0.00001',length(label_valid)));
        end
%         xlim([0.5, 7.5]);

%         set(h,{'linew'},{2});
        set(gca,'FontSize',12);
%         set(findobj(gca,'Type','text'),'FontSize',50,'fontweight','bold');
    end
end
save find_top_features_prev.mat 
%% maybe i could save the features with the lowest p values? currently i limited 
%% 3****build classifiers using selected features from training set
%%% build the final classifer using QDA
%get the validation vs training set: keeping ratio as 1:1 until I know what i'm doing
ratio = 8/2; %training:validation ratio. ideally should be <1, but num training must be > max features in a family
random = round(rand(size(labels))*ratio); % approx 50% ones, 50% zeroes
validation = find(random == 0); 
training = find(random ~= 0); %now we have indices corresponding to which rows should be training, which for validation
length(find(labels))
data_train = data(training, :);
labels_train = labels(training, :);
data_validate = data(validation, :); %THIS IS WHAT I NEED TO CHANGE. LIMIT THE COLUMNS HERE, CHECK W/ set_feature_group_top_feature_idx_good
labels_validate = labels(validation, :);
%findout = zeros(size(alldescription));
max_feats_per_fam = floor(length(labels_train) / length(set_feature_group_top_feature_idx_good)); %the max number of features from one family, since we need fewer features than training data
max_feats_per_fam = 4;
for i=1:length(idx_good_family)
    sortedIndices = set_feature_group_top_feature_idx_good{i}(1:min(max_feats_per_fam, length(set_feature_group_top_feature_idx_good{i})));
   % while ~isempty(sortedIndices) %another easier thing I could do is just skip it, don't even worry about replacing it. because its replacement is probably even worse 
        family_name = groups(idx_good_family(i)); %name of the top feature family
        out = strncmp(family_name, alldescription, strlength(family_name)); %gets indices of which columns correspond to our feature family
        fam_indices = find(out); %gives the indices of our feature family        
         %if isempty(failed) %if all of the standard deviations are high enough, then we move on.
            if (i == 1)
                findout = fam_indices(sortedIndices);
            else
                findout = [findout; fam_indices(sortedIndices)]; %finds the specific indices we're interested in
            end
%             break;
%         end
      %  sortedIndices(failed) = []; %if it wasn't high enough, then we 
%    end
end
%findout = find(findout);
train_data = data_train(:, findout); %all rows from training set but only these columns
stdev = std(train_data); %row vector of standard deviations 

failed = find(stdev <= length(labels_train)*max_feats_per_fam * eps(max(stdev)));
if ~isempty(failed)
    sortedIndices(failed) = [];
end
validation_data = data_validate(:, findout);
T_predict=0.5; % threshold on the predicted probability obtain by the classifier

% data_validation - is the data from validation set, in which the feature
% dimension is the same as the the training data (only keep the slected features)
% labels - is a vector, with 0 and 1
try 
  %  [~,~,probs,~,c] = classify(validation_data,train_data,labels,'quadratic'); 
    [~,~,probs,~,c] = classify(validation_data,train_data,labels_train,'quadratic');
catch err
    %[~,~,probs,~,c] = classify(validation_data,train_data,labels,'diagquadratic'); 
    [~,~,probs,~,c] = classify(validation_data,train_data,labels_train,'diagquadratic'); 
end
label_qda=zeros(size(validation_data,1),1);
label_qda(probs(:,2)>T_predict)=1;
% sum(label_qda)


%%% build the final classifer using LDA
try 
    [~,~,probs,~,c] = classify(validation_data,train_data,labels_train,'linear'); 
catch err
    [~,~,probs,~,c] = classify(validation_data,train_data,labels_train,'diaglinear'); 
end

label_lda=zeros(size(validation_data,1),1);
label_lda(probs(:,2)>T_predict)=1;
% sum(label_lda)


%%% build the final classifer using RF
%data_train=good_featuregroup_data;
%data_validation=good_featuregroup_data; %these don't exist...? daniel -
%commented out
data_train = train_data;
data_validation = validation_data;
methodstring = 'BaggedC45';
options = statset('UseParallel','never','UseSubstreams','never');
C_rf = TreeBagger(50,data_train,labels_train,'FBoot',0.667,'oobpred','on','Method','classification','NVarToSample','all','NPrint',4,'Options',options);    % create bagged d-tree classifiers from training

[Yfit,Scores] = predict(C_rf,data_validation);   % use to classify testing
% [Yfit,Scores] = predict(C_rf,data_train);   % use to classify testing
label_rf=str2double(Yfit); %daniel changed from label_lda
% sum(label_lda)
% accuracy_RF_reuse=sum(label_lda==labels')/length(labels);

%% 4**** check the classification perfromance in test set: compares our prediction to the actual results
%[recall,specificity,accuracy]=Lcal_recall_spe_acc(groundtruth_label,predicted_label); %check accuracy for each of the classifiers i think
[recall_qda,specificity_qda,accuracy_qda]=Lcal_recall_spe_acc(labels_validate,label_qda);
[recall_lda,specificity_lda,accuracy_lda]=Lcal_recall_spe_acc(labels_validate,label_lda);
[recall_rf,specificity_rf,accuracy_rf]=Lcal_recall_spe_acc(labels_validate,label_rf);
%% 5**** check the KM curve
