.data
veiculos:     .space 1440   # 12 andares x 2 apartamentos por andar x  30 bytes (20 bytes modelo + 10 bytes placa) por veiculo x 2 motos (maior espaço possível)

msg_vagas_ocupadas: .asciiz "\nEsse apartamento ja esgotou todas as vagas disponiveis\n"
msg_registrar:   .asciiz "\nDigite o nome do morador:\n"
msg_andar:       .asciiz "\nDigite o andar (1-12):\n"
msg_apto:        .asciiz "\nDigite o número do apartamento (1 ou 2):\n"
msg_veiculo:     .asciiz "\nVocê deseja registrar um carro ou moto? (1=carro, 2=moto):\n"
msg_modelo:      .asciiz "\nDigite o modelo do veículo:\n"
msg_placa:       .asciiz "\nDigite a placa do veículo:\n"
msg_carro_registrado: .asciiz "\nCarro registrado com sucesso!\n"
msg_moto_registrada:  .asciiz "\nMoto registrada com sucesso!\n"
msg_carro_existente:  .asciiz "\nEste apartament não pode registrar um carro.\n"
msg_motos_existentes: .asciiz "\nEste apartamento já possui duas motos cadastradas. Não pode registrar mais veículos.\n"

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

.text

main:
    # Solicita o andar
    printString(msg_andar)
    
    # Lê o Int Andar e armazena em $t0
    lerInt($t0)
    subi $t0, $v0, 1          # $t0 = andar (0-11)

    # Solicita o número do apartamento
    printString(msg_apto)
    
    # Lê o Int Apartamento e armazena em $t1
    lerInt($t1)
    subi $t1, $t1, 1          # $t1 = apartamento (0 ou 1)
    
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
    j main

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

    j main
    
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
    
   j main
    
carro_existente:
    printString(msg_carro_existente)
    j main                # Volta ao início
