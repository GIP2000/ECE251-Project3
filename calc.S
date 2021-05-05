.data

.balign 4
return: .word 0

.balign 4
printPattern: .asciz "%s\n"

.balign 4
printPatternC: .asciz "%c\n"

.balign 4
scanPattern: .asciz "%lf"

.balign 4
printFloatPattern: .asciz "value = %lf\n"

.balign 4
invalidInputStr: .asciz "Invalid Input\n"

.balign 4 
numberString: .skip 250

.balign 4 
postfixStr: .skip 250 

.balign 4 
initalStr: .word 250

.balign 4
processNegativeString: .skip 250

.balign 4
processNegativeStringAddr: .skip 250

.balign 4
floatNumber: .space 20

.text 
.global main
main:
    ldr r3,=return
    str lr,[r3]
    cmp r0, #1
    ble throw_consecutive_operation_error
    ldr r1,[r1, #4] @grabs the command line arg
    ldr r2,=initalStr
    str r1,[r2]
    mov r2,#0 @ counter through string
    ldr r10,=processNegativeString 
    ldr r9, =initalStr
    ldr r9,[r9]
    mov r1,#0 @ flag 0 if last thing was an number; 1 if last thing was operator 
    mov r8, #0
    mov r3, #1
    mov r5, #0 @ open/close parenthesis counter
    mov r6, #0 @ operator counter

check_valid_equation:
    ldrb r4,[r9],#1
    
check_valid_eqaution_inner:
    mov r0, #0
    @ add r2, #1

    cmp r4, #0x00
    addeq r2, #1
    beq reset_increment
    
    cmp r4, #43 @is add
    addeq r8,#1
    addeq r6,#1
    moveq r0, #1

    cmp r4, #42 @is mult
    addeq r8,#1
    addeq r6,#1
    moveq r0, #1

    cmp r4, #40 @is open
    addeq r5, #1
    streq r4,[r10,r2]
    addeq r2,#1
    beq check_open_parenthesis
    
    cmp r4, #45 @is minus
    bleq handle_minus
    @ addeq r8,#1
    @ addeq r6,#1
    @ moveq r0,#1
    
    cmp r4, #47 @is division
    addeq r8,#1
    addeq r6,#1
    moveq r0, #1
    
    cmp r4, #94 @is exp
    addeq r8,#1
    addeq r6,#1
    moveq r0, #1

    cmp r4, #41 @is close
    subeq r5, #1
    cmpeq r8, #1
    beq throw_consecutive_operation_error
    
    cmp r3, r8
    addne r3, #2
    beq throw_consecutive_operation_error

    cmp r8, #1
    bgt throw_consecutive_operation_error
    
    cmp r5, #0
    blt throw_consecutive_operation_error

    cmp r6, #4
    bgt throw_consecutive_operation_error

    cmp r0, #1
    movne r8, #0

    str r4,[r10,r2]
    add r2,#1

    b check_valid_equation

throw_consecutive_operation_error:
    ldr r0, =invalidInputStr
    bl printf
    b full_exit

reset_increment:
    cmp r3, #1
    beq throw_consecutive_operation_error

    cmp r5, #0
    bne throw_consecutive_operation_error

    cmp r8, #1
    bge throw_consecutive_operation_error

reset_increment_inner:
    cmp r2, #0
    ldreq r9,=processNegativeString
    ldreq r3,=processNegativeStringAddr
    addeq r9,#4
    streq r9, [r3]
    ldreq r9,=processNegativeString
    ldreq r9,[r9]
    moveq r3, #95 @stores an underscore
    moveq r5,#0 @ what type of operation it is 
    moveq r6,#0 @ length of stack 
    ldreq r10,=postfixStr @ new string
    beq postfix_conversion

    ldrb r4,[r9],#-1
    sub r2, #1
    b reset_increment_inner

check_open_parenthesis:
    ldrb r4,[r9],#1
    cmp r4, #48
    blt check_valid_eqaution_inner

check_open_parenthesis_2:
    cmp r4, #57
    bgt throw_consecutive_operation_error
    b check_valid_eqaution_inner


handle_minus:
    cmp r8,#1
    addlt r8, #1
    addlt r6, #1
    movlt r0, #1
    movge r4, #32
    cmp r3, r8
    subeq r8,#1
    subeq r6, #1
    moveq r0,#0
    moveq r4,#32

    str r4,[r10,r2]
    add r2,#1
    ldrb r4,[r9],#1
    cmp r4,#40
    beq throw_consecutive_operation_error

    b check_valid_eqaution_inner

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

    bx lr

convert_to_rank_stack:
    cmp r5, #40 @is open parenthesis 
    moveq r5,#8
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

    bx lr

convert_8_to_rank_stack:
    cmp r8, #40 @is open parenthesis 
    moveq r0,#8
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

    bx lr

pop_and_insert:
    cmp r5,#8 
    streq r4, [sp, #-4]!
    beq postfix_conversion

    str r4,[r10,r2]
    add r2,#1
    sub r6,#1
    b cont_pop

cont_pop:
    cmp r6,#0
    streq r8, [sp, #-4]!
    addeq r6,#1
    beq postfix_conversion
    ldr r4, [sp], #4
    mov r5, r4
    bl convert_to_rank_stack
    cmp r0,r5
    bge pop_and_insert
    str r4, [sp, #-4]!
    str r8, [sp, #-4]!
    add r6,#1
    b postfix_conversion

cont_pop_par:
    ldr r5, [sp], #4
    mov r4, r5
    sub r6,#1
    bl convert_to_rank_stack
    cmp r5,#8
    beq postfix_conversion
    str r4,[r10,r2]
    add r2,#1
    b cont_pop_par

check_true_end:
    push {r3}
    ldr r9,=processNegativeStringAddr
    ldr r9,[r9]
    add r9,#4
    ldr r3,=processNegativeStringAddr
    str r9,[r3]
    sub r9, #4
    pop {r3}
    ldr r9,[r9]
    cmp r9, #0x00
    beq end_conversion
    and r4,r9,#0xFF
    mov r9, r9, LSR #8
    b mid_postfix_conversion

stack_manager:
    cmp r1, #0
    streq r3,[r10,r2]
    addeq r2,#1
    mov r1,#1
    
    mov r5, r4
    bl convert_to_rank
    
    cmp r5,#1 @2
    beq cont_pop_par    
    cmp r6,#0
    streq r4, [sp, #-4]!
    addeq r6,#1
    beq postfix_conversion
    
    mov r8, r4
    ldr r4, [sp], #4 @ pop {r5}
    mov r5, r4
    bl convert_to_rank_stack
    bl convert_8_to_rank
    cmp r0,r5
    str r4, [sp, #-4]! @ push{r5}
    bge cont_pop
    mov r5,r8
    @ bl swap_open_par
    str r5, [sp, #-4]! @ push{r5}
    add r6,#1
    
postfix_conversion:
    @ ldrb r4,[r9],#1
    and r4,r9,#0xFF
    mov r9, r9, LSR #8
    cmp r4, #0x00
    beq check_true_end
    @ ldreq r9,=processNegativeString
    @ addeq r9,#4
    @ ldreq r9,[r9]
    @ beq end_conversion
mid_postfix_conversion:
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
    ldr r0,=printPattern
    ldr r1,=postfixStr
    bl printf 
    ldr r9,=numberString
    mov r2, #0
    mov r5, #0

stack_number: @ stack until operator is found
    ldrb r4,[r10],#1
    cmp r4, #0x00 @ branch if not at end of string
    beq exit

stack_number_inner:
    cmp r4, #95    
    beq convert_to_float
    cmp r4, #32
    moveq r4,#45
    addeq r5, #1
    cmp r5, #2
    beq throw_consecutive_operation_error
    str r4,[r9, r2]
    add r2, #1
    b stack_number

convert_to_float:
    mov r5, #0
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

full_exit:
    ldr lr,=return
    ldr lr,[lr]
    bx lr

.global printf
.global sscanf
.global pow
