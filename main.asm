#Grupo: Gabriel Cisneiros, Lucas Aurélio e Marcela Hadassa (Equipe Rocket)
#Projeto: 1ª VA
#Disciplina: Arquitetura e organização de computadores
#Semestre letivo: 2024.1
#Arquivo: Main
#Descrição: Sistema com todos as funcionalidades

#macro que printa uma string utilizando o endereço dela como variavel
.macro printString %endereco_str
    li $v0, 4
    la $a0, %endereco_str #carrega o end da string em $a0
    syscall
.end_macro

.macro lerString %endereco, %limiteChar
    li $v0, 8          # Syscall para leitura de string
    la $a0, %endereco     # Carregar o endereço da string
    li $a1, %limiteChar     # Carregar o limite de caracteres
    syscall            # Chamada de sistema
.end_macro

#macro que ler um inteiro e usa o endereço como variavel
.macro lerInt %endereco
    li $v0, 5
    syscall
    move %endereco, $v0
.end_macro

.data
moradores:  .space 5760   # 12 andares x 2 apartamentos por andar x 6 moradores x 40 bytes (nome) por morador
veiculos:     .space 1440   # 12 andares x 2 apartamentos por andar x  30 bytes (20 bytes modelo + 10 bytes placa) por veiculo x 2 motos (maior espaço possível)
input:     .space 100         #espaço reservado para o input do usuário
mensagemPrintar:  .space 100  #espaço reservado para o print da mensagem

banner:     .asciiz "\nGLM-shell>> "
comandoSair:   .asciiz "exit"
# modificar caminho caso seja necessário, pois não existe caminho relativo
path_formatar: .asciiz "/home/gabriel/Projetos/Projeto1ASM/Dados-Salvos/formatar.txt"
path_moradores:  .asciiz "/home/gabriel/Projetos/Projeto1ASM/Dados-Salvos/moradores.txt"
path_veiculos:  .asciiz "/home/gabriel/Projetos/Projeto1ASM/Dados-Salvos/veiculos.txt"
addMorador:  .asciiz "addMorador"
salvar:   .asciiz "salvar"
recarregar: .asciiz "recarregar"
formatar: .asciiz "formatar"
newline:    .asciiz "\n"
limparAp:     .asciiz "limparAp"
infoAp:       .asciiz "infoAp"
comandoInvalido: .asciiz "Comando inválido.\n"
msg_apto_cheio:  .asciiz "Apartamento cheio! Nao pode adicionar mais moradores.\n"
msg_morador_registrado: .asciiz "Morador cadastrado com sucesso!"
msg_registrar:   .asciiz "Digite o nome do morador:\n"
msg_andar:       .asciiz "Digite o andar (1-12):\n"
msg_apto:        .asciiz "Digite o numero do apartamento (1 ou 2):\n"
msg_aptos_vazios:   .asciiz "Numero de apartamentos vazios: \n"
msg_aptos_ocupados: .asciiz "Numero de apartamentos ocupados: \n"
apInvalido: .asciiz "Número de apartamento inválido!\n"
addAuto:  .asciiz "addAuto"
msg_vagas_ocupadas: .asciiz "\nEsse apartamento ja esgotou todas as vagas disponiveis\n"
msg_veiculo:     .asciiz "\nVocê deseja registrar um carro ou moto? (1=carro, 2=moto):\n"
tipoInvalido: .asciiz "Opção inválida.\n"
msg_modelo:      .asciiz "\nDigite o modelo do veículo:\n"
msg_placa:       .asciiz "\nDigite a placa do veículo:\n"
msg_carro_registrado: .asciiz "\nCarro registrado com sucesso!\n"
msg_moto_registrada:  .asciiz "\nMoto registrada com sucesso!\n"
msg_carro_existente:  .asciiz "\nEste apartamento não pode registrar um carro.\n"
msg_motos_existentes: .asciiz "\nEste apartamento já possui duas motos cadastradas. Não pode registrar mais veículos.\n"
msg_vazios:         .asciiz "Numero de apartamentos vazios: "
msg:        .asciiz "\nPorcentagens de apartamentos ocupados: ("
porcentagem: .asciiz "%)"
relatorio: .asciiz "relatorio"
apartamentoLimpo: .asciiz "Apartamento limpo com sucesso"
.text

# Inicializa contadores
    li $s0, 24  # Total de apartamentos (24)
    li $s1, 0   # Contador de apartamentos ocupados

