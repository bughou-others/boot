GDT		=0x00
CODE_KERNEL	=0x01*0x08
DATA_KERNEL	=0x02*0x08
KEYBOARD_BUFFER =0xe0
HD_BUFFER	=0xe4
HD_DO		=0xe8
CORSUR		=0xf0
TICK		=0xf4
IDT		=0x100
ISR		=IDT+0x800
IDT_LOW		=0x00080000+(ISR&0x0000ffff)
IDT_HIGH	=0x00008e00+(ISR&0xffff0000)
DELAY		=0x00eb00eb
HZ		=100
.text
.code16
.global _start
_start:

#initialise the segment registers and stack pointer!
	ljmp 	$0x00,$1f
1:	mov  	%cs,%ax
	mov  	%ax,%ds
	mov  	%ax,%es
	mov  	%ax,%ss
	mov	$0x7c00,%sp

#read the following sectors!
1:	mov	$0x0203,%ax	#ah=sevice 2,al=3 sectors
	mov	$0x7e00,%bx	#es:bx=buffer
	mov	$0x0002,%cx	#cl[6:7]ch=track 0,cl[0:5]=sector 2
	mov	$0x0000,%dx	#dh=head 0,dl=drive 0
	int	$0x13
	jnc	1f
	mov	$0x0000,%ax
	mov	$0x0000,%dx
	int	$0x13
	jmp	1b

#enable a20!
1:	movw 	$0x2401,%ax
	int     $0x15

#from now on,we want to change to protected mode,and
#external interrupt is disabled,until the new interrupt
#mechanism in protected mode has been initialized!
	cli

#set up gdt!
	mov  	$gdt,%si
	mov  	$GDT,%di
	mov  	$(gdt_end-gdt)/0x04,%cx
	cld
	rep
	movsl

#load gdtr!
	lgdt	gdtr

#set the PE bit of cr0!
	mov	$0x01,%ax
	lmsw	%ax

#jump to protected mode!
	ljmp	$CODE_KERNEL,$1f


####################data#########################
	.balign 8
gdt:
	.quad 	0x0000000000000000
	.quad 	0x00cf9a000000ffff
	.quad 	0x00cf92000000ffff
gdt_end:
	.balign 4
	.word	0x00
gdtr:
	.word 	gdt_end-gdt-0x01
	.long 	GDT
.org 0x1fe
	.word 	0xaa55

###################################################
#######now,we have got into protected mode!########
###################################################

.code32
1:	mov	$DATA_KERNEL,%eax
	mov	%eax,%ds
	mov	%eax,%es
	mov	%eax,%ss
	mov	%eax,%fs
	mov	%eax,%gs
	mov	$0x9fc00,%esp
	movl	$0xb8000,CORSUR
	movl	$0x00,TICK

/*	mov	$0x9fc4d,%ebx
	mov	(%ebx),%ax
	call	print_ax
	mov	$0x0720,%cx
	call	print_cx

	mov	2(%ebx),%al
	call	print_al
	mov	$0x0720,%cx
	call	print_cx

	mov	0x0e(%ebx),%al
	call	print_al
*/
#rearrange default 8259A interrupt vectors to 0x20~0x2f!
	mov	$0x11,%al	#ICW1
	outb	$0x20
	.long	DELAY
	outb	$0xa0
	.long	DELAY

	mov	$0x20,%al	#ICW2
	outb	$0x21
	.long	DELAY
	mov	$0x28,%al
	outb	$0xa1
	.long	DELAY

	mov	$0x04,%al	#ICW3
	outb	$0x21
	.long	DELAY
	mov	$0x02,%al
	outb	$0xa1
	.long	DELAY

	mov	$0x01,%al	#ICW4
	outb	$0x21
	.long	DELAY
	outb	$0xa1
	.long	DELAY

	mov	$0xff,%al	#OCW1
	outb	$0x21
	.long	DELAY
	outb	$0xa1

#set up idt!
	mov	$IDT,%edi
	mov	$0x100,%ecx
1:
	movl	$IDT_LOW,(%edi)
	movl	$IDT_HIGH,4(%edi)
	add	$0x08,%edi
	dec	%ecx
	jnz	1b
#load idtr!
	lidt	idtr

#set up the default interrupt service routine isr!
	mov	$isr,%esi
	mov	$ISR,%edi
	mov	$(routines_end-isr),%ecx
	cld
	rep
	movsb
	movw	$isr0x20_timer-isr+ISR,IDT+8*0x20
	movw	$isr0x21_keyboard-isr+ISR,IDT+8*0x21
	movw	$isr0x2e_ide0-isr+ISR,IDT+8*0x2e
#initialise 8254 timer0!
	mov	$0x36,%al
	outb	$0x43
	mov	$(1193180/HZ)&0xff,%al
	outb	$0x40
	mov	$(1193180/HZ)>>0x08,%al
	outb	$0x40
	mov	$0xf8,%al
	outb	$0x21
	mov	$0xbf,%al
	outb	$0xa1
	sti
