.data
    ##constantes
    num0: .word 4	#posición 0.
    num1: .word 80	#posición 4.
    num2: .word 100	#posición 8.
    num3: .word 15	#posición 12.
    num4: .word 200	#posición 16.
    num5: .word 240	#posición 20.
    
    ##Registros intermedios vacios
    num6:  .word 0	#posición 24.
    num7:  .word 0	#posición 28.
    num8:  .word 0	#posición 32.
    num9:  .word 0	#posición 36.
    num10: .word 0	#posición 40.
    num11: .word 0	#posición 44.
    num12: .word 0	#posición 48.
    num13: .word 0	#posición 52.
    num14: .word 0	#posición 56.
    num15: .word 0	#posición 60.
    
    ##A[0],...,A[19] desde 0x00000020 a 0x0000040
    num16: .word 50
    num17: .word 10
    num18: .word 37
    num19: .word 98
    num20: .word 150
    num21: .word 0
    num22: .word 59
    num23: .word 151
    num24: .word 163
    num25: .word 22
    num26: .word 77
    num27: .word 66
    num28: .word 244
    num29: .word 233
    num30: .word 34
    num31: .word 21
    num32: .word 67
    num33: .word 234
    num34: .word 123
    num35: .word 56
   
    # Declaraciones:
    # $t0 es i
    # $t1 es un auxiliar
    # $t2 es A[i]
.text   

main:
    addi $t0, $zero, 0 		#$t0 = 0
    lw $t1, 4($zero)			#$t1 = 80
    for:
    	nop
    	nop
    	nop
        sub $t1, $t1, $t0		#$t1 = 80 - i
        nop
        nop
        beq $t1, $zero, exit		#si $t1 = 0 -> exit
        lw  $t2, 64($t0)		#$t2 = mem[40 + i] = A[i]
        
  	lui $t1, 100		#$t1 = mem[8] = 100
  	nop
  	nop
  	nop
  	slt $t1, $t1, $t2		#$t1 = $t2 < $t1
  	nop
  	nop
  	beq $t1, $zero, primerIf	#si $t1 = 0 -> primerIf
  	
  	##primer else.
  	lw $t1, 16($zero)		#$t1 = mem[16] = 200
  	nop
  	nop
  	nop
  	slt $t1, $t2, $t1 		#si ($t2 < $t1) entonces $t1 = 1 sino $t2 = 0
  	nop
  	nop
  	beq $t1, $zero, segundoElse
  	
  	##segundo if
  	##Res[i] = A[i]
  	sw $t2, 256($t0)		#mem[100 + i] = $t2 = A[i]
 	beq $zero, $zero, finalFor	#salto incondicional a la parte final del for.
    
    primerIf:
        ##Res[i] = A[i] & 0x0000000F; 
        andi $t1, $t2, 15		#$t1 = $t1 & $t2
        nop
        nop
  	sw $t1, 256($t0)		#mem[100 + i] = $t1
  	beq $zero, $zero, finalFor
  	    
    segundoElse:
        ##Res[i] = A[i] & 0x000000F0;
        andi $t1, $t2, 240		#$t1 = $t1 & $t2 = 240 & A[i]
        nop
        nop
        sw $t1, 256($t0)		#mem[100 + i] = $t1
        beq $zero, $zero, finalFor	#salto incondicional a la parte final del for.
        
    finalFor:  
        nop
        nop
  	addi $t0, $t0, 4 		#$t0 = $t0 + 4
  	lw $t1, 4($zero)		#$t1 = 80
  	beq $zero, $zero, for		#salto incondicional al for.
    exit:
