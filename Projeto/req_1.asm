.data
moradores:  .space 5760   # 12 andares x 2 apartamentos por andar x 6 moradores x 40 bytes (nome) por morador

msg_apto_cheio:  .asciiz "Apartamento cheio! Nao pode adicionar mais moradores.\n"
msg_morador_registrado: .asciiz "Morador cadastrado com sucesso!"
msg_registrar:   .asciiz "Digite o nome do morador:\n"
msg_andar:       .asciiz "Digite o andar (1-12):\n"
msg_apto:        .asciiz "Digite o numero do apartamento (1 ou 2):\n"

#macro que ler um inteiro e usa o endereço como variavel
.macro lerInt %endereco
    li $v0, 5
    syscall
    move %endereco, $v0
.end_macro

.text

#macro que printa uma string utilizando o endereço dela como variavel
.macro printString %endereco_str
    li $v0, 4
    la $a0, %endereco_str #carrega o end da string em $a0
    syscall
.end_macro

main:
    
    printString (msg_andar) # Pede o andar do novo morador
    lerInt($t0) # lê efetivamente o Andar e armazena em t0
    subi $t0, $t0, 1 #subtrai o inteiro digitado para ficar de 0-11

    printString(msg_apto) # Pede o apartamento do novo morador
    
    lerInt($t1) # lê efetivamente o número do Apartamento e armazena em t1
    subi $t1, $t1, 1 # $t1 = número apartamento digitado - 1 = 0/1
    
    # Calcula posição no array de moradores
    sll $t2, $t0, 1           # t2 = andar x 2 = indice do primeiro apartamento do andar (ex: andar 1 = apt 2 e 3, logo o primeiro apt do andar 1 é 2) 
    add $t2, $t2, $t1         # t2 = índice do apartamento (0-23) = somar o numero do apartamento ao endereço base 
    li $t3, 240               # t3 = tamanho do espaço reservado para cada apartamento (6 moradores x 40 bytes pra cada = 240 bytes por apartamento)
    mul $t2, $t2, $t3         # calcula o endereço no vetor moradores contando 240 bytes para cada, (apt 3 x 240 = 720 = posição inicial do terceiro apt)
    
    # Calcula quantos moradores existem no andar
    li $t4, 0                 # t4 = quantidade de moradores (começa em 0)
    li $t5, 40                # t5 = tamanho de um nome (40 bytes)
    
check_moradores:
    lb $t6, moradores($t2) # carrega em t6 o byte na posição indicada por t2 em moradores
    beqz $t6, registrar    # se t6 for 0, significa que não está ocupado, portanto pula para registrar morador no endereço apontado
    addi $t4, $t4, 1       # caso t6 não seja 0, temos que o endereço de memória está com outro morador. Por isso, incrementa o contador de moradores
    add $t2, $t2, $t5      # t2 = endereço do próximo espaço para morador obtido ao soma o endereço atual do vetor com 40 (espaço de um morador)
    bne $t4, 6, check_moradores # se não estourou o limite de moradores no andar volta para o loop

    # Caso já existam 6 moradores no apartamento
    printString(msg_apto_cheio) #printa mensagem informando que o apt lotou
    
    j main                    # Volta para o início

registrar:
    # Registrar novo morador
    printString(msg_registrar)
 
    li $v0, 8                 # Carrega operação em v0 
    la $a0, moradores($t2)    # Endereço onde será armazenado (a0)
    li $a1, 40                # a1 -> limite de bytes
    syscall                   # Lê uma string
   
   j main # carrega a main novamente para adicionar um novo morador
