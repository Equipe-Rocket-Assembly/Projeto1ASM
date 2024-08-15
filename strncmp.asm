#macro que printa um inteiro usando o valor como variave
.macro printInt %valor
    move $a0, %valor
    li $v0, 1
    syscall
.end_macro

#macro que ler um inteiro e usa o endereço como variavel
.macro lerInt %endereco
    li $v0, 5
    syscall
    move %endereco, $v0
.end_macro


.data
    str1: .asciiz "exe"       #primeira string que usamos na comparação
    str2: .asciiz "exemplo"   #segunda string que usamos na comparação

.text
    la $a0, str1 #carrega em a0 o endereço da primeira string
    la $a1, str2 #carrega em a1 o endereço da segunda string
    lerInt $a3 #carrega em a3 o valod de n (quantos chars serão comparados)
    jal strncmp #ele entra em strcmp e salva em ra o endereço de retorno

    #imprime o valor de retorno de strcmp resultado da comparação que estava em v0
    printInt $v0

    li $v0, 10 #sai do programa
    syscall

strncmp:
	
    comparacao: #carrega x[n] e y[n], fazendo a comparação entre elas
        lb $t0, 0($a0)      #t0 carrega o valor do que está na posição n do str1 (inicialmente a primeira posição)
        lb $t1, 0($a1)      #t1 carrega o valor do que está na posição n do str2 (inicialmente a primeira posição)

        bne $t0, $t1, subtracao  #se t0 e t1 forem diferentes ele entra em subtracao para obter o valor de saída
        beqz $t0, sair     #se t0 for 0 significa que ela acabou e ele entra em sair

        addi $a0, $a0, 1     #incrementa de n para str1 igual a n+1
        addi $a1, $a1, 1     #incrementa de n para str2 igual a n+1
        sub $a3, $a3, 1      #decrementa n para ver se já chegou em 0
        bnez $a3, comparacao #repete a comparação enquanto a3 não for 0

    subtracao:
        sub $v0, $t0, $t1    #v0 recebe a diferença entre os valores ascii de t0 e t1
        j sair               #entra em sair

sair:
    jr $ra                   #ele retorna para depois da chamada com o resultado em v0
