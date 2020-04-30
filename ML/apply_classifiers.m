load find_top_features_prev.mat
ratio = 7/3; %training:validation ratio. ideally should be <1, but num training must be > max features in a family
random = round(rand(size(labels))*ratio); % approx 50% ones, 50% zeroes
validation = find(random == 0); 
training = find(random ~= 0); %now we have indices corresponding to which rows should be training, which for validation
length(find(labels))
data_train = data(training, :);
labels_train = labels(training, :);
data_validate = data(validation, :); %THIS IS WHAT I NEED TO CHANGE. LIMIT THE COLUMNS HERE, CHECK W/ set_feature_group_top_feature_idx_good
labels_validate = labels(validation, :);
survival_validate = survival(validation, :); %only these rows
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
[recall_qda,specificity_qda,accuracy_qda]=Lcal_recall_spe_acc(labels_validate,label_qda); %accuracy=True positive rate TP/(TP+FN)
[recall_lda,specificity_lda,accuracy_lda]=Lcal_recall_spe_acc(labels_validate,label_lda); %specificity=true negative rate TN/(TN+FP)
[recall_rf,specificity_rf,accuracy_rf]=Lcal_recall_spe_acc(labels_validate,label_rf);     %precision= correct positive vs total items as positive TP/(TP+FP)
%% 5**** check the KM curve
%% our KM curve defines an event as death, grouping based on how our classifier predicted survival
%vlabel = zeros(size(labels_validate));
all_labels = [label_qda, label_lda, label_rf];
for i=1: length(all_labels) 
    for j=1:3
        if all_labels(i,j) == 0 
            vlabel(i, j) = {'No Death'};
        else
            vlabel(i, j) = {'Death'};
        end
    end
end
MatSurv(survival_validate, labels_validate, vlabel(:,1), 'EventDefinition', {'Dead', 'Alive'}, 'GroupsToUse', {'No Death', 'Death'}, 'Title', 'Linear Discriminant Analysis'); %times to event, label of event or censored, grouping variable
MatSurv(survival_validate, labels_validate, vlabel(:,2), 'EventDefinition', {'Dead', 'Alive'}, 'GroupsToUse', {'No Death', 'Death'}, 'Title', 'Quantitative Descriptive Analysis');
MatSurv(survival_validate, labels_validate, vlabel(:,3), 'EventDefinition', {'Dead', 'Alive'}, 'GroupsToUse', {'No Death', 'Death'}, 'Title', 'Random Forest');
%still need to understand what the risk table and its values mean