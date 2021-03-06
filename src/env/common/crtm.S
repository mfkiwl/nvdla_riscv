# See LICENSE for license details.

#.include "macros.S"
.include "constants.S"

#
# start of trap handler
#

.section .text.init,"ax",@progbits
.globl _start

_start:
    # setup default trap vector
    la      t0, trap_vector
    csrw    mtvec, t0

	# init bss data, as simulation environment requires
	la		a4, _bss_start
	la		a5, _bss_end
	li		a6, 0
bss_init:
	sw		a6, 0(a4)
	addi    a4, a4, 4
	bleu	a4, a5, bss_init

    # set up stack pointer based on hartid
    csrr    t0, mhartid
    slli    t0, t0, STACK_SHIFT
    la      sp, stacks + STACK_SIZE
    add     sp, sp, t0

    # park all harts excpet hart 0
    csrr    a0, mhartid
    bnez    a0, park

    # jump to libfemto_start_main
    j       main #libfemto_start_main

    # sleeping harts mtvec calls trap_fn upon receiving IPI
park:
    wfi
    j       park

    .align 4
trap_vector:
    # Save registers.
    addi    sp, sp, -CONTEXT_SIZE
    sxsp    ra, 0
    sxsp    a0, 1
    sxsp    a1, 2
    sxsp    a2, 3
    sxsp    a3, 4
    sxsp    a4, 5
    sxsp    a5, 6
    sxsp    a6, 7
    sxsp    a7, 8
    sxsp    t0, 9
    sxsp    t1, 10
    sxsp    t2, 11
    sxsp    t3, 12
    sxsp    t4, 13
    sxsp    t5, 14
    sxsp    t6, 15

    # Invoke the handler.
    # mv      a0, sp
    csrr    a0, mcause
    csrr    a1, mip
    jal     trap_handler

    # Restore registers.
    lxsp    ra, 0
    lxsp    a0, 1
    lxsp    a1, 2
    lxsp    a2, 3
    lxsp    a3, 4
    lxsp    a4, 5
    lxsp    a5, 6
    lxsp    a6, 7
    lxsp    a7, 8
    lxsp    t0, 9
    lxsp    t1, 10
    lxsp    t2, 11
    lxsp    t3, 12
    lxsp    t4, 13
    lxsp    t5, 14
    lxsp    t6, 15
    addi sp, sp, CONTEXT_SIZE

    # Return
    mret

    .bss
    .align 4
    .global stacks
stacks:
    .skip STACK_SIZE * MAX_HARTS
