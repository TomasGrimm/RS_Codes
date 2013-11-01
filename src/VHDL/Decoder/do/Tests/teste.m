GeneratorPolynomial = [1 4 7 7 5]; %[1 3 1 2 3]; %[1, 59, 13, 104, 189, 68, 209, 30, 8, 163, 65, 41, 229, 98, 50, 36, 59];
a = GeneratorPolynomial;
m = 8; %tamanho do vetor 
de2bi(a',m,'left-msb')