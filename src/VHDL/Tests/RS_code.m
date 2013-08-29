%function RS_code
% Codificacao de uma mensagem pelo codigo RS (255, 239)

clear;
clc;

% Parametros do codigo
n = 255;
k = 239;
m = 8;

% Especifcacao do codificador e do decodificador
rsEnc = comm.RSEncoder(n, k);
rsEnc.BitInput = true;
rsEnc.PrimitivePolynomialSource = 'Property';
rsEnc.PrimitivePolynomial = [1 0 0 0 1 1 1 0 1];
rsEnc.GeneratorPolynomialSource = 'Property';
rsEnc.GeneratorPolynomial = [1, 59, 13, 104, 189, 68, 209, 30, 8, 163, ...
    65, 41, 229, 98, 50, 36, 59];

rsDec = comm.RSDecoder(n, k);
rsDec.BitInput = true;
rsDec.PrimitivePolynomialSource = 'Property';
rsDec.PrimitivePolynomial = [1 0 0 0 1 1 1 0 1];
rsDec.GeneratorPolynomialSource = 'Property';
rsDec.GeneratorPolynomial = [1, 59, 13, 104, 189, 68, 209, 30, 8, 163, ...
    65, 41, 229, 98, 50, 36, 59];

% criacao da mensagem
message = zeros((k*m), 1);

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

fd = fopen('codeword_golden.txt', 'w');

for i = 1:size(codeword, 1)
    fprintf(fd, '%d', codeword(i, 1));
    
    if (mod(i, m) == 0)
        fprintf(fd, '\n');
    end
end

fclose(fd);

% Insercao de erro
%errors = randi([1 8]);
errors = 9;
received = zeros(size(codeword, 1), 1);

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

fd = fopen('received.txt', 'w');

for i = 1:size(received, 1)
    fprintf(fd, '%d', received(i, 1));
    
    if (mod(i, m) == 0)
        fprintf(fd, '\n');
    end
end

fclose(fd);

% Decodificacao
estimated = step(rsDec, received);

fd = fopen('estimated_golden.txt', 'w');

for i = 1:size(estimated, 1)
    fprintf(fd, '%d', estimated(i, 1));
    
    if (mod(i, m) == 0)
        fprintf(fd, '\n');
    end
end

fclose(fd);

%exit
