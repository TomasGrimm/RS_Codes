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