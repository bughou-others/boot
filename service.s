# vim:tabstop=8 shiftwidth=8
#file:			service.s
#author:		bughou@gmail.com
#last modified:		2009.12.17
#function:
#			1. global descriptor table.
#			2. interrupt descriptor table.
#			3. interrupt service routines.
#note:
#			1. this file is loaded at 0x01000.
#			2. this is the background service file,and will not
#			   be executed in foreground.
#			3. the 'ld' parameter '-Ttext' should be 0x1000.
.include "header.s"
.text
.global _start
_start:

################1. global descriptor table########################
#gdt entry format: '0xYYrZstYYYYYYZZZZ'
#the eight 'Y' is base address,the five 'Z' is limit.
#r:G(0=1B,1=4kB),D/B(0=16bit,1=32bit),L(0=compatibility-mode,1=64bit-mode),AVL
#s:P(0=not~,1=present),DPL(00~11),S(0=system,1=code/data)
#t:T(0=data),E(0=not~,1=expand-down),W(0=not~,1=writable),A(0=not~,1=accessed)
#t:T(1=code),C(0=not~,1=conforming),R(0=not~,1=readable),A(0=not~,1=accessed)

	.quad 	0x0000000000000000
	.quad 	0x00cf9a000000ffff#CODE_KERNEL
	.quad 	0x00cf92000000ffff#DATA_KERNEL
	.quad	0x00cffa000000ffff#CODE_USER
	.quad	0x00cff2000000ffff#DATA_USER

#################2. interrupt descriptor table####################
#interrupt gate,trap gate format: '0xYYYYstuvZZZZYYYY
#the eight 'Y' is isr address,the four 'Z' is code segment selector.
#s:P(0=not~,1=present),DPL(00~11),S(0=system,1=code/data)
#t:D(0=16bit,1=32bit),T(110=interrupt gate,111=trap gate)
#uv[7:5]=0b000,uv[4:0] is reserved.
.macro int_gate isr_address
	.word	\isr_address 
	.word	0x0008	#code selector
	.word	0x8e00	#interrupt gate
	.word	0x0000
.endm

	int_gate isr0x00
	int_gate isr0x01
	int_gate isr0x02
	int_gate isr0x03
	int_gate isr0x04
	int_gate isr0x05
	int_gate isr0x06
	int_gate isr0x07
	int_gate isr0x08
	int_gate isr0x09
	int_gate isr0x0a
	int_gate isr0x0b
	int_gate isr0x0c
	int_gate isr0x0d
	int_gate isr0x0e
	int_gate isr0x0f
	int_gate isr0x10
	int_gate isr0x11
	int_gate isr0x12
	int_gate isr0x13
	int_gate isr0x14
	int_gate isr0x15
	int_gate isr0x16
	int_gate isr0x17
	int_gate isr0x18
	int_gate isr0x19
	int_gate isr0x1a
	int_gate isr0x1b
	int_gate isr0x1c
	int_gate isr0x1d
	int_gate isr0x1e
	int_gate isr0x1f
	int_gate isr0x20
	int_gate isr0x21
	int_gate isr0x22
	int_gate isr0x23
	int_gate isr0x24
	int_gate isr0x25
	int_gate isr0x26
	int_gate isr0x27
	int_gate isr0x28
	int_gate isr0x29
	int_gate isr0x2a
	int_gate isr0x2b
	int_gate isr0x2c
	int_gate isr0x2d
	int_gate isr0x2e
	int_gate isr0x2f
	int_gate isr0x30

############3. interrupt service routines###########

#interrupt 0x00:divide error exception,fault
isr0x00:
	push	%ebp
	mov	%esp,%ebp
	push	%esi
	push	%eax
	push	%ecx
	mov	$str0x00,%esi
	mov	CURSOR,%edi
	call	print_str_esi_edi
	mov	8(%ebp),%ax	#cs
	call	print_hex_ax_edi
	movw	$0x073a,(%edi)
	add	$2,%edi
	mov	4(%ebp),%eax	#eip
	call	print_hex_eax_edi
	mov	%edi,CURSOR
	pop	%ecx
	pop	%eax
	pop	%esi
	pop	%ebp
	iret

#interrupt 0x01:debug exception,fault or trap
isr0x01:

#interrupt 0x02:NMI interrupt
isr0x02:

#interrupt 0x03:breakpoint exception,trap
isr0x03:

#interrupt 0x04:overflow exception,trap
isr0x04:

#interrupt 0x05:bound range exceeded exception,fault
isr0x05:

#interrupt 0x06:invalid opcode exception,fault
isr0x06:

#interrupt 0x07:device not available exception,fault
isr0x07:

#interrupt 0x08:double fault exception,abort
#error code is always zero
isr0x08:

#interrupt 0x09:coprocessor segment overrun exception,abort
isr0x09:

#interrupt 0x0a:invalid TSS exception,fault
#error code pushed
isr0x0a:

#interrupt 0x0b:segment not present exception,fault
#error code pushed
isr0x0b:

#interrupt 0x0c:stack exception,fault
#error code pushed
isr0x0c:

#interrupt 0x0d:general protection exception,fault
#error code pushed
isr0x0d:

#interrupt 0x0e:page exception,fault
#error code pushed
isr0x0e:

#interrupt 0x0f:interrupt 0x0f is reserved by intel
isr0x0f:

#interrupt 0x10:x87 FPU floating point error exception,fault
isr0x10:

#interrupt 0x11:alignment check exception,fault
#error code is always zero
isr0x11:

#interrupt 0x12:machine check exception,abort
isr0x12:

#interrupt 0x13:SIMD floating point exception,fault
isr0x13:

