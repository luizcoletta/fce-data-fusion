function [out] = EFGLCM(glcm)
% 
% Features computed 
% Autocorrelation: [2]   
% Cluster Prominence: [2]                   
% Cluster Shade: [2] 
% Contrast: [1]                                         
% Correlation: [1]                        
% Difference entropy [1] 
% Difference variance [1]                   
% Dissimilarity: [2]                        
% Energy: [1]                    
% Entropy: [2]       
% Homogeneity: (Inverse Difference Moment) [2,1] 
% Information measure of correlation1 [1]   
% Informaiton measure of correlation2 [1]  
% Inverse difference (Homogeneity in matlab): [3]                              
% Maximum probability: [2]                    
% Sum average [1]   
% Sum entropy [1]  
% Sum of sqaures: Variance [1]    
% Sum variance [1]   
%
% References:
% 1. R. M. Haralick, K. Shanmugam, and I. Dinstein, Textural Features of
% Image Classification, IEEE Transactions on Systems, Man and Cybernetics,
% vol. SMC-3, no. 6, Nov. 1973
% 2. L. Soh and C. Tsatsoulis, Texture Analysis of SAR Sea Ice Imagery
% Using Gray Level Co-Occurrence Matrices, IEEE Transactions on Geoscience
% and Remote Sensing, vol. 37, no. 2, March 1999.
% 3. D A. Clausi, An analysis of co-occurrence texture statistics as a
% function of grey level quantization, Can. J. Remote Sensing, vol. 28, no.
% 1, pp. 45-62, 2002
%
%
% Started from Avinash Uppupuri's code on Matlab file exchange. It has then
% been vectorized. Three features were not implemented correctly in that
% code, it has since then been changed. The features are: 
%   * Sum of squares: variance
%   * Difference variance
%   * Sum Variance

% The GLCMs are stored in a i x j x n matrix, where n is the number of GLCMs calculated usually due to the different orientation and displacements used in the algorithm. Usually the values i and j are equal to 'NumLevels' parameter of the GLCM computing function graycomatrix(). Note that matlab quantization values belong to the set {1,..., NumLevels} and not from {0,...,(NumLevels-1)} as provided in some references
% http://www.mathworks.com/help/images/ref/graycomatrix.html
% 
% Although there is a function graycoprops() in Matlab Image Processing Toolbox that computes four parameters Contrast, Correlation, Energy, and Homogeneity. The paper by Haralick suggests a few more parameters that are also computed here. The code is not vectorized and hence is not an efficient implementation but it is easy to add new features based on the GLCM using this code. The code takes care of 3 dimensional glcms (multiple glcms in a single 3D array)
% 
% If you find that the values obtained are different from what you expect or if you think there is a different formula that needs to be used from the ones used in this code please let me know. A few questions which I have are listed in the link http://www.mathworks.com/matlabcentral/newsreader/view_thread/239608
% 
% I plan to submit a vectorized version of the code later and provide updates based on replies to the above link and this initial code.
% 
% % Features computed
% % Autocorrelation: [2] (out.autoc)
% % Contrast: matlab/[1,2] (out.contr)
% % Correlation: matlab (out.corrm)
% % Correlation: [1,2] (out.corrp)
% % Cluster Prominence: [2] (out.cprom)
% % Cluster Shade: [2] (out.cshad)
% % Dissimilarity: [2] (out.dissi)
% % Energy: matlab / [1,2] (out.energ)
% % Entropy: [2] (out.entro)
% % Homogeneity: matlab (out.homom)
% % Homogeneity: [2] (out.homop)
% % Maximum probability: [2] (out.maxpr)
% % Sum of sqaures: Variance [1] (out.sosvh)
% % Sum average [1] (out.savgh)
% % Sum variance [1] (out.svarh)
% % Sum entropy [1] (out.senth)
% % Difference variance [1] (out.dvarh)
% % Difference entropy [1] (out.denth)
% % Information measure of correlation1 [1] (out.inf1h)
% % Informaiton measure of correlation2 [1] (out.inf2h)
% % Inverse difference (INV) is homom [3] (out.homom)
% % Inverse difference normalized (INN) [3] (out.indnc)
% % Inverse difference moment normalized [3](out.idmnc)
% 
% Haralick uses 'Symmetric' = true in computing the glcm. There is no Symmetric flag in the Matlab version I use hence I add the diagonally opposite pairs to obtain the Haralick glcm. Here it is assumed that the diagonally opposite orientations are paired one after the other in the matrix. If the above assumption is true with respect to the input glcm then setting the flag 'pairs' to 1 will compute the final glcms that would result by setting 'Symmetric' to true. If your glcm is computed using the
% Matlab version with 'Symmetric' flag you can set the flag 'pairs' to 0
% 
% % References:
% 1. R. M. Haralick, K. Shanmugam, and I. Dinstein, Textural Features of Image Classification, IEEE Transactions on Systems, Man and Cybernetics, vol. SMC-3, no. 6, Nov. 1973
% 2. L. Soh and C. Tsatsoulis, Texture Analysis of SAR Sea Ice Imagery Using Gray Level Co-Occurrence Matrices, IEEE Transactions on Geoscience and Remote Sensing, vol. 37, no. 2, March 1999.
% 3. D A. Clausi, An analysis of co-occurrence texture statistics as a
% function of grey level quantization, Can. J. Remote Sensing, vol. 28, no.1, pp. 45-62, 2002
% 4. http://murphylab.web.cmu.edu/publications/boland/boland_node26.html
% 
% % Example:
% % Usage is similar to graycoprops() but needs extra parameter 'pairs' apart from the GLCM as input
% 
% >I = imread('circuit.tif');
% >GLCM2 = graycomatrix(I,'Offset',[2 0;0 2]);
% >stats = GLCM_features1(GLCM2,0)

