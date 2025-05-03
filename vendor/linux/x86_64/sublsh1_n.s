




















































































	.text
	.align	16, 0x90
	.globl	__gmpn_sublsh1_n
	.type	__gmpn_sublsh1_n,@function
	
__gmpn_sublsh1_n:

	
	push	%rbp
	push	%r15
	xor	%ebp, %ebp
.Lent:	mov	%ecx, %eax
	and	$3, %eax
	jz	.Lb0
	cmp	$2, %eax
	jz	.Lb2
	jg	.Lb3

.Lb1:	mov	(%rdx), %r8
	add	%r8, %r8
	lea	8(%rdx), %rdx
	sbb	%eax, %eax	
	add	%ebp, %ebp	
	mov	(%rsi), %r15
	sbb	%r8, %r15
	mov	%r15, (%rdi)
	sbb	%ebp, %ebp	
	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	jmp	.Lb0

.Lb2:	mov	(%rdx), %r8
	add	%r8, %r8
	mov	8(%rdx), %r9
	adc	%r9, %r9
	lea	16(%rdx), %rdx
	sbb	%eax, %eax	
	add	%ebp, %ebp	
	mov	(%rsi), %r15
	sbb	%r8, %r15
	mov	%r15, (%rdi)
	mov	8(%rsi), %r15
	sbb	%r9, %r15
	mov	%r15, 8(%rdi)
	sbb	%ebp, %ebp	
	lea	16(%rsi), %rsi
	lea	16(%rdi), %rdi
	jmp	.Lb0

.Lb3:	mov	(%rdx), %r8
	add	%r8, %r8
	mov	8(%rdx), %r9
	adc	%r9, %r9
	mov	16(%rdx), %r10
	adc	%r10, %r10
	lea	24(%rdx), %rdx
	sbb	%eax, %eax	
	add	%ebp, %ebp	
	mov	(%rsi), %r15
	sbb	%r8, %r15
	mov	%r15, (%rdi)
	mov	8(%rsi), %r15
	sbb	%r9, %r15
	mov	%r15, 8(%rdi)
	mov	16(%rsi), %r15
	sbb	%r10, %r15
	mov	%r15, 16(%rdi)
	sbb	%ebp, %ebp	
	lea	24(%rsi), %rsi
	lea	24(%rdi), %rdi

.Lb0:	test	$4, %cl
	jz	.Lskp
	add	%eax, %eax	
	mov	(%rdx), %r8
	adc	%r8, %r8
	mov	8(%rdx), %r9
	adc	%r9, %r9
	mov	16(%rdx), %r10
	adc	%r10, %r10
	mov	24(%rdx), %r11
	adc	%r11, %r11
	lea	32(%rdx), %rdx
	sbb	%eax, %eax	
	add	%ebp, %ebp	
	mov	(%rsi), %r15
	sbb	%r8, %r15
	mov	%r15, (%rdi)
	mov	8(%rsi), %r15
	sbb	%r9, %r15
	mov	%r15, 8(%rdi)
	mov	16(%rsi), %r15
	sbb	%r10, %r15
	mov	%r15, 16(%rdi)
	mov	24(%rsi), %r15
	sbb	%r11, %r15
	mov	%r15, 24(%rdi)
	lea	32(%rsi), %rsi
	lea	32(%rdi), %rdi
	sbb	%ebp, %ebp	

.Lskp:	cmp	$8, %rcx
	jl	.Lrtn

	push	%r12
	push	%r13
	push	%r14
	push	%rbx
	lea	-64(%rdi), %rdi
	jmp	.Lx

	.align	16, 0x90
.Ltop:	mov	(%rdx), %r8
	add	%eax, %eax
	lea	64(%rdx), %rdx
	adc	%r8, %r8
	mov	-56(%rdx), %r9
	adc	%r9, %r9
	mov	-48(%rdx), %r10
	adc	%r10, %r10
	mov	-40(%rdx), %r11
	adc	%r11, %r11
	mov	-32(%rdx), %r12
	adc	%r12, %r12
	mov	-24(%rdx), %r13
	adc	%r13, %r13
	mov	-16(%rdx), %r14
	adc	%r14, %r14
	mov	-8(%rdx), %r15
	adc	%r15, %r15
	sbb	%eax, %eax
	add	%ebp, %ebp
	mov	(%rsi), %rbp
	lea	64(%rdi), %rdi
	mov	8(%rsi), %rbx
	sbb	%r8, %rbp
	mov	32(%rsi), %r8
	mov	%rbp, (%rdi)
	sbb	%r9, %rbx
	mov	16(%rsi), %rbp
	mov	%rbx, 8(%rdi)
	sbb	%r10, %rbp
	mov	24(%rsi), %rbx
	mov	%rbp, 16(%rdi)
	sbb	%r11, %rbx
	mov	%rbx, 24(%rdi)
	sbb	%r12, %r8
	mov	40(%rsi), %r9
	mov	%r8, 32(%rdi)
	sbb	%r13, %r9
	mov	48(%rsi), %rbp
	mov	%r9, 40(%rdi)
	sbb	%r14, %rbp
	mov	56(%rsi), %rbx
	mov	%rbp, 48(%rdi)
	sbb	%r15, %rbx
	lea	64(%rsi), %rsi
	mov	%rbx, 56(%rdi)
	sbb	%ebp, %ebp
.Lx:	sub	$8, %rcx
	jge	.Ltop

.Lend:	pop	%rbx
	pop	%r14
	pop	%r13
	pop	%r12
.Lrtn:
	add	%ebp, %eax
	neg	%eax

	pop	%r15
	pop	%rbp
	
	ret
	.size	__gmpn_sublsh1_n,.-__gmpn_sublsh1_n
	.globl	__gmpn_sublsh1_nc
	.type	__gmpn_sublsh1_nc,@function
	
__gmpn_sublsh1_nc:

	

	push	%rbp
	push	%r15
	neg	%r8			
	sbb	%ebp, %ebp	
	jmp	.Lent
	.size	__gmpn_sublsh1_nc,.-__gmpn_sublsh1_nc

