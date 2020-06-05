function [] = CLShowClusters(pathImage, sizeSubImage, U, localization)
   % *************************************************************************
   % ExtractSubImgFeatures: show recognized patterns in red on image files
   %              
   % Example: CLShowClusters([pwd, '/images/teste1.png'], 16, U)
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
   cluster7 = fullImage;
   %   .    =    .
   %   .    =    .
   %   .    =    .
   %   if you want...
   
   threshold = 0.8; % for patterns from fuzzy partitions
   
   if (nargin >= 4)
      newU = []; 
      cont = 1;
      cont2 = 1;
      for j = 1:rows/width
         for k = 1:cols/width
             if (cont2 > size(localization,1))
                 pos = -1;
             else 
                 pos = localization(cont2, 2);
             end
             if (pos == cont)
                newU = [newU; U(cont2)];
                cont2 = cont2 + 1;
             else 
                newU = [newU; -1];
             end
             cont = cont + 1;
         end
      end
      U = newU;
   end
   
   Crisp = [];
   if (size(U,2) == 1) 
       Crisp = U;
   end
   
   for j = 1:rows/width % iterate getting subimages from current file (lines)

      left = 0; 
      width = sizeSubImage;

      for k = 1:cols/width % iterate getting subimages from current file (columns)
          
          try
             
             if (isempty(Crisp)) 

                 if (U(1,i) >= threshold) % adjusting red channel
                     cluster1(top+1:(top+1+height),left+1:(left+1+width),1) = U(1,i)*(255/1);
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = U(1,i)*(255/1);
                 end 

                 if (U(2,i) >= threshold) % adjusting green channel
                     cluster2(top+1:(top+1+height),left+1:(left+1+width),2) = U(2,i)*(255);
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = U(2,i)*(255);
                 end

                 if (U(3,i) >= threshold) % adjusting blue channel
                     cluster3(top+1:(top+1+height),left+1:(left+1+width),3) = U(3,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = U(3,i)*255;
                 end

                 if (U(4,i) >= threshold) % adjusting red and green channels
                     cluster4(top+1:(top+1+height),left+1:(left+1+width),1) = U(4,i)*255;  
                     cluster4(top+1:(top+1+height),left+1:(left+1+width),2) = U(4,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = U(4,i)*255;  
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = U(4,i)*255;
                 end

                 if (U(5,i) >= threshold) % adjusting red and blue channels
                     cluster5(top+1:(top+1+height),left+1:(left+1+width),1) = U(5,i)*255;
                     cluster5(top+1:(top+1+height),left+1:(left+1+width),3) = U(5,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = U(5,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = U(5,i)*255;
                 end

                 if (U(6,i) >= threshold) % adjusting green and blue channels
                     cluster6(top+1:(top+1+height),left+1:(left+1+width),2) = U(6,i)*255;
                     cluster6(top+1:(top+1+height),left+1:(left+1+width),3) = U(6,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = U(6,i)*255;
                     cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = U(6,i)*255;
                 end

             else
                 
                 if (Crisp(i) > -1)
                     if (Crisp(i) == 1) % adjusting red channel
                         cluster1(top+1:(top+1+height),left+1:(left+1+width),1) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = 255;
                     end 

                     if (Crisp(i) == 2) % adjusting green channel
                         cluster2(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                     end

                     if (Crisp(i) == 3) % adjusting blue channel
                         cluster3(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                     end

                     if (Crisp(i) == 4) % adjusting red and green channels
                         cluster4(top+1:(top+1+height),left+1:(left+1+width),1) = 255;  
                         cluster4(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = 255; 
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                     end

                     if (Crisp(i) == 5) % adjusting red and blue channels
                         cluster5(top+1:(top+1+height),left+1:(left+1+width),1) = 255;
                         cluster5(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),1) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                     end

                     if (Crisp(i) == 6) % adjusting green and blue channels
                         cluster6(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                         cluster6(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),2) = 255;
                         cluster7(top+1:(top+1+height),left+1:(left+1+width),3) = 255;
                     end
                 end

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
   subplot(2,3,1);
   imshow(cluster1);
   
   subplot(2,3,2);
   imshow(cluster2);
   
   subplot(2,3,3);
   imshow(cluster3);
   
   subplot(2,3,4);
   imshow(cluster4);
   
   subplot(2,3,5);
   imshow(cluster5);
   
   subplot(2,3,6);
   imshow(cluster6);
   
   figure
   imshow(cluster7);
   
end
