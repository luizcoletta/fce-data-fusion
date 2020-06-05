function [results] = HCMain()
% *************************************************************************
% HCMain: 
%                                    
%              
% Example: 
%           
% Author: Luiz F. S. Coletta (luiz.fersc@gmail.com) - 18/10/18
% Update: Luiz F. S. Coletta - 18/10/18
% *************************************************************************

outputResultsPath = [pwd, '/results/'];  % path where datasets will be placed
inputDataPath = [pwd, '/data/']; % path with images to be analyzed
csvFile = 1; % 1 for CSV; other case, ARFF
csvDelimiter = ' ';
hOLimit = 10 



indexFile = 1;

allFiles = dir(inputDataPath);
allNames = {allFiles(~[allFiles.isdir]).name};

fullData = [];
indexData = [];

for i = 1:size(allNames,2)
    
    nameFile = char(allNames(i));

    if ((nameFile(1,size(nameFile,2)) == 'v') && csvFile) % check CSV of ARFF

        M = dlmread([inputDataPath, nameFile], csvDelimiter);
        
        if (indexFile == 1)
            n1 = repmat([nameFile,'-'],size(M,1),1);
            n2 = 1:size(M,1);
            indexData = [indexData; [n1,int2str(n2')]];
        end 
     
        fullData = [fullData; M];
        
    else 
        % HERE FOR ARFF FILES
    end


end 

holdOut = [1,hOLimit];

[Sfilldata] = size (fullData);

lines = Sfilldata(1,1);

for i = 1:(lines/holdOut(1,2));
    Li = i*holdOut(1,2) +1;
    col = (i+1)*holdOut(1,2);
    if (col > lines)
        col = lines;
    end
    
    
    holdOut = [holdOut;Li,col];
end

[sHoldOut] = size (holdOut);

for i = 1:sHoldOut(1,1);
 
d=fullData(holdOut(i,1):holdOut(i,2),:);
a = ones(size(fullData,1),1);
a(holdOut(i,1):holdOut(i,2)) = 0;
b = logical(a);
c = fullData(b, :)


ArffWriter([pwd,'/results/'], ['test',num2str(i)], d);
ArffWriter([pwd,'/results/'], ['training',num2str(i)], c);
end

% agora tem que gerar uma matrix, na qual linhas são
% as pastas deixadas de fora e cada coluna c1 ~ c2 é o
% intervalos de objetos para cada pasta. Ex: [1, 10; 11, 20; 21, 30]

%holdOut[1, 10; 11, 20; 21, 30];

% AQUI PEGA A PARTE DE TEST : fullData(holdOut(i,1):holdOut(i,2),:)
% AQUI PEGA A PARTE DE TRAINING: a = ones(size(fullData,1),1)
%                                a(holdOut(i,1):holdOut(i,2)) = 0;
%                                b = logical(a)
%                               c = fullData(b, :)


% Salvar em arquivo de test e de training (ARRF)
 
 




% --------



% set 1 for saving results
nameSavedFile = 'ResultsNB1';
saveFile = 0;
if (nargin >= 1)
    saveFile = savefl;
end

% numeric vector setting databases
numDatasets = [1, 2, 3];
if (nargin >= 2)
    if (nData ~= 0)
        numDatasets = nData;
    end
end

setOfData = 1; % choose the set of databases
if (setOfData == 1)
    dataTrain = struct('A','ceratocystis_train_90_10_rgb-05.arff','B','ceratocystis_train_90_10_rgb-1.arff','C','ceratocystis_train_90_10_rgb-2.arff','D','ceratocystis_train_90_10_rgb-5.arff','E','ceratocystis_train_90_10_rgb-10.arff','F','ceratocystis_train_90_10_rgb-20.arff','G','ceratocystis_train_90_10_rgb-30.arff');
    dataTest = struct('A','ceratocystis_test_90_10_rgb.arff','B','ceratocystis_test_90_10_rgb.arff','C','ceratocystis_test_90_10_rgb.arff','D','ceratocystis_test_90_10_rgb.arff','E','ceratocystis_test_90_10_rgb.arff','F','ceratocystis_test_90_10_rgb.arff','G','ceratocystis_test_90_10_rgb.arff');
end
if (setOfData == 2)
    dataTrain = struct('A','ceratocystis_train_90_10_rgb-40.arff','B','ceratocystis_train_90_10_rgb-50.arff','C','ceratocystis_train_90_10_rgb-60.arff','D','ceratocystis_train_90_10_rgb-70.arff','E','ceratocystis_train_90_10_rgb-80.arff','F','ceratocystis_train_90_10_rgb-90.arff','G','ceratocystis_train_90_10_rgb.arff');
    dataTest = struct('A','ceratocystis_test_90_10_rgb.arff','B','ceratocystis_test_90_10_rgb.arff','C','ceratocystis_test_90_10_rgb.arff','D','ceratocystis_test_90_10_rgb.arff','E','ceratocystis_test_90_10_rgb.arff','F','ceratocystis_test_90_10_rgb.arff','G','ceratocystis_test_90_10_rgb.arff');
end

% 0: for testing (to build the test and training sets);
% 1: for validation (fold 1 of 2 from labeled objects - the dataset's name appears with "R");
% 2: for validation (fold 2 of 2 from labeled objects - the dataset's name appears with "R");
validation = 0;
if (nargin >= 3)
    validation = val;
end

nDataTr = fieldnames(dataTrain);
nDataTe = fieldnames(dataTest);
results = [];

s = struct('Summary',[],'EvalPerClass',[],'ConfMatrix',[],'NameData',[],'Info',[]);

for i = 1:size(numDatasets,2)
    
    nameDataTrain = dataTrain.(nDataTr{numDatasets(i)});
    nameDataTest = dataTest.(nDataTe{numDatasets(i)});
    results = [results; s];
    
    [labels, piSet, ~, ~] = runJavaMLA_STS(nameDataTrain, nameDataTest, validation);

    save([pwd,'/results/labels.mat'], 'labels');
    save([pwd,'/results/piSet.mat'], 'piSet');

    % compute accuracy, balanced accuracy, precision, sensitivity,
    % specificity, f_measure, gmean, relerror
    % storing in a matrix (first and second columns are the fold and class, respectively)
    % (zeros in the second column are general results - considering all classes)
    [~, piSetLabel] = max(piSet');
    [sumResults, resultsPerClass, confMatrix] = evaluateClassifier(labels, piSetLabel');
    
    % piSetLabel -> vetor com labels estimados pelo classificador (1: solo, 2:sadia, 3:doente)
    % labels -> vetor com labels reais/esperados (1: solo, 2:sadia, 3:doente) 

    results(i).Summary = sumResults;
    results(i).EvalPerClass = resultsPerClass;
    results(i).ConfMatrix = confMatrix;
    results(i).NameData = nameDataTrain;
    results(i).Info = 'Classification using a test set';
       
    if (saveFile > 0)
        save([pwd,'/results/', nameSavedFile, '.mat'], 'results');
    end
end
