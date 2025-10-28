.section .text
.globl get_number

get_number:
    addi sp, sp, -24        # Reservar espacio en stack
    sw ra, 20(sp)           # Guardar return address
    sw s0, 16(sp)            # Guardar s0 (acumulador)
    sw s1, 12(sp)            # Guardar s1 (signo)
    sw s2, 8(sp)            # Guardar s2 (primer dígito)
    sw t0, 4(sp)            # Guardar s2 (primer dígito)
    sw t1, 0(sp)            # Guardar s2 (primer dígito)
    
    li s0, 0                # s0 = acumulador (resultado)
    li s1, 0                # s1 = signo (0=positivo, 1=negativo)
    li s2, 1                # s2 = flag primer dígito
    
get_number_loop:
    call getchar         # Leer carácter en a0
    mv t6, a0               # Guardar carácter en t6
    
    # ECHO: Mostrar el carácter leído
    call putchar         # a0 ya contiene el carácter
    
    mv a0, t6               # Restaurar carácter para procesamiento
    
    # Verificar si es newline o enter (terminar)
    li t0, 10               # '\n'
    beq a0, t0, get_number_done
    li t0, 13               # '\r'
    beq a0, t0, get_number_done
    
    # Verificar si es espacio (terminar)
    li t0, 32               # ' '
    beq a0, t0, get_number_done
    # Verificar si es dígito ('0'-'9')
    li t0, 48               # '0'
    blt a0, t0, get_number_loop  # Si < '0', ignorar
    li t0, 57               # '9'
    bgt a0, t0, get_number_loop  # Si > '9', ignorar
    
    # Convertir ASCII a número
    andi  a0, a0, 15

    # correr 4 posiciones: s0 = s0 << 4
    mv t1, s0               # t1 = s0
    slli s0, s0, 4
    
    # Sumar nuevo dígito
    or s0, s0, a0
    j get_number_loop       # Continuar leyendo
    
get_number_done:
    mv a0, s0               # Retornar resultado en a0
    
    # Restaurar registros
    lw t1, 0(sp)
    lw t0, 4(sp)
    lw s2, 8(sp)
    lw s1, 12(sp)
    lw s0, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24
    
    ret