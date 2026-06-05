.global _start

_start:
    # Configurar stack
    la sp, _fstack
    
    # Configurar trap vector
    la t0, trap_vector
    csrw mtvec, t0
    
    # SALTARSE inicialización de .data completamente
    # Solo inicializar .bss
    la t0, _fbss
    la t1, _ebss
1:  beq t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    # Habilitar interrupciones
    li t0, 0x800
    csrs mie, t0
    
    # Llamar main
    call main
    
    # Loop infinito
1:  j 1b

# Trap handler simple
trap_vector:
    # Guardar contexto mínimo
    addi sp, sp, -16
    sw ra, 0(sp)
    sw t0, 4(sp)
    
    # Llamar ISR
    call isr
    
    # Restaurar contexto
    lw ra, 0(sp)
    lw t0, 4(sp)
    addi sp, sp, 16
    mret