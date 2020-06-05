function [Result] = NDVI(NIR, RED)

   RED = fliplr(RED);
   NIR = fliplr(NIR);

   NIR = double(NIR);
   RED = double(RED);

   Result = (NIR-RED)./(NIR+RED);
   
   %colormap(flipud(jet))

   %r1 = [0 1];
   %g1 = [0 1];
   %b1 =  [0 1];
   r1 = [1 1];
   g1 = [0 1];
   b1 =  [0.4 0.4];
   rgb1 = [r1; g1; b1]';
   rgbt = interp1([1 2],rgb1, linspace(1,2,32 ));

   r1 = [1 0];
   g1 = [1 0.5];
   b1 =  [0.4 0.4];
   rgb2 = [r1; g1; b1]';
   rgbb= interp1([1 2],rgb2, linspace(1,2,32 ));

   newNDVI = [rgbt;rgbb];

   
   
   
   figure
   imshow(imrotate(flipdim(Result,2),180), []), title('NDVI');
   colormap(newNDVI );
   cmap = colormap; % cmap nicely puts colormap into 3 col data
   % colorbar
   caxis([-1 1])
   hc = colorbar('southoutside');
   set(hc, 'FontSize', 16)
   
   axis off; set(gcf,'Color','White')
   
   %colorbar;
   impixelinfo
   
   saveas(gcf,'NDVI.png');
   
   %http://usefulcodes.blogspot.com/2016/05/colormap-for-ndvi.html
   
end

