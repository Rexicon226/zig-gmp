


















































































  
  
  
  







	.text
	.align	16, 0x90
	.globl	__gmpn_rsblsh1_n
	.type	__gmpn_rsblsh1_n,@function
	
__gmpn_rsblsh1_n:

	
	push	%rbp
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
	sbb	(%rsi), %r8
	mov	%r8, (%rdi)
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
	sbb	(%rsi), %r8
	mov	%r8, (%rdi)
	sbb	8(%rsi), %r9
	mov	%r9, 8(%rdi)
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
	sbb	(%rsi), %r8
	mov	%r8, (%rdi)
	sbb	8(%rsi), %r9
	mov	%r9, 8(%rdi)
	sbb	16(%rsi), %r10
	mov	%r10, 16(%rdi)
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
	sbb	(%rsi), %r8
	mov	%r8, (%rdi)
	sbb	8(%rsi), %r9
	mov	%r9, 8(%rdi)
	sbb	16(%rsi), %r10
	mov	%r10, 16(%rdi)
	sbb	24(%rsi), %r11
	mov	%r11, 24(%rdi)
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
.Ltop:	add	%eax, %eax	
	lea	64(%rdi), %rdi
	mov	(%rdx), %r8
	adc	%r8, %r8
	mov	8(%rdx), %r9
	adc	%r9, %r9
	mov	16(%rdx), %r10
	adc	%r10, %r10
	mov	24(%rdx), %r11
	adc	%r11, %r11
	mov	32(%rdx), %r12
	adc	%r12, %r12
	mov	40(%rdx), %r13
	adc	%r13, %r13
	mov	48(%rdx), %r14
	adc	%r14, %r14
	mov	56(%rdx), %rbx
	adc	%rbx, %rbx
	lea	64(%rdx), %rdx
	sbb	%eax, %eax	
	add	%ebp, %ebp	
	sbb	(%rsi), %r8
	mov	%r8, (%rdi)
	sbb	8(%rsi), %r9
	mov	%r9, 8(%rdi)
	sbb	16(%rsi), %r10
	mov	%r10, 16(%rdi)
	sbb	24(%rsi), %r11
	mov	%r11, 24(%rdi)
	sbb	32(%rsi), %r12
	mov	%r12, 32(%rdi)
	sbb	40(%rsi), %r13
	mov	%r13, 40(%rdi)
	sbb	48(%rsi), %r14
	mov	%r14, 48(%rdi)
	sbb	56(%rsi), %rbx
	mov	%rbx, 56(%rdi)
	sbb	%ebp, %ebp	
	lea	64(%rsi), %rsi
.Lx:	sub	$8, %rcx
	jge	.Ltop

.Lend:	pop	%rbx
	pop	%r14
	pop	%r13
	pop	%r12
.Lrtn:


	sub	%eax, %ebp
	movslq	%ebp, %rax

	pop	%rbp
	
	ret
	.size	__gmpn_rsblsh1_n,.-__gmpn_rsblsh1_n
	.globl	__gmpn_rsblsh1_nc
	.type	__gmpn_rsblsh1_nc,@function
	
__gmpn_rsblsh1_nc:

	

	push	%rbp
	neg	%r8			
	sbb	%ebp, %ebp	
	jmp	.Lent
	.size	__gmpn_rsblsh1_nc,.-__gmpn_rsblsh1_nc