%       GLCM Features (Soh, 1999; Haralick, 1973; Clausi 2002)
%           f1. Uniformity / Energy / Angular Second Moment (done)
%           f2. Entropy (done)
%           f3. Dissimilarity (done)
%           f4. Contrast / Inertia (done)
%           f5. Inverse difference    
%           f6. correlation
%           f7. Homogeneity / Inverse difference moment
%           f8. Autocorrelation
%           f9. Cluster Shade
%          f10. Cluster Prominence
%          f11. Maximum probability
%          f12. Sum of Squares
%          f13. Sum Average
%          f14. Sum Variance
%          f15. Sum Entropy
%          f16. Difference variance
%          f17. Difference entropy
%          f18. Information measures of correlation (1)
%          f19. Information measures of correlation (2)
%          f20. Maximal correlation coefficient
%          f21. Inverse difference normalized (INN)
%          f22. Inverse difference moment normalized (IDN)




if ((nargin > 1) || (nargin == 0))
    error('Too many or too few input arguments')
else
    if ((size(glcm,1) <= 1) || (size(glcm,2) <= 1))
        error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcm,1) ~= size(glcm,2) )
        error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end  
end

% Normalize the GLCMs
glcm = bsxfun(@rdivide,glcm,sum(sum(glcm)));

% Get size of GLCM
nGrayLevels = size(glcm,1);
nglcm = size(glcm,3);

% checked 
out.autoCorrelation                     = zeros(1,nglcm); % Autocorrelation: [2] 
out.clusterProminence                   = zeros(1,nglcm); % Cluster Prominence: [2]
out.clusterShade                        = zeros(1,nglcm); % Cluster Shade: [2]
out.contrast                            = zeros(1,nglcm); % Contrast: matlab/[1,2]
out.correlation                         = zeros(1,nglcm); % Correlation: [1,2]
out.differenceEntropy                   = zeros(1,nglcm); % Difference entropy [1]
out.differenceVariance                  = zeros(1,nglcm); % Difference variance [1]
out.dissimilarity                       = zeros(1,nglcm); % Dissimilarity: [2]
out.energy                              = zeros(1,nglcm); % Energy: matlab / [1,2]
out.entropy                             = zeros(1,nglcm); % Entropy: [2]
out.homogeneity                         = zeros(1,nglcm); % Homogeneity: [2] (inverse difference moment)
out.informationMeasureOfCorrelation1    = zeros(1,nglcm); % Information measure of correlation1 [1]
out.informationMeasureOfCorrelation2    = zeros(1,nglcm); % Informaiton measure of correlation2 [1]
out.inverseDifference                   = zeros(1,nglcm); % Homogeneity in matlab
% out.inverseDifferenceMomentNormalized   = zeros(1,nglcm); % Normalized Homogeneity
% out.inverseDifferenceNormalized         = zeros(1,nglcm); % Normalized inverse difference
out.maximumProbability                  = zeros(1,nglcm); % Maximum probability: [2]
out.sumAverage                          = zeros(1,nglcm); % Sum average [1]    
out.sumEntropy                          = zeros(1,nglcm); % Sum entropy [1]
out.sumOfSquaresVariance                = zeros(1,nglcm); % Sum of sqaures: Variance [1]
out.sumVariance                         = zeros(1,nglcm); % Sum variance [1]

glcmMean = zeros(nglcm,1);
uX = zeros(nglcm,1);
uY = zeros(nglcm,1);
sX = zeros(nglcm,1);
sY = zeros(nglcm,1);

% pX pY pXplusY pXminusY
pX = zeros(nGrayLevels,nglcm); % Ng x #glcms[1]  
pY = zeros(nGrayLevels,nglcm); % Ng x #glcms[1]
pXplusY = zeros((nGrayLevels*2 - 1),nglcm); %[1]
pXminusY = zeros((nGrayLevels),nglcm); %[1]
% HXY1 HXY2 HX HY
HXY1 = zeros(nglcm,1);
HX   = zeros(nglcm,1);
HY   = zeros(nglcm,1);
HXY2 = zeros(nglcm,1);

