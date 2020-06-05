function [Result] = EFSR(NIR, RED)

   %RED = fliplr(RED);
   %NIR = fliplr(NIR);

   NIR = double(NIR);
   RED = double(RED);

   Result = NIR./RED;
   
end