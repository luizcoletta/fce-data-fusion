function [labels, piSet, SSet, resFiles] = CLJavaMLA(data4Class, data4Clust, validation)

% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11res.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11res-bal.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11res-bal-cfs.arff', 0)

% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res05.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res1.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res2.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res5.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res10.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res20.arff', 0)
% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res30.arff', 0)

% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb_11-bal9-res2-imb.arff', 0)

% [labels, piSet, SSet, resFiles] = runJavaMLA_STSC3E('', 'ceratocystis_test_90_10_rgb-11-017-980-003-5.arff', 0)

resFiles = [];

% set data for classification
trainDataPath = ''; % [pwd, '/leaves-train.arff'];
if (nargin >= 1)
    if (size(data4Class,2) > 1)
        trainDataPath = data4Class;
    end
end 

% set data for clustering
testDataPath = [pwd, '/leaves-test.arff'];
if (nargin >= 2)
    if (size(data4Clust,2) > 1)
        testDataPath = data4Clust;
    end
end

%---------------------%
% CLASSIFIER ENSEMBLE %
%---------------------%

            % NB J48 KNN SVM BayesNet Logistic MLP SimpleLogistic RandomForest
typeClaEns = [0, 0,  0,  0,  0,       0,       0,  0,             0];

%------------------%
% CLUSTER ENSEMBLE %
%------------------%

%2: strategy 2 based on SimpleKMeans from WEKA
%3: stragegy based on KMedoids from ELKI
strategyCluEns = 2;

% for strategy 2: subset of features size (1 = 10%, 2 = 20%, ... from the original)
viewSize = 3; %3;

% for strategy 2 and 3: number of partitions (1, 2, ...); for 0, it doesn't run clustering
numPartitions = 6; %6;

strmc = '0'; 
strni = '-1';
iter = '0';

if (validation == 0)
   sFCAE = ['_', data4Class, strmc, strni, iter, num2str(typeClaEns(1)), num2str(typeClaEns(2)), num2str(typeClaEns(3)), num2str(typeClaEns(4)), num2str(typeClaEns(5)), num2str(typeClaEns(6)), num2str(typeClaEns(7)), num2str(typeClaEns(8)), num2str(typeClaEns(9))];
   sFCUE = ['_', data4Class, strmc, strni, iter, num2str(strategyCluEns), num2str(viewSize), num2str(numPartitions)];
else
   sFCAE = ['_', data4Class, 'R', strmc, strni, iter, num2str(validation), num2str(typeClaEns(1)), num2str(typeClaEns(2)), num2str(typeClaEns(3)), num2str(typeClaEns(4)), num2str(typeClaEns(5)), num2str(typeClaEns(6)), num2str(typeClaEns(7)), num2str(typeClaEns(8)), num2str(typeClaEns(9))];
   sFCUE = ['_', data4Class, 'R', strmc, strni, iter, num2str(validation), num2str(strategyCluEns), num2str(viewSize), num2str(numPartitions)];
end
labelFile = [pwd, '/results/labels', sFCAE, '.dat'];
piSetFile = [pwd, '/results/piSet', sFCAE, '.dat'];
if (exist(labelFile, 'file') && exist(piSetFile, 'file'))
    typeClaEns(1) = 0;
    typeClaEns(2) = 0;
    typeClaEns(3) = 0;
    typeClaEns(4) = 0;
    typeClaEns(5) = 0;
    typeClaEns(6) = 0;
    typeClaEns(7) = 0;
    typeClaEns(8) = 0;
    typeClaEns(9) = 0;
end 

SSetFile = [pwd, '/results/SSet', sFCUE, '.dat'];
if (exist(SSetFile, 'file'))
    numPartitions = 0;
end

% load java classes
javaaddpath({[pwd, '/javamla/lib/weka-3.9.1-SNAPSHOT.jar']});
javaaddpath({[pwd, '/javamla/lib/elki-bundle-0.7.1.jar']});
javaaddpath({[pwd, '/javamla/']});

ensemble = RunEnsembleSuppliedTestSet;

claEns = java.util.ArrayList;
claEns.add(java.lang.Integer(typeClaEns(1))); % NB
claEns.add(java.lang.Integer(typeClaEns(2))); % J48
claEns.add(java.lang.Integer(typeClaEns(3))); % IB5
claEns.add(java.lang.Integer(typeClaEns(4))); % SVM
claEns.add(java.lang.Integer(typeClaEns(5))); % BayesNet
claEns.add(java.lang.Integer(typeClaEns(6))); % Logistic
claEns.add(java.lang.Integer(typeClaEns(7))); % Multilayer Perceptron
claEns.add(java.lang.Integer(typeClaEns(8))); % SimpleLogistic
claEns.add(java.lang.Integer(typeClaEns(9))); % RandomForest

% Run JAVAMLA to generate classifier and clusterer ensembles. Results will
% be saved in 'piSet.dat' and 'SSet.dat', respectively. The file 'labels.dat'
% contains the ground truth. For validation the files' name will be with 'R';

%
% PARAMETERS:
%
%   train_data_path -> train data path (DATA INPUT FOR CLASSIFIERS)
%   test_data_path  -> test data path (DATA INPUT FOR CLUSTERERS)
%   path_results    -> path in which results will be saved
%   claEns          -> classifier ensemble
%   strategyCluEns  -> cluster ensemble strategy 1 or 2 or 3
%   viewSize        -> multiplier (number of clusters or size of subset features)
%   numPartitions   -> if 1, 1 kmeans(k*viewSize); if 2, 2 kmeans(k*viewSize*2); if 3, 3 kmeans(k*viewSize*3)
%   validation      -> if validating the model
%   printResults    -> if 0, it does not print results; otherwise it does
%   iter            -> number of iterations (for selftraining)

fprintf('*******************************************************************\n');
fprintf('%s - Running Unsupervised Learning\n', datestr(now)); 
fprintf('name file: SSet%s - strategy: %d - view size: %d\n', sFCUE, strategyCluEns, viewSize);
fprintf('*******************************************************************\n');
tStart = tic;

res = ensemble.RunEnsembleSTS('', [pwd, '/data/', testDataPath], [pwd, '/results/'], claEns, strategyCluEns, viewSize, numPartitions, validation, 1, iter, sFCAE, sFCUE);

tEnd = toc(tStart);
fprintf('*******************************************************************\n');
fprintf('%s - It took %d minutes and %2.2f seconds\n', datestr(now), floor(tEnd/60), rem(tEnd,60));
fprintf('*******************************************************************\n');

try
    % labels-piSet Name: DatasetName + "R" for validation + Fold + MissingClass + NewInstances + Iteration + If "R", ValidationSet + EnsembleClassVector
    % SSet Name: DatasetName + "R" for validation + Fold + MissingClass + NewInstances + Iteration + If "R", ValidationSet + ClusterEnsembleStrategy + Multiplier(strat1)/SizeSubsetFeatures(strat2) + NumberOfClusters 
    resFiles.labels = res.get(0);
    resFiles.piSet = res.get(1);
    resFiles.SSet = res.get(2);
    
    labels = [];
    piSet = [];
    SSet = [];
    
    %labels = load([pwd, '/results/', resFiles.labels]);
    %piSet = load([pwd, '/results/', resFiles.piSet]);
    SSet = load([pwd, '/results/', resFiles.SSet]);
    
    %save([pwd,'/results/labels.mat'],'labels');
    %save([pwd,'/results/piSet.mat'],'piSet'); 
catch err
end
