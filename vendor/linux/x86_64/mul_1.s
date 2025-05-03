











































































   
   
   
   
    








	.text
	.align	32, 0x90
	.globl	__gmpn_mul_1c
	.type	__gmpn_mul_1c,@function
	
__gmpn_mul_1c:

	

	mov	%r8, %r11	
	jmp	.Lcom
	.size	__gmpn_mul_1c,.-__gmpn_mul_1c

	.globl	__gmpn_mul_1
	.type	__gmpn_mul_1,@function
	
__gmpn_mul_1:

	
	xor	%r11d, %r11d
.Lcom:
	mov	%rcx, %r10
	mov	%rdx, %rcx
	mov	%edx, %eax
	shr	$3, %rcx
	and	$7, %eax		
	mov	%r10, %rdx
	lea	.Ltab(%rip), %r10

	jmp	*(%r10,%rax,8)

	.section	.data.rel.ro.local,"a",@progbits
	.align	8, 0x90
.Ltab:	.quad	.Lf0
	.quad	.Lf1
	.quad	.Lf2
	.quad	.Lf3
	.quad	.Lf4
	.quad	.Lf5
	.quad	.Lf6
	.quad	.Lf7
	.text

.Lf0:	.byte	0xc4,98,171,0xf6,6
	lea	-8(%rsi), %rsi
	lea	-8(%rdi), %rdi
	lea	-1(%rcx), %rcx
	adc	%r11, %r10
	jmp	.Lb0

.Lf3:	.byte	0xc4,226,179,0xf6,6
	lea	16(%rsi), %rsi
	lea	-48(%rdi), %rdi
	adc	%r11, %r9
	jmp	.Lb3

.Lf4:	.byte	0xc4,98,171,0xf6,6
	lea	24(%rsi), %rsi
	lea	-40(%rdi), %rdi
	adc	%r11, %r10
	jmp	.Lb4

.Lf5:	.byte	0xc4,226,179,0xf6,6
	lea	32(%rsi), %rsi
	lea	-32(%rdi), %rdi
	adc	%r11, %r9
	jmp	.Lb5

.Lf6:	.byte	0xc4,98,171,0xf6,6
	lea	40(%rsi), %rsi
	lea	-24(%rdi), %rdi
	adc	%r11, %r10
	jmp	.Lb6

.Lf1:	.byte	0xc4,226,179,0xf6,6
	adc	%r11, %r9	
	jrcxz	.Lend
	jmp	.Lb1

.Lend:	mov	%r9, (%rdi)
	adc	%rcx, %rax		
	
	ret

.Lf2:	.byte	0xc4,98,171,0xf6,6
	lea	8(%rsi), %rsi
	lea	8(%rdi), %rdi
	.byte	0xc4,226,179,0xf6,6
	adc	%r11, %r10

	.align	32, 0x90
.Ltop:	.byte	0x66,77,0x0f,0x38,0xf6,200
	mov	%r10, -8(%rdi)
	jrcxz	.Lend
.Lb1:	.byte	0xc4,98,171,0xf6,70,8
	lea	-1(%rcx), %rcx
	mov	%r9, (%rdi)
	.byte	0x66,76,0x0f,0x38,0xf6,208
.Lb0:	.byte	0xc4,226,179,0xf6,70,16
	.byte	0x66,77,0x0f,0x38,0xf6,200
	mov	%r10, 8(%rdi)
.Lb7:	.byte	0xc4,98,171,0xf6,70,24
	lea	64(%rsi), %rsi
	.byte	0x66,76,0x0f,0x38,0xf6,208
	mov	%r9, 16(%rdi)
.Lb6:	.byte	0xc4,226,179,0xf6,70,224
	.byte	0x66,77,0x0f,0x38,0xf6,200
	mov	%r10, 24(%rdi)
.Lb5:	.byte	0xc4,98,171,0xf6,70,232
	.byte	0x66,76,0x0f,0x38,0xf6,208
	mov	%r9, 32(%rdi)
.Lb4:	.byte	0xc4,226,179,0xf6,70,240
	.byte	0x66,77,0x0f,0x38,0xf6,200
	mov	%r10, 40(%rdi)
.Lb3:	.byte	0xc4,98,171,0xf6,70,248
	mov	%r9, 48(%rdi)
	lea	64(%rdi), %rdi
	.byte	0x66,76,0x0f,0x38,0xf6,208
	.byte	0xc4,226,179,0xf6,6
	jmp	.Ltop

.Lf7:	.byte	0xc4,226,179,0xf6,6
	lea	-16(%rsi), %rsi
	lea	-16(%rdi), %rdi
	adc	%r11, %r9
	jmp	.Lb7
	.size	__gmpn_mul_1,.-__gmpn_mul_1

