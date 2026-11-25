# Arquitetura de Computadores - RV32I
# Busca binaria em vetor ordenado
# Entrada: vetor ordenado, quantidade de elementos e alvo.
# Saida: indice (a partir de zero) e quantidade de elementos consultados.

.data
vetor:       .word 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32
quantidade:  .word 16
alvo:        .word 16
indice:      .word -1
comparacoes: .word 0
msg_indice:  .string "Indice: "
msg_comp:    .string "\nComparacoes: "
quebra:      .string "\n"

.text
main:
    andi sp, sp, -16       # Mantem a pilha alinhada a 16 bytes
    jal ra, executar_busca

    la a0, msg_indice
    addi a7, zero, 4
    ecall
    la t0, indice
    lw a0, 0(t0)
    addi a7, zero, 1
    ecall

    la a0, msg_comp
    addi a7, zero, 4
    ecall
    la t0, comparacoes
    lw a0, 0(t0)
    addi a7, zero, 1
    ecall

    la a0, quebra
    addi a7, zero, 4
    ecall
    addi a7, zero, 10
    ecall

# Prepara os argumentos e guarda os dois resultados na memoria.
# Salva ra porque chama outra rotina; s0 guarda o endereco de indice.
executar_busca:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    la s0, indice

    la a0, vetor
    la t0, quantidade
    lw a1, 0(t0)
    la t0, alvo
    lw a2, 0(t0)
    jal ra, buscar

    sw a0, 0(s0)
    la t0, comparacoes
    sw a1, 0(t0)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jalr zero, 0(ra)

# buscar(a0 = endereco do vetor, a1 = tamanho, a2 = alvo)
# Retorna a0 = indice ou -1; a1 = numero de elementos consultados.
# Rotina folha: usa apenas temporarios e argumentos, sem alterar sp ou s0.
buscar:
    addi t0, zero, 0      # inicio
    addi t1, a1, -1       # fim
    addi t2, zero, 0      # contador

bin_loop:
    blt t1, t0, nao_encontrado
    sub t3, t1, t0
    srli t3, t3, 1        # (fim - inicio) / 2
    add t3, t0, t3        # meio = inicio + (fim - inicio) / 2
    slli t4, t3, 2        # indice * 4 bytes
    add t4, a0, t4
    lw t5, 0(t4)
    addi t2, t2, 1
    beq t5, a2, encontrado
    blt t5, a2, metade_direita
    addi t1, t3, -1       # Descarta a metade direita
    jal zero, bin_loop

metade_direita:
    addi t0, t3, 1        # Descarta a metade esquerda
    jal zero, bin_loop

encontrado:
    addi a0, t3, 0
    addi a1, t2, 0
    jalr zero, 0(ra)

nao_encontrado:
    addi a0, zero, -1
    addi a1, t2, 0
    jalr zero, 0(ra)
