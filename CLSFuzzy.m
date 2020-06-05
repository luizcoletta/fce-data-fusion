function [valorSF] = CLSFuzzy(U, x, alfa, w, qtdeObj)
% ***********************************************************************************
% SILHUETAFUZZY: Medida de validacao das particoes, determina a melhor particao
%
% DESCRICAO:
%
% FUNCAO: [valorSF] = silhuetafuzzy(U, x, qtdeObj)
%
% ONDE:
%
% EXEMPLOS:
% [valorSF] = silhuetafuzzy(U, x, qtdeObj)
%
% AUTOR: Luiz Fernando S. C. - 26/10/08
% ATUALIZADO: Luiz Fernando S. C. - 19/02/09
% ***********************************************************************************

constpeq = 10e-5;
ai = 0;
bi = 0;
sfden = 0;
sfdiv = 0;

for i = 1:size(U,2)
    
    priMaior = -1;
    segMaior = -1;
    indPriMaior = -1;
    indSegMaior = -1;
    
    uAux = U;
    r = find(uAux(:,i)==max(uAux(:,i)),1,'first');
    priMaior = uAux(r,i);
    indPriMaior = r;
    uAux(r,i) = -1;
    
    r = find(uAux(:,i)==max(uAux(:,i)),1,'first');
    segMaior = uAux(r,i);
    indSegMaior = r;
    
    ai = x(indPriMaior,i);
    bi = x(indSegMaior,i);
    maxAB = max(ai,bi);
    sic=(bi-ai)/(maxAB+constpeq);
    
    sif = ((priMaior-segMaior)^alfa)*w(i);
    %sif = ((priMaior-segMaior)^alfa);
    
    %if (qtdeObj(indPriMaior)<=1)
    %    fprintf('\n-----------------------------------------------\n');
    %    fprintf('CLUSTER PENALIZADO - Singleton Cluster\n');
    %    fprintf('-----------------------------------------------\n');
    %else
        si=sif*sic;
        sfden=sfden+si;
    %end
    sfdiv=sfdiv+sif;
end

valorSF = sfden/(sfdiv+constpeq);
