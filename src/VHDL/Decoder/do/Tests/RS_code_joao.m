clc
clear
load('RS.mat')
qtidadeacerto=0;
for repet = 1:2


% criacao da mensagem
message = randi([0 1],(k*m), 1); %k palavras de m bits, vetor coluna unico

%fd = fopen('message.txt', 'w');

%for i = 1:size(message, 1)
%    fprintf(fd, '%d', message(i, 1));
    
%    if (mod(i, m) == 0)
%        fprintf(fd, '\n');
%    end
%end

%fclose(fd);

% Codificacao
codeword = step(rsEnc, message);

% fd = fopen('codeword_golden.txt', 'w'); %escreve msg codificada
% 
% for i = 1:size(codeword, 1)
%     fprintf(fd, '%d', codeword(i, 1));
%     
%     if (mod(i, m) == 0)
%         fprintf(fd, '\n');
%     end
% end
% 
% fclose(fd);

% Insercao de erro
errors =  randi([0 8]); %

received = codeword;

for i = 1:errors
    position = randi([1 n]) * m;
    element = de2bi(randi([1 n]), m, 'left-msb');
    
    received(position) = element(8);
    received(position - 1) = element(7);
    received(position - 2) = element(6);
    received(position - 3) = element(5);
    received(position - 4) = element(4);
    received(position - 5) = element(3);
    received(position - 6) = element(2);
    received(position - 7) = element(1);
end

fd = fopen('received.txt', 'w'); %escreve msg codificada +erros

for i = 1:size(received, 1)
    fprintf(fd, '%d', received(i, 1));
    
    if (mod(i, m) == 0)
        fprintf(fd, '\n');
    end
end

fclose(fd);

% Decodificacao
[estimated errs] = step(rsDec, received); %decodifica received

% fd = fopen('estimated_golden.txt', 'w');
% 
% for i = 1:size(estimated, 1)
%     fprintf(fd, '%d', estimated(i, 1));
%     
%     if (mod(i, m) == 0)
%         fprintf(fd, '\n');
%     end
% end
% 
% fclose(fd);

%comparacao
fileID = -1; 

delete estimated_vhdl.txt
vsim('runmode','Batch','rundir','C:\João\linux\RS\V1.4deco\Decoder\do', 'tclstart', 'do RS_decoder_tb.do'); % '/mnt/linux/RS/V1.5deco/Decoder/tb'

pause(6)%espera

while fileID < 0 %garantia para pegar o ID certo, espera vsim gerar arquvivo 
    fileID = fopen('estimated_vhdl.txt');
end

estimated_word_vhdl = zeros(m*k,1);
C = fgetl(fileID);%a primeira eh lixo, descartando ela


for i = 1:k
    C = fgetl(fileID);
    for j = 1:m
        estimated_word_vhdl(i*m-8+j,1) = C(j)-48;
    end
end

fclose(fileID);

clear ans

certo=all(estimated_word_vhdl==estimated);
qtidadeacerto = certo + qtidadeacerto;
repet
end
qtidadeacerto