# Loop principal do shell
printBanner:
    
    printString banner #imprime o banner no terminal com as iniciais do grupo
 
    lerString input, 100 #recebe e lê o input do usuário

    la $t0, input  #carrega o endereço do input em t0
    li $t1, 0      #inicializa o contador de indices em t1
    
procuraEnter: #troca o enter do input por fim da string (\0) para que apenas a parte da string em si lida
    lb $t2, 0($t0)     #carrega o byte n em t2
    beqz $t2, comparaComandoExit   #se o byte for nulo, entra em comparaComandoExit para comparar com os comandos cadastrados
    beq $t2, 10, fimDeString  #verifica se em t2 (endereço do byte atual) é 10 (valor ASCII do \n que é o enter), se for ele entra em fimDeString
    addi $t0, $t0, 1            #incrementa o índice
    j procuraEnter #volta pra procuraEnter

fimDeString:
    sb $zero, 0($t0)  #armazena fim de linha em na posição que enter foi encontrado
    j comparaComandoExit #entra em comparaComandoExit

comparaComandoExit: #compara com o comando exit
    la $a0, input              #carrega o endereço do input em a0
    la $a1, comandoSair        #carrega o endereço do comando "exit" em a1
    jal strcmp                 #chama a função strcmp 
    bnez $v0, comparaAddAuto     #se não for "exit", verifica se é print
    
    #se for "exit", encerra o programa
    li $v0, 10                  #syscall para sair do programa
    syscall                    

comparaAddAuto:
la $a0, input
la $a1, addAuto
jal strcmp
bnez $v0, comparaRelatorio

    # Solicita o andar
    printString(msg_andar)
    
    # Lê o Int Andar e armazena em $t0
    lerInt($t0)
    subi $t0, $v0, 1          # $t0 = andar (0-11)
     
    blt $t0, $zero, inputInvalido #verifica se o numero do aptmento é válido
    bgt $t0, 11, inputInvalido
    
    # Solicita o número do apartamento
    printString(msg_apto)
    
    # Lê o Int Apartamento e armazena em $t1
    lerInt($t1)
    subi $t1, $t1, 1          # $t1 = apartamento (0 ou 1)
    
    blt $t1, $zero, inputInvalido #verifica se o numero do aptmento é válido
    bgt $t1, 1, inputInvalido
    
    
    # Calcula o índice base no array de veículos
    sll $t2, $t0, 1          # t2 = andar x 2 = indice do primeiro apartamento do andar (ex: andar 1 = apt 2 e 3, logo o primeiro apt do andar 1 é 2)
    add $t2, $t2, $t1        # t2 = índice do apartamento (0-23)= = somar o numero do apartamento ao endereço base 
    li $t3, 60               # t3 = Tamanho do espaço reservado para cada apartamento (60 bytes = 30 bytes por veículo x no máximo 2)
    mul $t2, $t2, $t3        # calcula o endereço no vetor veiculos contando 60 bytes para cada, (apt 3 x 60 = 180 = posição inicial do terceiro apt)
    
    # Verifica quantos veículos já estão cadastrados no apt
    li $t4, 0                 # Contador de veículos
    li $t5, 30                # Tamanho de um "veiculo" (30 bytes)
    
    printString(msg_veiculo)
    lerInt($t7)           # $t7 = tipo de veículo (1=carro, 2=moto)
    blt $t7, 1, tipoVeiculoInvalido #verifica se o numero do opção é válida
    bgt $t7, 2, tipoVeiculoInvalido
    beq $t7, 1, verifica_carro # Se for carro, verifica se já existe um carro registrado    
    
verifica_moto:

    lb $t6, veiculos($t2)   # carrega em t6 o byte na posição indicada por t2 em veiculos
    beqz $t6, cadastrar_moto # se t6 for 0, significa que não está ocupado, portanto pula para registrar veículo
    addi $t4, $t4, 1          # caso t6 não seja 0, temos que o endereço de memória está com outro veículo. Por isso, incrementa o contador de moradores
    add $t2, $t2, $t5         # t2 = endereço do próximo espaço para veiculo obtido ao soma o endereço atual do vetor com 30 (espaço de um veiculo)
    bne $t4, 2, verifica_moto # Continua verificando se menos de 6 moradores
    
vagas_esgotadas:    
    # Se já houver 2 veiculos não há mais vagas, printa e volta pro loop
    printString(msg_vagas_ocupadas)
    j printBanner