#hard disk test!
1:	hlt
	mov	$0x1f7,%dx	
	inb	%dx		#state
	and	$0x80,%al
	#cmp	$0x40,%al
	jnz	1b

	/*mov	0x9fc3d+8,%al
	mov	$0x3f6,%dx
	outb	%dx
	call	print_eax
	mov	0x9fc3d+5,%ax
	mov	$0x1f1,%dx
	outb	%dx
	call	print_eax
	mov	$0x0,%al
	mov	$0x1f2,%dx
	outb	%dx		#sector count
	mov	$0x01,%al
	mov	$0x1f3,%dx
	outb	%dx		#sector number
	mov	$0x00,%al
	mov	$0x1f4,%dx
	outb	%dx		#cylinder number low
	mov	$0x00,%al
	mov	$0x1f5,%dx
	outb	%dx		#cylinder number high
	mov	$0xa0,%al
	mov	$0x1f6,%dx
	outb	%dx		#device number,head number
	mov	$0x30,%al
	mov	$0x1f7,%dx
	outb	%dx		#command

	mov	$0x1f0,%dx
	mov	$0x100,%ecx
	mov	$0x2e3f,%ax
1:	outw	%dx
	dec	%ecx
	jnz	1b
	movl	$hd_out,HD_DO*/
/*1:	hlt
	mov	$0x17f,%dx
	inb	%dx		#status
	and	$0x80,%al
	jnz	1b
*/
#time
	#hlt
	#mov	$200,%ebx
	#xor	%edx,%edx
	#mov	TICK,%eax
	#div	%ebx
	#call	print_eax
#keyboard
	#movb	KEYBOARD_BUFFER,%al
	#and	$0xff,%eax
	#call	print_eax
	mov	$0,%eax
	movl	$print_eax,HD_DO
	call	*HD_DO	
1:	hlt
	jmp	1b	
#############################routines########################
isr:
	push	%ax
	push	%cx
	mov	$0x0721,%cx
	call	print_cx
	#mov	$0x20,%al
	#outb	$0x20
	pop	%cx
	pop	%ax
	iret
isr0x20_timer:
	push	%ax
	incl	TICK
	mov	$0x20,%al
	outb	$0x20
	pop	%ax
	iret
isr0x21_keyboard:
	push	%ax
	inb	$0x60
	mov	%al,KEYBOARD_BUFFER
	inb	$0x61
	or	$0x80,%al
	outb	$0x61
	and	$0x7f,%al
	outb	$0x61
	mov	$0x20,%al
	outb	$0x20
	pop	%ax
	iret
isr0x2e_ide0:
	push	%eax
	push	%dx
	push	%ecx
	mov	$0x1f7,%dx
	inb	%dx
	call	print_al
	#mov	HD_DO,%eax
	call	*HD_DO	
	mov	$0x20,%al
	outb	$0xa0
	outb	$0x20
	pop	%ecx
	pop	%dx
	pop	%eax
	iret
hd_in:
	mov	HD_BUFFER,%edi
	mov	$0x80,%ecx
	mov	$0x1f0,%dx
	rep
	insl
	addl	$0x200,HD_BUFFER
	ret
hd_out:
	mov	HD_BUFFER,%esi
	mov	$0x80,%ecx
	mov	$0x1f0,%dx
	rep
	outsl
	addl	$0x200,HD_BUFFER
	ret
print_eax:
	push	%ebx
	push	%cx
	push	%dx
	mov	CORSUR,%ebx
	mov	$0x08,%cl
	mov	$0x07,%dh
1:	rol	$0x04,%eax
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%ebx)
	add	$0x02,%ebx
	dec	%cl
	jnz	1b	
	mov	%ebx,CORSUR
	pop	%dx
	pop	%cx
	pop	%ebx
	ret
print_ax:
	push	%ebx
	push	%cx
	push	%dx
	mov	CORSUR,%ebx
	mov	$0x04,%cl
	mov	$0x07,%dh
1:	rol	$0x04,%ax
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%ebx)
	add	$0x02,%ebx
	dec	%cl
	jnz	1b
	mov	%ebx,CORSUR
	pop	%dx
	pop	%cx
	pop	%ebx
	ret
print_al:
	push	%ebx
	push	%cx
	push	%dx
	mov	CORSUR,%ebx
	mov	$0x02,%cl
	mov	$0x07,%dh
1:	rol	$0x04,%al
	mov	%al,%dl
	and	$0x0f,%dl
	add	$0x30,%dl
	cmp	$0x3a,%dl
	jc	2f
	add	$0x07,%dl
2:	mov	%dx,(%ebx)
	add	$0x02,%ebx
	dec	%cl
	jnz	1b
	mov	%ebx,CORSUR
	pop	%dx
	pop	%cx
	pop	%ebx
	ret
print_cx:
	push	%ebx
	mov	CORSUR,%ebx
	mov	%cx,(%ebx)
	add	$0x02,%ebx
	mov	%ebx,CORSUR
	pop	%ebx
	ret
routines_end:	
	

########################data######################
	.balign 4
	.word	0x00
idtr:
	.word	0x7ff
	.long	IDT

.org	0x800


