function [labels, piSet, SSet, resFiles] = HCJavaMLA(data4Class, data4Clust, validation)

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
typeClaEns = [0, 1,  0,  0,  0,       0,       0,  0,             0];

%------------------%
% CLUSTER ENSEMBLE %
%------------------%

%1: strategy 1 (old)
%2: strategy 2 (new)
%3: stragegy based on KMedoids (using ELKI)
strategyCluEns = 2;

% multiplier (for strategy 1) 
% size of subset of features (for strategy 2)
theta = 2;

% number of partitions (1, 2, 3, ...) - if 0, does not run clustering
typeCluEns = 0; 

strmc = '0'; 
strni = '-1';
iter = '0';

if (validation == 0)
   sFCAE = ['_', data4Class, strmc, strni, iter, num2str(typeClaEns(1)), num2str(typeClaEns(2)), num2str(typeClaEns(3)), num2str(typeClaEns(4)), num2str(typeClaEns(5)), num2str(typeClaEns(6)), num2str(typeClaEns(7)), num2str(typeClaEns(8)), num2str(typeClaEns(9))];
   sFCUE = ['_', data4Class, strmc, strni, iter, num2str(strategyCluEns), num2str(theta), num2str(typeCluEns)];
else
   sFCAE = ['_', data4Class, 'R', strmc, strni, iter, num2str(validation), num2str(typeClaEns(1)), num2str(typeClaEns(2)), num2str(typeClaEns(3)), num2str(typeClaEns(4)), num2str(typeClaEns(5)), num2str(typeClaEns(6)), num2str(typeClaEns(7)), num2str(typeClaEns(8)), num2str(typeClaEns(9))];
   sFCUE = ['_', data4Class, 'R', strmc, strni, iter, num2str(validation), num2str(strategyCluEns), num2str(theta), num2str(typeCluEns)];
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
    typeCluEns = 0;
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
%   theta           -> multiplier (number of clusters or size of subset features)
%   typeCluEns      -> if 1, 1 kmeans(k*theta); if 2, 2 kmeans(k*theta*2); if 3, 3 kmeans(k*theta*3)
%   validation      -> if validating the model
%   printResults    -> if 0, it does not print results; otherwise it does
%   iter            -> number of iterations (for selftraining)
res = ensemble.RunEnsembleSTS([pwd, '/data/', trainDataPath], [pwd, '/data/', testDataPath], [pwd, '/results/'], claEns, strategyCluEns, theta, typeCluEns, validation, 1, iter, sFCAE, sFCUE);

%try
    % labels-piSet Name: DatasetName + "R" for validation + Fold + MissingClass + NewInstances + Iteration + If "R", ValidationSet + EnsembleClassVector
    % SSet Name: DatasetName + "R" for validation + Fold + MissingClass + NewInstances + Iteration + If "R", ValidationSet + ClusterEnsembleStrategy + Multiplier(strat1)/SizeSubsetFeatures(strat2) + NumberOfClusters 
    resFiles.labels = res.get(0);
    resFiles.piSet = res.get(1);
    resFiles.SSet = res.get(2);
    
    labels = [];
    piSet = [];
    SSet = [];
    
    labels = load([pwd, '/results/', resFiles.labels]);
    piSet = load([pwd, '/results/', resFiles.piSet]);
    %SSet = load([pwd, '/results/', resFiles.SSet]);
    
    %save([pwd,'/results/labels.mat'],'labels');
    %save([pwd,'/results/piSet.mat'],'piSet'); 
%catch err
end
