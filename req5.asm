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

.data
banner:     .asciiz "GLM-shell>> "
comandoSair:   .asciiz "exit"
comandoPrintar:  .asciiz "print"
newline:    .asciiz "\n"
comandoInvalido: .asciiz "Comando inválido.\n"
input:     .space 100         #espaço reservado para o input do usuário
mensagemPrintar:  .space 100  #espaço reservado para o print da mensagem

.text
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
    bnez $v0, comparaComandoPrint      #se não for "exit", verifica se é print
    
    #se for "exit", encerra o programa
    li $v0, 10                  #syscall para sair do programa
    syscall                    
    
comparaComandoPrint:
    # Comparar com o comando "print"
    la $a0, input              #carrega o endereço do input em a0
    la $a1, comandoPrintar     #carrega o endereço do comando "print" em a1
    jal strcmp                 #chama a função strcmp 
    bnez $v0, printComandoInvalido   #se não for "print", entra em printComandoInvalido

    
    #se for "print", recebe a string do usuário
    
    #lê a string que o usuário deseja imprimir
    lerString mensagemPrintar, 100

    #imprime a string armazenada em mensagemPrintar
    printString mensagemPrintar
   
    #volta ao loop principal
    j printBanner
    
 

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
    