% Create indices for vectorising code:
sub   = 1:nGrayLevels*nGrayLevels;
[I,J] = ind2sub([nGrayLevels,nGrayLevels],sub);

% Loop over all GLCMs
for k = 1:nglcm 
    currentGLCM = glcm(:,:,k);
    glcmMean(k) = mean2(currentGLCM);
    
    % For symmetric GLCMs, uX = uY
    uX(k)   = sum(I.*currentGLCM(sub));
    uY(k)   = sum(J.*currentGLCM(sub));
    sX(k)   = sum((I-uX(k)).^2.*currentGLCM(sub));
    sY(k)   = sum((J-uY(k)).^2.*currentGLCM(sub));

    out.contrast(k)             = sum(abs(I-J).^2.*currentGLCM(sub)); %OK
    out.dissimilarity(k)        = sum(abs(I - J).*currentGLCM(sub)); %OK
    out.energy(k)               = sum(currentGLCM(sub).^2); % OK
    out.entropy(k)              = -nansum(currentGLCM(sub).*log(currentGLCM(sub))); %OK
    out.inverseDifference(k)    = sum(currentGLCM(sub)./( 1 + abs(I-J) )); %OK
    out.homogeneity(k)          = sum(currentGLCM(sub)./( 1 + (I - J).^2)); %OK
    
%     out.inverseDifferenceNormalized(k)      = sum(currentGLCM(sub)./( 1 + abs(I-J)/nGrayLevels )); %OK
%     out.inverseDifferenceMomentNormalized(k)= sum(currentGLCM(sub)./( 1 + ((I - J)/nGrayLevels).^2)); %OK

    out.sumOfSquaresVariance(k) = sum(currentGLCM(sub).*((I - uX(k)).^2)); %<----- N.B! Wrong implementation previously!!
    out.maximumProbability(k)   = max(currentGLCM(:));
    
    pX(:,k) = sum(currentGLCM,2); %OK
    pY(:,k) = sum(currentGLCM,1)'; %OK
    
    tmp1 = [(I+J)' currentGLCM(sub)'];
    tmp2 = [abs((I-J))' currentGLCM(sub)'];
    idx1 = 2:2*nGrayLevels;
    idx2 = 0:nGrayLevels-1;
    for i = idx1
        pXplusY(i-1,k) = sum(tmp1(tmp1(:,1)==i,2));
    end
    
    for i = idx2 
        pXminusY(i+1,k) = sum(tmp2(tmp2(:,1)==i,2));
    end

    % These can be evaluated for all GLCMs simultaneously, no k-index
    % missing. We need the results further down so I keep it in the loop.
    out.sumAverage              = sum(bsxfun(@times,idx1',pXplusY));
    out.sumEntropy              = -nansum(pXplusY.*log(pXplusY)); %OK
    out.differenceEntropy       = -nansum(pXminusY.*log(pXminusY)); %OK
    out.differenceVariance(k)   = sum((idx2-out.dissimilarity(k)).^2'.*pXminusY(idx2+1,k)); %<----- N.B! Wrong implementation previously!! Dissimilarity is "difference Average"
    out.sumVariance(k)          = sum((idx1-out.sumAverage(k))'.^2.*pXplusY(idx1-1,k)); %<----- N.B! Wrong implementation previously AND in [1]
    
    HXY1(k)                     = -nansum(currentGLCM(sub)'.*log(pX(I,k).*pY(J,k))); %OK
    HXY2(k)                     = -nansum(pX(I,k).*pY(J,k).*log(pX(I,k).*pY(J,k))); %OK
    HX(k)                       = -nansum(pX(:,k).*log(pX(:,k))); %OK
    HY(k)                       = -nansum(pY(:,k).*log(pY(:,k))); %OK
    
    out.autoCorrelation(k)      = sum(I.*J.*currentGLCM(sub));
    out.clusterProminence(k)    = sum((I+J-uX(k)-uY(k)).^4.*currentGLCM(sub)); %OK
    out.clusterShade(k)         = sum((I+J-uX(k)-uY(k)).^3.*currentGLCM(sub)); %OK
    out.correlation(k)          = (out.autoCorrelation(k) - uX(k).*uY(k))./(sqrt(sX(k).*sY(k))); %OK
    
    out.informationMeasureOfCorrelation1(k) = (out.entropy(k)-HXY1(k))./(max(HX(k),HY(k))); %OK
    out.informationMeasureOfCorrelation2(k) = (1 - exp(-2.*(HXY2(k)-out.entropy(k))) ).^(1/2); %OK
    
end
