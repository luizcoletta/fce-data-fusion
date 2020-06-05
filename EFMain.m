function [dataset] = EFMain(nameDataset, sizeSubImage, vetDescriptors, normalize, vetOutputFiles, saveIndexFile)
   % *************************************************************************
   % EFMain: extract subimage features from image files in folder 'images'
   %         (labels came from ground truth files (in 'GT' folder). 
   %         'nameDataset' is the name of the dataset as output in               
   %         folder 'data'.
   %              
   % Example: [dataset] = EFMain('dataset1', 16, [1,0,0], true, [0,0,1], 0);
   %           
   % Author: Luiz F. S. Coletta (luiz.fersc@gmail.com) - 30/01/18
   % Update: Luiz F. S. Coletta - 30/01/19
   % ************************************************************************* 
   
   nDataset = 'dataset'; % name of the dataset
   if (nargin >= 1)
       nDataset = nameDataset;
   end
   
   sSubImage = 16; % square pixel matrix order for subimages
   if (nargin >= 2)
       sSubImage = sizeSubImage;
   end
   
   vDescriptors = [1, ... % CIE-LAB
                   0, ... % BIC
                   0];    % Haralick6
   if (nargin >= 3)
       vDescriptors = vetDescriptors;
   end

   normAttrib = true; % normalize attributes to [0, 1]
   if (nargin >= 4)
       normAttrib = normalize;
   end
   
   vOutputFiles = [1, ... % .txt
                   1, ... % .csv
                   1];    % .arff
   if (nargin >= 5)
       vOutputFiles = vetOutputFiles;
   end
   
   sIndexFile = true; % outputs a index file for the data
   if (nargin >= 6)
       sIndexFile = saveIndexFile;
   end
   
   outputPath = [pwd, '/data/'];  % path where datasets will be placed
   inputImagePath = [pwd, '/images/']; % path with images to be analyzed
   inputGroundTruthPath = [pwd, '/images/GT/']; % path with ground truth
   
   %if (exist([outputPath, nDataset], 'file'))
   %    dataset = load([outputPath, nDataset], '\t');
   %else
   
   dataset = [];

   allFiles = dir(inputImagePath);
   allNames = {allFiles(~[allFiles.isdir]).name};

   %r = randperm(size(allNames,2));
   r = 1:size(allNames,2);

   position = []; 

   for i = 1:size(allNames,2) % iterate files in 'data'

       left = 0;
       top = left;
       width = sSubImage;
       height = width;

       nameFile = strjoin(allNames(r(i)));

       fullImage = imread([inputImagePath, nameFile]);

       red = fullImage(:,:,1);   % Red channel
       green = fullImage(:,:,2); % Green channel
       blue = fullImage(:,:,3);  % Blue channel
       fullImage = cat(3, red, green, blue);

       [rows, cols, ~] = size(fullImage);

       % Getting ground truth image if exists
       nameFileGT = ['gt', strjoin(allNames(r(i)))];
       if (exist([outputPath, nameFileGT], 'file'))
           withGT = 1;
       else
           withGT = 0;
       end
       if (withGT)
           fullImageGT = imread([inputGroundTruthPath, nameFileGT]);
       end 

       for j = 1:rows/width % iterate getting subimages from current file (lines)

          left = 0; 
          width = sSubImage;

          for k = 1:cols/width % iterate getting subimages from current file (columns)

              p = [nameFile, '-', int2str(j), 'x', int2str(k)];
              position = [position; [p, repmat(' ', [1,50-size(p,2)])]];

              fprintf('Extracting features of %s - [%d x %d]\n', nameFile, j, k);

              subImage = imcrop(fullImage, [left, top, width, height]); % left, top, width, height]

              %figure, imshow(subImage)

              if (withGT)
                  subImageGT = imcrop(fullImageGT, [left, top, width, height]);
                  if (max(max(subImageGT))/255 == 1)
                      label = 1;
                  elseif (max(max(subImageGT)) == 0)
                      label = 0;
                  else
                      label = -1;
                  end
              end 

              %figure, imshow(subImageGT)

              left = left + width + 1;
              if (k == 1)
                 width = width - 1;
              end 

              % *************************************
              % **** DESCRIPTORS FUNCTIONS HERE ***** 
              % *************************************

              featureVector = [];

              if (vDescriptors(1)) 
                 % generates 3 features (avg(l*) avg(a*) and avg(b*))
                 lab_features = EFLAB(subImage, [1,1,1]);
                 lab_features(isnan(lab_features)) = 0;
                 featureVector = lab_features;
              end

              if (vDescriptors(2)) 
                 % default quantization = 64 (128 features); 16 (32 features)
                 % reduced because sparse matrices
                 bic_features = EFBIC(subImage, 8); 
                 featureVector = [featureVector, bic_features'];
              end

              if (vDescriptors(3)) 
                 % default neighbors = 8 (48 features);
                 img_gray = rgb2gray(subImage);
                 %angle = [[0 1]; [-1 1]; [-1 0]; [-1 -1]; [0 -1]; [1 -1]; [1 0]; [1 1]];
                 angle = [[0 1]; [-1 0]; [0 -1]; [1 0]];
                 haralick6 = [];
                 for l = 1:size(angle,1)
                     glcms = graycomatrix(img_gray, 'offset', angle(l,:), 'Symmetric', true);
                     HF = EFGLCM(glcms);
                     vecHF = [HF.maximumProbability; HF.correlation; HF.contrast; HF.energy; HF.homogeneity; HF.entropy];
                     vecHF(isnan(vecHF)) = 0;
                     haralick6 = [haralick6; vecHF];
                 end 
                 featureVector = [featureVector, haralick6'];
              end

              if (withGT)
                  featureVector = [featureVector, label];
              end

              % CONCATENATING FEATURES AND LABELS
              dataset = [dataset; featureVector];

              % *******************************************************************
              % *******************************************************************
              % *******************************************************************
          end 

          top = top + height + 1;
          if (j == 1)
              height = height - 1;
          end 

       end 

   end 

   if (normAttrib) 
       minVal = min(dataset);
       maxVal = max(dataset);
       norm_data = [];
       for m = 1:size(dataset,2)-withGT
           vecN = (dataset(:, m) - minVal(m))/(maxVal(m) - minVal(m));
           vecN(isnan(vecN)) = 0;
           norm_data = [norm_data, vecN];
       end
       if (withGT)
          dataset = [norm_data, dataset(:,size(dataset,2))];
       else
          dataset = [norm_data];
       end
   end 

   % Saving output files
   if (vOutputFiles(1))
       dlmwrite([outputPath, nDataset, '.txt'], dataset, 'delimiter', '\t', 'precision', 4);
   end
   if (vOutputFiles(2))
       csvwrite([nDataset, '.csv'], dataset)
   end
   if (vOutputFiles(3))
       ArffWriter(outputPath, nDataset, dataset, withGT);
   end

   if (sIndexFile)
       dlmwrite([outputPath, nDataset, '-Index.txt'], position, 'delimiter', '');
   end
end

