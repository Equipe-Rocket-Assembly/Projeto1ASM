.data
    msg_andar:          .asciiz "\nDigite o andar (1-12): "
    msg_apto:           .asciiz "Digite o número do apartamento (1-2): "
    msg_apto_cheio:     .asciiz "Apartamento cheio! Não é possível adicionar mais moradores.\n"
    msg_registrar:      .asciiz "Digite o nome do novo morador: "
    msg_vazios:         .asciiz "Numero de apartamentos vazios: "
    msg_ocupados:         .asciiz "Numero de apartamentos ocupados: "
    quebraDeLinha:      .asciiz "\n"
    moradores_por_apartamento: .space 240  #24 apartamentos * 240 bytes = 5760
    
.text
.globl main

# Macro para realizar syscall de impressão
.macro printString %endereco_str
    li $v0, 4
    la $a0, %endereco_str  # Carrega o endereço da string em $a0
    syscall
.end_macro

# Macro para leitura de um inteiro
.macro lerInt %dest
    li $v0, 5
    syscall
    move %dest, $v0
.end_macro

main:
    # Inicializa contadores
    li $s0, 24  # Total de apartamentos (24)
    li $s1, 0   # Contador de apartamentos ocupados
    
adicionar_moradores:
    printString(msg_andar)  # Pede o andar do novo morador
    lerInt($t0)             # Lê o andar e armazena em $t0
    subi $t0, $t0, 1        # Subtrai 1 para ajustar índice (0-11)
    
    printString(msg_apto)   # Pede o apartamento do novo morador
    lerInt($t1)             # Lê o número do apartamento e armazena em $t1
    subi $t1, $t1, 1        # Subtrai 1 para ajustar índice (0-1)
    
    # Calcula o índice no array de moradores
    sll $t2, $t0, 1         # Multiplica o andar por 2
    add $t2, $t2, $t1       # Soma o número do apartamento (0-23)
    li $t3, 240             # Espaço por apartamento (240 bytes)
    mul $t2, $t2, $t3       # Calcula o endereço no array
    
    # Inicializa variáveis para verificar moradores
    li $t4, 0               # Contador de moradores no apartamento
    li $t5, 40              # Tamanho de um morador (40 bytes)
    
verificar_moradores:
    lb $t6, moradores_por_apartamento($t2)  # Carrega o byte do endereço atual
    beqz $t6, registrar          # Se $t6 for 0, o espaço está vazio, pula para registrar
    addi $t4, $t4, 1             # Incrementa o contador de moradores
    add $t2, $t2, $t5            # Avança para o próximo espaço de morador
    bne $t4, 6, verificar_moradores  # Verifica até 6 moradores

    # Apartamento cheio
    printString(msg_apto_cheio)  # Informa que o apartamento está cheio
    j adicionar_moradores        # Retorna ao início para nova tentativa

registrar:
    # Se o apartamento estava vazio, incrementa o contador de apartamentos ocupados
    beqz $t4, novo_morador
    
    j finalizar_registro

novo_morador:
    addi $s1, $s1, 1  # Incrementa o contador de apartamentos ocupados
    j finalizar_registro

finalizar_registro:
    # Registrar novo morador
    printString(msg_registrar)
    li $v0, 8
    la $a0, moradores_por_apartamento($t2)
    li $a1, 40
    syscall
    
    # Calcula e imprime o número de apartamentos vazios
    sub $t7, $s0, $s1         # $t7 = Total de apartamentos - ocupados
    printString(msg_vazios)   # Imprime mensagem de apts vazios
    move $a0, $t7
    li $v0, 1
    syscall  
    
    j adicionar_moradores  # Volta para adicionar mais moradores

fim:
    # Finaliza o programa
    li $v0, 10
    syscall
