function [histogram] = EFBIC(img, colors)
   % *************************************************************************
   % BICFeatures: extract features based on border and interior classification
   %              from a re-quantized image (e.g., 8 colors). Two histograms
   %              are computed: one for the pixels classified as part of the 
   %              border, and another for those classified as part of image 
   %              interior. Thus, for 8 colors a 16-dimensional vector will 
   %              be produced as being the 'histogram' output.
   %              
   % Example:  [histogram] = BICFeatures(image, 8)
   %           
   % Author: Luiz F. S. Coletta (luiz.fersc@gmail.com) - 30/01/18
   % Update: Luiz F. S. Coletta - 07/02/18
   % ************************************************************************* 
   
   [quant_img]= rgb2ind(img, colors, 'dither');
   
   %figure, imshow(quant_img), title('Quantized image')
   %figure, imagesc(quant_img, 'Parent', handles.axes1), title('Quantized image')
   
   vetBorder = zeros(colors,1);
   vetInterior = zeros(colors,1);
   
   maxRows = size(quant_img, 1);
   maxCols = size(quant_img, 2);
   
   for i = 1:maxRows
       for j = 1:maxCols
           
           pixelColor = squeeze(quant_img(i, j,:));
           
           if ((i == 1) || (j == 1) || (i == maxRows) || (j == maxCols))
               vetBorder(pixelColor + 1) = vetBorder(pixelColor + 1) + 1;
           else
               t = squeeze(quant_img(i-1, j,:));
               b = squeeze(quant_img(i+1, j,:));
               l = squeeze(quant_img(i, j-1,:));
               r = squeeze(quant_img(i, j+1,:));
               if ((pixelColor == t) && (pixelColor == b) && (pixelColor == l) && (pixelColor == r))
                   vetInterior(pixelColor + 1) = vetInterior(pixelColor + 1) + 1;   
               else
                   vetBorder(pixelColor + 1) = vetBorder(pixelColor + 1) + 1; 
               end    
           end    
       end    
   end
   
   histogram = [vetBorder; vetInterior];
   histogram(isnan(histogram)) = 0;
end
