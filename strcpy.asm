.data
	mensagem: .asciiz "Digite a string que será utilizada: "
	string: .space 50
	output: .asciiz "String resultante: "
	placeholder: .asciiz "..."
	
.macro lerString (%endereco, %limite)
    li $v0, 8                 # syscall para ler string
    la $a0, %endereco         # para armazenar a string
    li $a1, %limite           # tamanho máximo da string
    syscall
.end_macro

.macro imprimirString (%text) #definindo macro para imprimir um texto arbitrario (%text)
li $v0, 4 #Carrega a operação de ler string em v0
la $a0, %text #Carrega o texto em a
syscall # chamada para o sistema
.end_macro

.text

imprimirString(mensagem)

lerString(string, 50)

move $a1, $a0
la $a0, placeholder
imprimirString(output)
jal strcpy
li $v0, 4
syscall

li $v0, 10
syscall 

# supondo que a string recebida seja um vetor de chars X, teremos que percorrer as posições de X[N] para copíá-las para Y[N]
strcpy: 
	addi $sp, $sp, -4  # Libera espaço na pilha para armazenarmos o n atual
	sw $s0, 0($sp) 	   #  Guarda n anterior
	move $s0, $zero   # Inicializa s0 = 0
	
parte1:			   # parte 1 = 	
	add $t1, $s0, $a1 # t1 = s0 + a1; (n + endereço base da string digitada)
	lb $t2, 0($t1)    # carrega o char(byte) que está na posição n; t2 = x[n]
	add $t3, $s0, $a0 # t3 = s0 + a0; (n + endereço base da string resultante)
	sb $t2, 0($t3)    # Y[N] = X[N]
	beq $t2, $zero, parte2 # verifica se t2 é zero (chegou ao final) 
	add $s0, $s0, 1 # Transforma n em n + 1
	j parte1
	
parte2:
	lw $s0, 0($sp) # Guarda em s0 o que estava na pilha
	add $sp, $sp, 4 #Libera o espaço que estava sendo usado na pilha
	jr $ra		 #volta para 	