#interrupt 0x14~0x1f:reserved by intel
isr0x14:
isr0x15:
isr0x16:
isr0x17:
isr0x18:
isr0x19:
isr0x1a:
isr0x1b:
isr0x1c:
isr0x1d:
isr0x1e:
isr0x1f:

#timer interrupt
isr0x20:
	push	%eax
	incb	TICK100
	mov	TICK100,%al
	mov	$(0xb8000+49*2),%edi
	call	print_hex_al_edi
	cmpl	$100,TICK100
	jc	1f
	movl	$0,TICK100
	incl	TICK
	mov	TICK,%eax
	mov	$(0xb8000+40*2),%edi
	call	print_hex_eax_edi
1:	mov	$0x20,%al
	outb	$0x20
	pop	%eax
	iret
#keyboard interrupt
isr0x21:
	push	%eax
	push	%ebx
	inb	$0x60
	mov	%al,KEYBOARD_BUFFER
	mov	CURSOR,%edi
	call	print_hex_al_edi
	mov	%edi,CURSOR
	inb	$0x61
	or	$0x80,%al
	outb	$0x61
	and	$0x7f,%al
	outb	$0x61
	mov	$0x20,%al
	outb	$0x20
	pop	%ebx
	pop	%eax
	iret
isr0x22:
isr0x23:
isr0x24:
isr0x25:
isr0x26:
isr0x27:
isr0x28:
isr0x29:
isr0x2a:
isr0x2b:
isr0x2c:
isr0x2d:
#ide0 interrupt
isr0x2e:
	push	%eax
	push	%edx
	push	%ecx
	mov	$0x1f7,%edx
	inb	%dx
	call	print_hex_al_edi
	call	*HD_DO	
	mov	$0x20,%al
	outb	$0xa0
	outb	$0x20
	pop	%ecx
	pop	%edx
	pop	%eax
	iret
#ide1 interrupt
isr0x2f:
isr0x30:
	call	print_str_esi_edi
	iret
#################routines##############
hd_in:
	mov	HD_BUFFER,%edi
	mov	$0x80,%ecx
	mov	$0x1f0,%edx
	rep
	insl
	addl	$0x200,HD_BUFFER
	ret
hd_out:
	mov	HD_BUFFER,%esi
	mov	$0x80,%ecx
	mov	$0x1f0,%edx
	rep
	outsl
	addl	$0x200,HD_BUFFER
	ret
print_hex_eax_edi:
	push	%ecx
	push	%edx
	mov	$0x08,%cl
	mov	$0x02,%dh
1:	rol	$0x04,%eax
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%edi)
	add	$0x02,%edi
	dec	%cl
	jnz	1b	
	pop	%edx
	pop	%ecx
	ret
print_hex_ax_edi:
	push	%ecx
	push	%edx
	mov	$0x04,%cl
	mov	$0x02,%dh
1:	rol	$0x04,%ax
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%edi)
	add	$0x02,%edi
	dec	%cl
	jnz	1b
	pop	%edx
	pop	%ecx
	ret
print_hex_al_edi:
	push	%ecx
	push	%edx
	mov	$0x02,%cl
	mov	$0x07,%dh
1:	rol	$0x04,%al
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%edi)
	add	$0x02,%edi
	dec	%cl
	jnz	1b
	pop	%edx
	pop	%ecx
	ret
print_str_esi_edi:
	push	%eax
	push	%ecx
	push	%edx
	mov	$0x02,%dh
	sub	$0x04,%esi
1:	add	$0x04,%esi
	mov	(%esi),%eax
	mov	$0x04,%cl
2:	cmp	$0,%al
	jz	1f
	mov	%al,%dl
	mov	%dx,(%edi)
	add	$0x02,%edi
	dec	%cl
	jz	1b
	shr	$0x08,%eax
	jmp	2b
1:	pop	%edx
	pop	%ecx
	pop	%eax
	ret
###########################

str0x00:	.asciz	"(int0x00)divide error exception,fault;cs:eip="
str0x01:	.asciz	"(int0x01)debug exception,fault or trap;cs:eip="
str0x02:	.asciz	"(int0x02)NMI interrupt,cs:eip="
str0x03:	.asciz	"(int0x03)breakpoint exception,trap;cs:eip="
str0x04:	.asciz	"(int0x04)overflow exception,trap;cs:eip="
str0x05:	.asciz	"(int0x05)bound range exceeded exception,fault;cs:eip="
str0x06:	.asciz	"(int0x06)invalid opcode exception,fault;cs:eip="
str0x07:	.asciz	"(int0x07)device not available exception,fault;cs:eip="
str0x08:	.asciz	"(int0x08)double fault exception,abort;cs:eip="
str0x09:	.asciz	"(int0x09)coprocessor segment overrun exception,abort;cs:eip="
str0x0a:	.asciz	"(int0x0a)invalid TSS exception,fault;cs:eip="
str0x0b:	.asciz	"(int0x0b)segment not present exception,fault;cs:eip="
str0x0c:	.asciz	"(int0x0c)stack exception,fault;cs:eip="
str0x0d:	.asciz	"(int0x0d)general protection exception,fault;cs:eip="
str0x0e:	.asciz	"(int0x0e)page exception,fault;cs:eip="
str0x0f:	.asciz	"(int0x0f)intel reserved,cs:eip="
str0x10:	.asciz	"(int0x10)x87 FPU floating point error exception,fault;cs:eip="
str0x11:	.asciz	"(int0x11)alignment check exception,fault;cs:eip="
str0x12:	.asciz	"(int0x12)machine check exception,abort;cs:eip="
str0x13:	.asciz	"(int0x13)SIMD floating point exception,fault;cs:eip="
.org 0x2000
