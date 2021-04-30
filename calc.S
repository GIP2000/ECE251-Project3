.data

.balign 4
return: .word 0

.balign 4
printPattern: .asciz "%s\n"

.balign 4
printPatternC: .asciz "%c\n"

.balign 4
printTestString: .asciz "I ran \n"

.balign 4
scanPattern: .asciz "%lf"
.balign 4
printFloatPattern: .asciz "value = %lf\n"

.balign 4 
numberString: .skip 250

.balign 4 
postfixStr: .skip 250 

.balign 4 
initalStr: .word 250

.balign 4
floatNumber: .space 20

.balign 4
floatZero: .float 0.0

.balign 4
floatOne: .float 1.0



.text 
.global main
main:
    ldr r0,=return
    str lr,[r0]
    ldr r1,[r1, #4] @grabs the command line arg
    ldr r2,=initalStr
    str r1,[r2]
    mov r2,#0 @ counter through string
    ldr r10,=postfixStr @ new string
    mov r5,#0 @ what type of operation it is 
    mov r6,#0 @ length of stack 
    ldr r9,=initalStr
    ldr r9,[r9]
    mov r3,#95 @stores an underscore
    mov r1,#0 @ flag 0 if last thing was an number; 1 if last thing was operator 
    b postfix_conversion

convert_to_rank:
    cmp r5, #40 @is open parenthesis 
    moveq r5,#2
    cmp r5, #41 @is close parenthesis
    moveq r5,#1
    cmp r5, #42 @is mult
    moveq r5,#4
    cmp r5, #43 @is add
    moveq r5,#5
    cmp r5, #45 @is minus
    moveq r5,#5
    cmp r5, #47 @is division
    moveq r5,#4
    cmp r5, #94 @is exp
    moveq r5,#3
    cmp r5, #8
    moveq r5,#0

    bx lr

convert_8_to_rank:
    cmp r8, #40 @is open parenthesis 
    moveq r0,#2
    cmp r8, #41 @is close parenthesis
    moveq r0,#1
    cmp r8, #42 @is mult
    moveq r0,#4
    cmp r8, #43 @is add
    moveq r0,#5
    cmp r8, #45 @is minus
    moveq r0,#5
    cmp r8, #47 @is division
    moveq r0,#4
    cmp r8, #94 @is exp
    moveq r0,#3
    cmp r8, #8
    moveq r0,#0

    bx lr


pop_and_insert:
    cmp r5,#0
    moveq r5,#8
    streq r5, [sp, #-4]!
    beq postfix_conversion

    str r5,[r10,r2]
    add r2,#1
    sub r6,#1
    b cont_pop

cont_pop:
    cmp r6,#0
    moveq r5,r8
    beq swap_open_par_2
    ldr r5, [sp], #4
    cmp r8,r5
    bge pop_and_insert
    str r5, [sp, #-4]!
    mov r5,r8
    str r5, [sp, #-4]!
    b postfix_conversion

cont_pop_par:
    ldr r5, [sp], #4
    mov r4, r5
    sub r6,#1
    bl convert_to_rank
    cmp r5,#8
    beq postfix_conversion
    str r4,[r10,r2]
    add r2,#1
    b cont_pop_par

swap_open_par_2:
    cmp r5,#1
    moveq r5,#8
    str r5, [sp, #-4]!
    add r6,#1
    b postfix_conversion 

swap_open_par_3:
    cmp r5,#1
    moveq r5,#8
    str r4, [sp, #-4]! @ pusheq{r5}
    add r6,#1
    b postfix_conversion

swap_open_par:
    cmp r5,#1
    moveq r5,#8
    bx lr 

stack_manager:
    cmp r1, #0
    streq r3,[r10,r2]
    addeq r2,#1
    mov r1,#1
    
    mov r5, r4
    bl convert_to_rank
    
    cmp r5,#2
    beq cont_pop_par    
    cmp r6,#0
    beq swap_open_par_3
    
    mov r8, r4
    ldr r4, [sp], #4 @ pop {r5}
    mov r5, r4
    bl convert_to_rank
    bl convert_8_to_rank
    cmp r0,r5
    str r4, [sp, #-4]! @ push{r5}
    bge cont_pop
    mov r5,r8
    bl swap_open_par
    str r5, [sp, #-4]! @ push{r5}
    add r6,#1
    
postfix_conversion:
    ldrb r4,[r9],#1
    cmp r4, #0x00
    beq end_conversion
    cmp r4, #40 @is open parenthesis 
    beq stack_manager
    cmp r4, #41 @is close parenthesis
    beq stack_manager
    cmp r4, #42 @is mult
    beq stack_manager
    cmp r4, #43 @is add
    beq stack_manager
    cmp r4, #45 @is minus
    beq stack_manager
    cmp r4, #47 @is division
    beq stack_manager
    cmp r4, #94 @is exp
    beq stack_manager
    str r4,[r10,r2]
    add r2,#1
    mov r1,#0
    b postfix_conversion
    
end_conversion:
    cmp r1,#0
    streq r3,[r10,r2]
    addeq r2,#1
end_converstion_loop:
    cmp r6,#0
    beq calculate
    ldr r5, [sp], #4

    str r5,[r10,r2]
    add r2,#1
    sub r6,#1
    b end_converstion_loop

calculate: 
    ldr r1,=postfixStr
    ldr r0,=printPattern
    bl printf
    ldr r9,=numberString
    mov r2, #0

stack_number: @ stack until operator is found
    ldrb r4,[r10],#1
    cmp r4, #0x00 @ branch if not at end of string
    beq exit
stack_number_inner:
    cmp r4, #95    
    beq convert_to_float
    str r4,[r9, r2]
    add r2, #1
    b stack_number
    @ convert to float
    @ streq r10, [sp, #-4]! @ push if a "_"


convert_to_float:

    ldr r0,=numberString
    ldr r1,=scanPattern
    ldr r2,=floatNumber
    bl sscanf 

    ldr r1,=floatNumber
    vldr d0,[r1]
    vpush {d0}
    mov r2,#0

check_if_next_is_op:
    
    ldrb r4,[r10],#1
    cmp r4, #0x00
    beq exit
    @ b apply_operator@ if not operator go back to stack_number
    

apply_operator:
    cmp r4,#93
    beq stack_number
    cmp r4, #42 @is mult
    beq multiply
    cmp r4, #43 @is add
    beq addition
    cmp r4, #45 @is minus
    beq subtraction
    cmp r4, #47 @is division
    beq division
    cmp r4, #94 @is exp
    beq exponent
    b stack_number_inner 

get_top_two:
    vpop {d0,d1}
    bx lr

multiply:
    bl get_top_two
    vmul.f64 d0, d0,d1
    vpush {d0}
    b check_if_next_is_op
addition:
    bl get_top_two
    vadd.f64 d0,d0,d1
    vpush {d0}
    b check_if_next_is_op
subtraction:
    bl get_top_two
    vsub.f64 d0,d1,d0
    vpush.f64 {d0}
    b check_if_next_is_op
division:
    bl get_top_two
    vdiv.f64 d0,d1,d0
    vpush {d0}
    b check_if_next_is_op

exponent:
    bl get_top_two
    vmov r2, r3, d0
    vmov r0, r1, d1
    bl pow
    vmov d0,r0,r1
    vpush {d0}
    b check_if_next_is_op

exit:
    vpop {d0}
	vmov r2, r3, d0
    ldr r0,=printFloatPattern
    bl printf

    ldr lr,=return
    ldr lr,[lr]
    bx lr

.global printf
.global sscanf
.global pow