cadastrar_moto:
    
    # Se for moto
    printString(msg_modelo)
    
    li $v0, 8                 # Lê o modelo da moto
    la $a0, veiculos($t2)     #armazena em veiculos(t2)
    li $a1, 20                # Tamanho do modelo é 20 bytes
    syscall
    
    printString(msg_placa)
    
    li $v0, 8                 # Lê a placa da moto
    la $a0, veiculos($t2)      #armazena em veiculos(t2)
    addi $a0, $a0, 20         # Offset para a placa (20 bytes após o modelo)
    li $a1, 10                # Tamanho da placa é 10 bytes
    syscall
    
    printString(msg_moto_registrada)             

    j printBanner
    
    verifica_carro:
    # Se o espaço já estiver ocupado (ou seja, um carro já registrado)
    lb $t6, veiculos($t2)   # Verifica se a posição está ocupada
    bnez $t6, carro_existente
    
    # Se não estiver ocupado, registra o carro
    printString(msg_modelo)
    
    li $v0, 8               # Lê o modelo do carro
    la $a0, veiculos($t2)
    li $a1, 20              # Tamanho do modelo é 20 bytes
    syscall
    
    printString(msg_placa)
    
    addi $t2, $t2, 20       # Offset para a placa (20 bytes após o modelo)
    li $v0, 8               # Lê a placa do carro
    la $a0, veiculos($t2)
    li $a1, 10              # Tamanho da placa é 10 bytes
    syscall
    
    printString(msg_carro_registrado)

    # Preenche os 30 bytes restantes com 'x'
    addi $t2, $t2, 10       # Offset para os 30 bytes restantes (após modelo + placa)
    li $t3, 30              # Número de bytes a preencher
    li $t4, 'x'             # Caractere 'x' ASCII

preenche_espaco:
    sb $t4, veiculos($t2)          # Armazena 'x' no espaço
    addi $t2, $t2, 1        # Avança para o próximo byte
    subi $t3, $t3, 1        # Decrementa contador
    bnez $t3, preenche_espaco  # Continua preenchendo até completar 30 bytes
    
   j printBanner
    
carro_existente:
    printString(msg_carro_existente)
    j printBanner                # Volta ao início
 
comparaRelatorio: 
  # Verifica se o comando é "addMorador"
    la $a0, input             # Carrega o endereço do input em $a0
    la $a1, relatorio        # Carrega o endereço do comando "relatorio" em $a1
    jal strcmp                # Chama a função strcmp
    bnez $v0, comparaLimparAp   # Se não for "relatorio", entra em comparaLimparAp


    # Calcular a porcentagem: (parte / total) * 100
    mul $t2, $s1, 100       # $t2 = parte * 100
    div $t2, $s0            # $t2 = (parte * 100) / total
    mflo $t2                # Mover o resultado da divisão para $t2
    
    # Calcula e imprime o número de apartamentos vazios
    sub $t7, $s0, $s1         # $t7 = Total de apartamentos - ocupados
    printString(msg_vazios)   # Imprime mensagem de apts vazios
    move $a0, $t7
    li $v0, 1
    syscall
    
    printString msg
   
    # Converter e imprimir o número (a porcentagem)
    move $a0, $t2           # Move o valor calculado para $a0
    jal printInteger        # Chama função para imprimir o valor
    printString porcentagem
    
    
   j printBanner
   
# Função para imprimir um número inteiro
printInteger:
    li $v0, 1               # syscall para imprimir inteiro
    syscall
    jr $ra                  # Retorna à função chamadora


comparaLimparAp:

	la $a0, input #coloca
	la $a1, limparAp #coloca as strings nos registradores certos para a função strcmp
	jal strcmp #Compara o comando pra saber se é o comando "limparAp"
	bnez $v0, comparaSalvar #Se não for, pula para comparaSalvar

    printString (msg_andar) # Pede o andar do novo morador
    lerInt($t0) # lê efetivamente o Andar e armazena em t0
    subi $t0, $t0, 1 #subtrai o inteiro digitado para ficar de 0-11
    
  
    blt $t0, $zero, inputInvalido #verifica se o numero do aptmento é válido
    bgt $t0, 11, inputInvalido
    
    printString(msg_apto) # Pede o apartamento do novo morador
    lerInt($t1) # lê efetivamente o número do Apartamento e armazena em t1
    subi $t1, $t1, 1 # $t1 = número apartamento digitado - 1 = 0/1
    
    blt $t1, $zero, inputInvalido  #verifica se o numero do andar é válido
    bgt $t1, 1, inputInvalido
    
     # Calcula posição no array de moradores para zerar o apartamento
    sll $t2, $t0, 1           # t2 = andar x 2 = índice do primeiro apartamento do andar 
    add $t2, $t2, $t1         # t2 = índice do apartamento (0-23)
    li $t3, 240               # t3 = tamanho do espaço reservado para cada apartamento (240 bytes)
    mul $t2, $t2, $t3         # t2 = endereço no vetor moradores

    # Guardar 0 nos 240 bytes referentes ao apartamento
    li $t4, 240               # $t4 = número de bytes a serem limpos
    li $t5, 0                # $t5 = valor a ser armazenado (0)

zerarMoradores:
    beq $t4, $zero, moradoresLimpos  # Se $t4=0, já zeramos todos os bytes do apartamento relacionado  então vai para moradoresLimpos
    sb $t5, moradores($t2)      # Armazena o byte que está em t5 (0) na posição indicada por t2 em moradores
    addi $t2, $t2, 1            # Passa para o byte n+1
    subi $t4, $t4, 1            # decrementa os bytes restantes
    j zerarMoradores            # volta pro loop
    
moradoresLimpos:

    # Agora, calcula a posição no array para o veículo

    sll $t2, $t0, 1           # t2 = andar x 2 = índice do primeiro apartamento do andar 
    add $t2, $t2, $t1         # t2 = índice do apartamento (0-23)
    li $t3, 60                # t3 = tamanho do espaço reservado para cada apartamento (30 bytes por veiculo x 2 veiculos =60 bytes)
    mul $t2, $t2, $t3         # t2 = endereço no vetor moradores

    li $t6, 60                # $t6 = numero de bytes a serem limpos
    li $t7, 0                 # $t7 = valor a ser armazenado (0)

zerarVeiculo:
    beq $t6, $zero, veiculosLimpos  	 # Se $t6 == 0, acabamos de zerar os veiculos do ap e vamos para veiculosLimpos
    sb $t7, veiculos($t2)               # Armazena 0 na posição t2 de veiculos
    addi $t2, $t2, 1                    # Incrementa para n+1
    subi $t6, $t6, 1                    # Decrementa os espaços restantes
    j zerarVeiculo                      # volta pro loop

veiculosLimpos: #veiculos já limpos com sucesso
    printString(apartamentoLimpo) #printar a msg
    subi $s1, $s1, 1 #subtrai a quantidade de apts ocupados
    j printBanner

comparaSalvar:
	# verifica se o comando é salvar
	la $a0, input # Carrega o endereço do input em $a0
	la $a1, salvar # Carrega o endereço do comando "salvar" em $a1
	jal strcmp # Chama a função strcmp
	bnez $v0, comparaRecarregar # Se não for "salvar", entra em comparaAddMorador
	
	# salva moradores
	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_moradores # passa o caminho para o arquivo moradores.txt
	li $a1, 1 # carrega o valor 1 (modo de escrita) em $a1
	li $a2, 664 # define as permissões do arquivo como 664
	syscall # abre o arquivo
	
	move $s0, $v0 # move o descritor do arquivo (retornado no $v0) para $s0
	
	li $v0, 15 # carrega o código de serviço 15 (escrever em arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	la $a1, moradores # Carrega o endereço da string moradores no registrador $a1
	li $a2, 5760 # define o numero de bytes a serem escritos como 5760 (numero de bytes de moradores)
	syscall # escreve a string moradores em moradores.txt
	
	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo
	
	# salva veículos
	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_veiculos # passa o caminho para o arquivo veiculos.txt
	li $a1, 1 # carrega o valor 1 (modo de escrita) em $a1
	li $a2, 664 # define as permissões do arquivo como 664
	syscall # abre o arquivo
	
	move $s0, $v0 # move o descritor do arquivo (retornado no $v0) para $s0
	
	li $v0, 15 # carrega o código de serviço 15 (escrever em arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	la $a1, veiculos # carrega o endereço da string veiculos no registrador $a1
	li $a2, 1440 # define o numero de bytes a serem escritos como 1440 (numero de bytes de veiculos)
	syscall # escreve a string veiculos em veiculos.txt
	
	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo
	
	j printBanner

