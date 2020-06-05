function [] = CShowFuzzyClusters(pathImage, sizeSubImage, U)
   % *************************************************************************
   % ExtractSubImgFeatures: show recognized patterns in red on image files
   %              
   % Example: CShowFuzzyClusters([pwd, '/images/cana_raizen.tif'], 24, ans)
   %           
   % Author: Luiz F. S. Coletta (luiz.fersc@gmail.com) - 30/01/18
   % Update: Luiz F. S. Coletta - 07/02/18
   % ************************************************************************* 
   
   fullImage = imread(pathImage);

   red = fullImage(:,:,1);   % Red channel
   green = fullImage(:,:,2); % Green channel
   blue = fullImage(:,:,3);  % Blue channel
   fullImage = cat(3, red, green, blue);

   [rows, cols, ~] = size(fullImage);

   left = 0;
   top = left;
   width = sizeSubImage;
   height = width;
   i = 1;
   
   cluster1 = fullImage;
   cluster2 = fullImage;
   cluster3 = fullImage;
   cluster4 = fullImage;
   cluster5 = fullImage;
   cluster6 = fullImage;
   
   threshold = 0.2;
   
   for j = 1:rows/width % iterate getting subimages from current file (lines)

      left = 0; 
      width = sizeSubImage;

      for k = 1:cols/width % iterate getting subimages from current file (columns)
          
          try
             
             if (U(2,i) >= threshold)
                 cluster1(top+1:(top+1+height),left+1:(left+1+width),1) = U(1,i)*(255/1);
             end 
             
             if (U(1,i) >= threshold)
                 %cluster2(top+1:(top+1+height),left+1:(left+1+width),1) = U(2,i)*(255);
                 %cluster2(top+1:(top+1+height),left+1:(left+1+width),2) = U(2,i)*(255);
                 cluster2(top+1:(top+1+height),left+1:(left+1+width),3) = U(1,i)*(255);
             end
             
             if (U(3,i) >= threshold)
                 cluster3(top+1:(top+1+height),left+1:(left+1+width),3) = U(3,i)*255;
             end
             
             if (U(4,i) >= threshold)
                 cluster4(top+1:(top+1+height),left+1:(left+1+width),1) = U(4,i)*255;  
                 cluster4(top+1:(top+1+height),left+1:(left+1+width),2) = U(4,i)*255;
             end
             
             if (U(5,i) >= threshold)
                 cluster5(top+1:(top+1+height),left+1:(left+1+width),1) = U(5,i)*255;
                 cluster5(top+1:(top+1+height),left+1:(left+1+width),3) = U(5,i)*255;
             end
             
             if (U(6,i) >= threshold)
                 cluster6(top+1:(top+1+height),left+1:(left+1+width),2) = U(6,i)*255;
                 cluster6(top+1:(top+1+height),left+1:(left+1+width),3) = U(6,i)*255;
             end
             catch    
              
          end 
          
          %fullImage(top+1:(top+1+height),left+1:(left+1+width),1) = U(1,i)*255;
          %fullImage(top+1:(top+1+height),left+1:(left+1+width),2) = U(2,i)*255;
          %fullImage(top+1:(top+1+height),left+1:(left+1+width),3) = U(2,i)*255;
          
          left = left + width + 1;
          if (k == 1)
             width = width - 1;
          end 
          
          i = i+1;
          
      end 

      top = top + height + 1;
      if (j == 1)
          height = height - 1;
      end 
      
   end 

   figure
   %subplot(2,3,1);
   %imshow(cluster1);
   
   %subplot(2,3,2);
   imshow(cluster2);
   
   %subplot(2,3,3);
   %imshow(cluster3);
   
   %subplot(2,3,4);
   %imshow(cluster4);
   
   %subplot(2,3,5);
   %imshow(cluster5);
   
   %subplot(2,3,6);
   %imshow(cluster6);
   
end
