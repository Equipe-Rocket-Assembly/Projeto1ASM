#macro que printa uma string utilizando o endereço dela como variavel
.macro printString %endereco_str
    li $v0, 4
    la $a0, %endereco_str #carrega o end da string em $a0
    syscall
.end_macro

.data
    destination: .asciiz "Hello, " #string base
    source: .asciiz "World!" #string que será concatenada com a de destination
.text
        la $a0, destination  #carrega o endereço de destination em $a0
        la $a1, source       #carrega o endereço de source em $a1

        jal strcat          #entra na função strcat
        printString destination #imprime a string que está no endereço de destination
        
        li $v0, 10 #sai do programa
        syscall

strcat: #concatena as duas strings
    encontraNull: #encontra null
        lb $t0, 0($a0)      #carrega o byte da posição atual de a0 (destination) em t0
        beqz $t0, concatenar #se t0 for vazio, ele entra em concatenar
        addi $a0, $a0, 1    #incrementa 1 e vai para o próximo byte em destination
        j encontraNull      #volta pro loop

   
    concatenar:  #concatena a string, copiando cada caractere
        lb $t1, 0($a1)      #carrega o byte da posição atual de a1 (source) em t1
        sb $t1, 0($a0)      #armazena t1 no endereço atual de destination
        beqz $t1, finalizar #se o caractere for vazio, ele entra em finalizar
        addi $a0, $a0, 1    #incrementa 1 e vai para o próximo byte em destination
        addi $a1, $a1, 1    #incrementa 1 e vai para o próximo byte em source
        j concatenar        #volta pro loop

  
    finalizar: #retorna para o endereço de volta
        jr $ra  