comparaRecarregar:
	# verifica se o comando é recarregar
	la $a0, input # Carrega o endereço do input em $a0
	la $a1, recarregar # Carrega o endereço do comando "recarregar" em $a1
	jal strcmp # Chama a função strcmp
	bnez $v0, comparaFormatar # Se não for "recarregar", entra em comparaFormatar
    
	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_moradores # passa o caminho para o arquivo moradores.txt
	li $a1, 0 # carrega o valor 0 (modo de leitura) em $a1
	syscall # abre o arquivo

	move $s0, $v0

	li $v0, 14 # carrega o codigo de serviço 14 (ler do arquivo)
	move $a0, $s0 # move o descritor do arquivo para $a0
	la $a1, moradores # carrega a string de moradores em $a1
	li $a2, 5760 # define o numero de bytes a serem escritos como 5760 (numero de bytes de moradores)
	syscall # lê os veiculos do arquivo

	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo

	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_veiculos # passa o caminho para o arquivo veiculos.txt
	li $a1, 0 # carrega o valor 0 (modo de leitura) em $a1
	syscall # abre o arquivo

	move $s0, $v0

	li $v0, 14 # carrega o codigo de serviço 14 (ler do arquivo)
	move $a0, $s0 # move o descritor do arquivo para $a0
	la $a1, veiculos # carrega a string de veiculos em $a1
	li $a2, 1440 # define o numero de bytes a serem escritos como 1440 (numero de bytes de veiculos)
	syscall # lê os veiculos do arquivo

	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo
	
	j printBanner

comparaFormatar:
	# verifica se o comando é formatar
	la $a0, input # Carrega o endereço do input em $a0
	la $a1, formatar # Carrega o endereço do comando "formatar" em $a1
	jal strcmp # Chama a função strcmp
	bnez $v0, comparaAddMorador # Se não for "formatar", entra em comparaAddMorador
    
	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_formatar # passa o caminho para o arquivo formatar.txt
	li $a1, 0 # carrega o valor 0 (modo de leitura) em $a1
	syscall # abre o arquivo

	move $s0, $v0

	li $v0, 14 # carrega o codigo de serviço 14 (ler do arquivo)
	move $a0, $s0 # move o descritor do arquivo para $a0
	la $a1, moradores # carrega a string de moradores em $a1
	li $a2, 0 # define o numero de bytes a serem lidos como 0 (numero de bytes para formatar)
	syscall # lê os moradores do arquivo de formatação

	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo

	li $v0, 13 # carrega o codigo de serviço 13 (abrir arquivo)
	la $a0, path_formatar # passa o caminho para o arquivo formatar.txt
	li $a1, 0 # carrega o valor 0 (modo de leitura) em $a1
	syscall # abre o arquivo

	move $s0, $v0

	li $v0, 14 # carrega o codigo de serviço 14 (ler do arquivo)
	move $a0, $s0 # move o descritor do arquivo para $a0
	la $a1, veiculos # carrega a string de veiculos em $a1
	li $a2, 0 # define o numero de bytes a serem escritos como 0 (numero de bytes para formatação)
	syscall # lê os veiculos do arquivo

	li  $v0, 16 # carrega o código de serviço 16 (fechar arquivo)
	move $a0, $s0 # move o descritor do arquivo para o registrador $a0
	syscall # fecha o arquivo
	
	j printBanner

comparaAddMorador:

    # Verifica se o comando é "addMorador"
    la $a0, input             # Carrega o endereço do input em $a0
    la $a1, addMorador        # Carrega o endereço do comando "addMorador" em $a1
    jal strcmp                # Chama a função strcmp
    bnez $v0, printComandoInvalido   # Se não for "addMorador", entra em printComandoInvalido


    printString (msg_andar) # Pede o andar do novo morador
    lerInt($t0) # lê efetivamente o Andar e armazena em t0
    subi $t0, $t0, 1 #subtrai o inteiro digitado para ficar de 0-11
    
    blt $t0, $zero, inputInvalido #verifica se o numero do aptmento é válido
    bgt $t0, 11, inputInvalido
    
    printString(msg_apto) # Pede o apartamento do novo morador
    lerInt($t1) # lê efetivamente o número do Apartamento e armazena em t1
    subi $t1, $t1, 1 # $t1 = número apartamento digitado - 1 = 0/1
    
    blt $t1, $zero, inputInvalido  #verifica se o numero do andar é válido
    bgt $t1, 1, inputInvalido
    
    # Calcula posição no array de moradores
    sll $t2, $t0, 1           # t2 = andar x 2 = índice do primeiro apartamento do andar 
    add $t2, $t2, $t1         # t2 = índice do apartamento (0-23)
    li $t3, 240               # t3 = tamanho do espaço reservado para cada apartamento (240 bytes)
    mul $t2, $t2, $t3         # t2 = endereço no vetor moradores
    	
    # Calcula quantos moradores existem no apartamento
    li $t4, 0                 # t4 = quantidade de moradores (começa em 0)
    li $t5, 40                # t5 = tamanho de um nome (40 bytes)
    
