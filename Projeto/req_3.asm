#Grupo: Gabriel Cisneiros, Lucas Aurélio e Marcela Hadassa (Equipe Rocket)
#Projeto: 1ª VA
#Disciplina: Arquitetura e organização de computadores
#Semestre letivo: 2024.1
#Arquivo: req3
#Descrição: Salva os dados


.data
filePath: .asciiz "/home/gabriel/Projetos/Projeto1ASM/output.txt"
toWrite: .space 64

.text

# abre o arquivo
li $v0, 13
la $a0, filePath
li $a1, 1
li $a2, 664
syscall

move $s0, $v0

# recebe a string e salva em toWrite
li $v0, 8
la $a0, toWrite
li $a1, 100
syscall

# salva no arquivo
li  $v0, 15
move $a0, $s0
la   $a1, toWrite
li   $a2, 96
syscall

# fecha o arquivo
li  $v0, 16
move $a0, $s0
syscall

# abre o arquivo
li $v0, 13
la $a0, filePath
li $a1, 0
syscall

move $s0, $v0

# lê o arquivo
li  $v0, 14
move $a0, $s0
la   $a1, toWrite
li   $a2, 100
syscall

# printar o que estava no arquivo
li $v0, 4
la $a0, toWrite
syscall

# fecha o arquivo
li  $v0, 16
move $a0, $s0
syscall

# finaliza o programa
li $v0, 10
syscall
