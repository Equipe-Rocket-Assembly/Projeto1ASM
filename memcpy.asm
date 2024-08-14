#macro que ler um inteiro e usa o endereço como variavel
.macro lerInt %endereco
    li $v0, 5
    syscall
    move %endereco, $v0
.end_macro


.data
mensagem1: .asciiz "Olá, usuário" #source
destino: .space 50 #destination
.text

la $a0, destino #carrega o endereço de destino
la $a1, mensagem1 #carrega o endereço de mensagem1

lerInt $a2 #ler o numero de bytes a ser copiados

jal memcpy #entra na função de verificação e guarda o endereço de retorno em ra

la   $a0, destino     #imprime o resultado atualizado
li   $v0, 4        
syscall
    
li $v0, 10 #sai do programa
syscall


memcpy: #copia n bytes do source em destination
    sub $sp, $sp, 8      #libera espaço na pilha
    sw   $ra, 4($sp)     #armazena o endereço de retorno e o valor de s0
    sw   $s0, 0($sp)     #armazena o valor salvo de s0

    move $s0, $a0          #$s0 = destino
    move $t0, $a1          #$t0 = mensagem1
    move $t1, $a2          #$t1 = num

   
    ble  $t1, $zero, sair #verifica se num < 0, se for, ele entra em sair
    
copia: #copia o que estiver em t2 para o que está no endereço de s0
    lb   $t2, 0($t0)       #carrega o byte atual (n) em t2
    sb   $t2, 0($s0)       #armazena o byte t2 na posição 0 de s0
    addi $t0, $t0, 1       #incrementa n
    addi $s0, $s0, 1       #incrementa n
    addi $t1, $t1, -1      #decrementa num para verificar se já é zero
    bne  $t1, $zero, copia #se não for o zero, o loop continua

sair:
    move $v0, $a0          #retorna o endereço de destino em $v0

    lw   $ra, 4($sp)       #restaura o endereço de retorno
    lw   $s0, 0($sp)       #restaura $s0
    addi $sp, $sp, 8       #restaura o ponteiro da pilha
    jr   $ra               #retorna para o endereço de retorno com o valor atualizado