check_moradores:
    lb $t6, moradores($t2)    # carrega em $t6 o byte na posição indicada por $t2 em moradores
    beqz $t6, verificarNovaOcupacao       # se $t6 for 0, apartamento está vazio, registra o morador
    addi $t4, $t4, 1          # incrementa contador de moradores
    add $t2, $t2, $t5         # incrementa $t2 para próximo espaço de morador
    bne $t4, 6, check_moradores # se não ultrapassar 6 moradores, verifica o próximo

    # Caso já existam 6 moradores no apartamento
    printString(msg_apto_cheio) #printa mensagem de apartamento cheio
    
    j printBanner             # Volta para o banner principal
    
    verificarNovaOcupacao:
    beqz $t4, novo_morador
    j registrar
    
    novo_morador:
    addi $s1, $s1, 1  # Incrementa o contador de apartamentos ocupados
    j registrar
    
    
registrar:
    # Registrar novo morador  
    printString(msg_registrar)
 
    li $v0, 8                 # Carrega operação para ler string
    la $a0, moradores($t2)    # Endereço onde será armazenado
    li $a1, 40                # Limite de bytes
    syscall                   # Lê a string e armazena
     
    printString msg_morador_registrado    

    j printBanner             # Volta para o banner principal

 

# Função strcpy para copiar uma string de $a1 para $a0
strcpy: 
    addi $sp, $sp, -4           # Libera espaço na pilha para armazenar $s0
    sw $s0, 0($sp)              # Guarda o valor anterior de $s0
    move $s0, $zero             # Inicializa $s0 = 0
    
parte1:                         
    add $t1, $s0, $a1           # $t1 = $s0 + $a1 (endereço da string de origem)
    lb $t2, 0($t1)              # Carrega o byte da string de origem
    add $t3, $s0, $a0           # $t3 = $s0 + $a0 (endereço da string de destino)
    sb $t2, 0($t3)              # Copia o byte para a string de destino
    beq $t2, $zero, parte2      # Se o byte é nulo, fim da cópia
    add $s0, $s0, 1             # Incrementa $s0 para o próximo byte
    j parte1                    # Repete o processo

parte2:
    lw $s0, 0($sp)              # Restaura o valor de $s0 da pilha
    add $sp, $sp, 4             # Libera o espaço na pilha
    jr $ra                      # Retorna ao chamador

# Função para comparar duas strings
# Retorna 0 se forem iguais, ou um valor diferente de 0 se forem diferentes
strcmp:
    subi $sp, $sp, 4           #reserva dois espaços na pilha
    sw $ra, 0($sp)             #salva o endereço de retorno

comparaLoop:
    lb $t0, 0($a0)             #carrega um byte da posição n de a0 em t0
    lb $t1, 0($a1)             #carrega um byte da posição n de a1 em t1
    beq $t0, $t1, procuraFinal #se forem iguais, entra em procurarFinal
    li $v0, 1                  #strings são diferentes, carrega 1 em v0
    j final #pula pra final

procuraFinal:
    beqz $t0, stringsIguais    #se $t0 é nulo, as strings são iguais e entra em stringsIguais
    addi $a0, $a0, 1           #incrementa as posições
    addi $a1, $a1, 1
    j comparaLoop #volta para comparaLoop

stringsIguais:
    move $v0, $zero            #strings são iguais, carrega $zero em v0

final:
    lw $ra, 0($sp)             #recupera o endereço de retorno
    addi $sp, $sp, 4           #libera um espaço na pilha
    jr $ra                     #retorna para o chamador

    
printComandoInvalido: #comando não identificado
printString comandoInvalido #printa mensagem quando não há um comando identificado
j printBanner #volta para printBanner
    
inputInvalido: #número do andar ou apartamento inválido
printString apInvalido #printa mensagem quando não há um apto ou andar identificado
j printBanner #volta pra printBanner

tipoVeiculoInvalido:
printString tipoInvalido
j printBanner
