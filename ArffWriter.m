function ArffWriter(dir, fname, data, withClass)
% *************************************************************************
% ArffWriter: convert a matrix m x n to a weka input file (.arff), where m 
%             are the objects and n-1 are their features - the last column 
%             is the class label (as being integer).
%              
% Example:  ArffWriter([pwd,'/results/'], 'datafile', x);
%           
% Author: Luiz F. S. Coletta (luiz.fersc@gmail.com) - 30/01/18
% Update: Luiz F. S. Coletta - 08/02/18
% ************************************************************************* 

if (withClass)
   sss=size(data,2)-1;
else
   sss=size(data,2); 
end
filename1=strcat([dir, fname, '.arff']);
out1 = fopen (filename1, 'w+');
aa1=strcat('@relation', {' '}, fname);
fprintf (out1, '%s\n\n', char(aa1));

for jj=1:sss
   fprintf(out1, '@attribute feature%s numeric\n', num2str(jj));
end

if (withClass)
    n_classes=max(unique(data(:,end)));
    txt1=strcat('@attribute class {');

    for ii=0:n_classes
        if (ii == n_classes)
            txt1=strcat(txt1, num2str(ii));    
        else
            txt1=strcat(txt1,num2str(ii),{','});    
        end 
    end
    txt1=strcat(txt1,{'}'});
    
    fprintf(out1, '%s\n\n', char(txt1));
else 
    fprintf(out1, '\n');
end 

fprintf(out1,'@data\n');

fclose(out1);

dlmwrite(filename1, data, '-append', 'precision', 4);
