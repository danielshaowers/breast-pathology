load optimal_outcome.mat
[recall_qda,specificity_qda,accuracy_qda]=Lcal_recall_spe_acc(labels_validate,label_qda);
[recall_lda,specificity_lda,accuracy_lda]=Lcal_recall_spe_acc(labels_validate,label_lda);
[recall_rf,specificity_rf,accuracy_rf]=Lcal_recall_spe_acc(labels_validate,label_rf);

 %generate the AUC?
 %definitely generate the KM curve
 %Generate a table for this at the very least
 table = [accuracy_qda, recall_qda, specificity_qda; accuracy_lda, recall_lda, specificity_lda; accuracy_rf, recall_rf, specificity_rf;];
 T = array2table(table,...
    'VariableNames',{'Accuracy' 'Specificity' 'Sensitivity'});
T2 = {'QDA'; 'LDA'; 'RF'};
T2 = cell2table(T2, 'VariableNames', {'Classifier'});
T = [T2 T]