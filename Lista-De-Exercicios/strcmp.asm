#macro que printa um inteiro usando o valor como variave
.macro printInt %valor
    move $a0, %valor
    li $v0, 1
    syscall
.end_macro


.data
    str1: .asciiz "a"
    str2: .asciiz "ab"

.text
    la $a0, str1 #carrega em a0 o endereço da primeira string
    la $a1, str2 #carrega em a0 o endereço da segunda string
    jal strcmp #ele entra em strcmp e salva em ra o endereço de retorno
    
    #imprimi o valor de retorno de strcmp resultado da comparação que estava em v0
    printInt $v0
    
    li $v0, 10 #sai do programa
    syscall
    
strcmp:
    comparacao: #carrega x[n] e y[n], fazendo a comparação entre elas
        lb $t0, 0($a0)      #t0 carrega o valor do que está na posição n do str1
        lb $t1, 0($a1)      #t1 carrega o valor do que está na posição n do str2

        bne $t0, $t1, subtracao  #se t0 e t1 forem diferentes ele entra em subtracao
        beqz $t0, sair     #se t0 for 0 significa que ela acabou e ele entra em sair

        addi $a0, $a0, 1     #incrementa n para str1 igual a n+1
        addi $a1, $a1, 1     #incrementa n para str2 igual a n+1
        j comparacao         #repete o loop, voltando para comparar novamente

    subtracao:
        sub $v0, $t0, $t1    #v0 recebe a diferença entre os valores ascii de t0 e t1
        j sair               #entra em sair

sair:
    jr $ra                   #ele retorna para depois da chamada com o resultado em v0
