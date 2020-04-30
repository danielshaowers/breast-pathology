function [training testing] = select_training_nostratify(data_set, data_labels, shuffle,n)

if n >= length(data_labels)
    error('Must have fewer training samples than total samples!');
end

data_labels = data_labels(:);

% 1. First, we acquire the training set, training labels, testing set and testing labels.
%    For this, we will divide our data set in two. We will find positive (a)
%    and negative (b) examples to create a balanced training set.

a = find( data_labels >  0 );
b = find( data_labels <= 0 );

if n > numel(a) || n > numel(b)
    error('There are insufficient samples in one of the classes to select %i samples.',n);
end

if shuffle
    % commit a random portion of the dataset for training
    a_shuffle = randperm(length(a));    %randomize index
    b_shuffle = randperm(length(b));    %randomize index
else
    % or don't shuffle
    a_shuffle = 1:length(a);    %same index
    b_shuffle = 1:length(b);    %same index
end


testing = cell(1);
training = cell(1);

% stratify
% a_prop = round(n * length(a) / length(data_labels));
% b_prop = n - a_prop;
a_prop = n;
b_prop = n;

% get indices
a_values = a(a_shuffle(1:a_prop));
b_values = b(b_shuffle(1:b_prop));
values = [a_values ; b_values];

a_notvalues = a(a_shuffle(a_prop+1:end));
b_notvalues = b(b_shuffle(b_prop+1:end));
notvalues = [a_notvalues ; b_notvalues];

% set output
testing{1} = notvalues;
training{1} = values;