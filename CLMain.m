function [melhorSF, melhorFO, melhorU, melhorC, dados, vmSF, itt] = CLMain(dirIn, dtBases, dsLocal, semEst, calcSF, grIni, grFim, prVirt, nPrVirt)
% *************************************************************************
% AFC_AMOSTFCM: Processo de amostragem do algoritmo FCM (colaborativo)
%
% DESCRICAO:
%
% FUNCAO: [melhorSF, melhorFO, melhorU, melhorC, dados] = afc_amostfcm(dirIn, dtBases, dsLocal, semEst, calcSF, grIni, grFim, prVirt, nPrVirt)
%
% ONDE:
%
% EXEMPLOS:
%
% AUTOR: Luiz F. S. Coletta - 17/08/09
% ATUALIZADO: Luiz F. S. Coletta - 24/08/09
% *************************************************************************

alfaSF = 1;
dirDB = [dirIn, dtBases(dsLocal,:), '.txt'];
dados = load(dirDB); % carrega arquivo de dados
if (semEst==1)
    dados = afc_gera_dados(size(dados,1),min(dados(:,1)),max(dados(:,1)),min(dados(:,2)),max(dados(:,2)));
end
opcoes = [
    2    % valor do fator de fuzzificacao m
    100  % numero maximo de iteracoes
    1e-5 % criterio de parada baseado num limiar entre duas funcoes objetivos
    ];
inicializacoes = 20;  % numero de inicializacoes para cada c grupo

w = ones(size(dados,1),1);                                                             
if (prVirt~=0)
    dados = [dados;prVirt];
    w = [w;nPrVirt]; 
end
                                      
vetorFO = 0;
vetorSF = 0;
vmSF = ones(grFim-1,1)*(-1);
melhorSF = -1;
melhorFO = 10e10;
melhorU = -1;
melhorC = -1;

itt = 0;

for i = grIni:grFim
    for j = 1:inicializacoes
        
%       fprintf('\n\n-----------------------------------------------------\n');
%       fprintf('GRUPO %d / Inicializacao %d / %s\n', i, j, datestr(now));
%       fprintf('-----------------------------------------------------\n');
        
        [center, U, fobj, X, it] = afc_fcm(dados, i, opcoes, w);
        
        itt = itt+it;
        
        %------------------------------------------------------------------
        % Funcao Objetivo do FCM
        %------------------------------------------------------------------
        if (vetorFO == 0)
            vetorFO = min(fobj);
        else    
            vetorFO = [vetorFO; min(fobj)];
        end
        if (min(fobj) < melhorFO)
             melhorFO = min(fobj);
             if (calcSF~=1)
                melhorU = U;
                melhorC = center;
             end   
        end
       
        %------------------------------------------------------------------
        %--- CALCULO DA SILHUETA FUZZY
        %------------------------------------------------------------------
        if (calcSF==1)
            sfCorrente = afc_silhuetafuzzy(U, X, alfaSF, w, afc_objgrupo(U, w));
            vetorSF = [vetorSF; sfCorrente];
            if (sfCorrente > vmSF(i-1,1))
                vmSF(i-1,1) = sfCorrente;
            end 
            if (sfCorrente > melhorSF)
                melhorSF = sfCorrente;
                melhorU = U;
                melhorC = center;
            end
        end
    end
end
