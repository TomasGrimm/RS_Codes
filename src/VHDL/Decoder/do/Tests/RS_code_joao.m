%=================================================================
% LIMPEZA
%=================================================================
clc
clear

%=================================================================
% CONFIGURAÇOES GERAIS
%=================================================================
load('RS.mat')

warning('off', 'HDLLink:HDLSimScript:UnknownHdlSimVersion');
warning('off', 'HDLLink:HDLSimScript:UnsupportedModelSim');

iterations = 1;
messages = 2;
test_coder = 0;
test_decoder = 1;

erro = 0;
email = 'tomas.grimm@gmail.com';
username = 'tomas.grimm@gmail.com';
server = 'smtp.gmail.com';
password = '';
config_email(email, username, server, password);

qtidade_acerto_CODER = 0;
qtidade_acerto_DECODER = 0;

% tempo necessario para rodar vsim
tempo_de_pausa = 2;

%=================================================================
% SIMULACOES
%=================================================================
for i = 1:iterations
    for j = 1:messages
        %=================================================================
        % CRIAÇAO DA MENSAGEM
        %=================================================================
        % k palavras de m bits, vetor coluna unico
        message = randi([0 1],(k*m), 1);
        
        if test_coder == 1
            print_file(message, ['message' num2str(j) '.txt'], m);
        end
        
        %=================================================================
        % CODIFICAÇAO
        %=================================================================
        codeword = step(rsEnc, message);
        print_file(codeword, ['codeword_golden' num2str(j) '.txt'], m);
        
        %=================================================================
        % INSERÇAO DE ERROS
        %=================================================================
        if test_decoder == 1
            received = codeword;
            errors = randi([0 8]);
            r = randperm(n);
            positions = r(1:errors);

            for l = 1:errors
                pos = positions(l) * m;
                element = de2bi(randi([1 n]), m, 'left-msb');
                
                for o = 0:m - 1
                    received(pos - o) = element(m - o);
                end
            end

            print_file(received, ['received' num2str(j) '.txt'], m);
        end
        
        %=================================================================
        % DECODIFICAÇAO
        %=================================================================
        if test_decoder == 1
            [estimated errs] = step(rsDec, received);
        end
    end
    
    %=================================================================
    % SIMULAÇOES
    %=================================================================
    if test_coder == 1
        delete('codeword_vhdl*.txt');
        vsim('runmode','Batch','rundir', '../', 'tclstart', 'do RS_coder_tb.do');
        pause(tempo_de_pausa)
    end
    
    if test_decoder == 1
        delete('estimated_vhdl*.txt');
        vsim('runmode','Batch','rundir', '../', 'tclstart', 'do RS_decoder_tb.do'); %'/mnt/linux/RS/V2.0deco/Decoder/do'
        pause(tempo_de_pausa)
    end
    
    for j = 1:messages
        %=================================================================
        % COMPARAÇAO CODIFICADOR
        %=================================================================
        if test_coder == 1
            fid = fopen(['codeword_vhdl' num2str(j) '.txt'], 'r');
            fgetl(fid);
            buffer = fread(fid, Inf);
            fclose(fid);
            
            fid = fopen(['codeword_vhdl' num2str(j) '.txt'], 'w');
            fwrite(fid, buffer);
            fclose(fid);
            
            file_1 = javaObject('java.io.File', ['codeword_golden' num2str(j) '.txt']);
            file_2 = javaObject('java.io.File', ['codeword_vhdl' num2str(j) '.txt']);
            is_equal = javaMethod('contentEquals','org.apache.commons.io.FileUtils', file_1, file_2);

            qtidade_acerto_CODER = is_equal + qtidade_acerto_CODER;

            if is_equal == 0
                erro = 1;
                sendmail(email, 'Matlab - Erro', ['Erro na mensagem ' num2str(j) ' durante a codificação. Iteração: ' num2str(i)]);
                break
            end
        end
        
        %=================================================================
        % COMPARAÇAO DECODIFICADOR
        %=================================================================
        if test_decoder == 1
            fid = fopen(['estimated_vhdl' num2str(j) '.txt'], 'r');
            fgetl(fid);
            buffer = fread(fid, Inf);
            fclose(fid);
            
            fid = fopen(['estimated_vhdl' num2str(j) '.txt'], 'w');
            fwrite(fid, buffer);
            fclose(fid);
            
            file_1 = javaObject('java.io.File', ['codeword_golden' num2str(j) '.txt']);
            file_2 = javaObject('java.io.File', ['estimated_vhdl' num2str(j) '.txt']);
            is_equal = javaMethod('contentEquals','org.apache.commons.io.FileUtils', file_1, file_2);

            qtidade_acerto_DECODER = is_equal + qtidade_acerto_DECODER;

            if is_equal == 0
                erro = 1;
                sendmail(email, 'Matlab - Erro', ['Erro na mensagem ' num2str(j) ' durante a decodificação. Iteração: ' num2str(i)]);
                break
            end
        end
    end
    
    %=================================================================
    % AUDITORIA
    %=================================================================
    if test_coder == 1
        qtidade_acerto_CODER
    end
    
    if test_decoder == 1
        qtidade_acerto_DECODER
    end
    
    i
end

if (erro == 0)
    sendmail(email, 'Matlab - Completado', 'Simulação executada com sucesso.');
    delete('codeword_golden*.txt');
    delete('received*.txt');
    delete('estimated_vhdl*.txt');
end
