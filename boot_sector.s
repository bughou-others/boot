# vim:tabstop=8 shiftwidth=8
#file:			boot_sector.s
#author:		bughou@gmail.com
#last modified:		2009.12.17
#fuction:
#			1. load the file 'service.s' at 0x01000.
#			2. load the file 'set_up.s' at 0x07ce0.
#			3. jump to protected mode.
#note:
#			1. this file is the boot sector loaded at 0x07c00.
#			2. this is the only file that uses segment model,others
#			   will use flat model.
#			3. this is the only file that runs in real mode,others will
#			   run in protected mode.
#			4. as 'cs' is assigned to 0x07c0,the 'ld' parameter '-Ttext'
#			   should be 0x00.
.include "header.s"
.text
.code16
.global _start
_start:

#initialise the segment registers and stack pointer!
	ljmp 	$0x07c0,$1f
1:	mov  	%cs,%ax
	mov  	%ax,%ds
	#mov	$0x9fc0,%ax
	mov  	%ax,%ss
	xor	%sp,%sp

#read the following 'service.s' sectors!
1:	mov	$0x0210,%ax	#ah=sevice 2,al=0x10 sectors
	mov	$0x0100,%di
	mov	%di,%es
	xor	%bx,%bx		#es:bx=buffer,i.e.0x1000
	mov	$0x0002,%cx	#cl[7:6]ch[7:0]=track 0,cl[5:0]=sector 2
	mov	$0x0000,%dx	#dh=head 0,dl=drive 0
	int	$0x13
	jnc	1f
	mov	$0x0000,%ax
	mov	$0x0000,%dx
	int	$0x13
	jmp	1b


#read the following 'set_up.s' sectors!
1:	mov	$0x0203,%ax	#ah=sevice 2,al=3 sectors
	mov	$0x07e0,%di
	mov	%di,%es
	xor	%bx,%bx		#es:bx=buffer
	mov	$0x0012,%cx	#cl[7:6]ch[7:0]=track 0,cl[5:0]=sector 0x12
	mov	$0x0000,%dx	#dh=head 0,dl=drive 0
	int	$0x13
	jnc	1f
	mov	$0x0000,%ax
	mov	$0x0000,%dx
	int	$0x13
	jmp	1b
1:
#enable a20!
	mov 	$0x2401,%ax
	int     $0x15

#now,we want to change to protected mode,and
#external interrupt is disabled,until the new interrupt
#mechanism in protected mode has been initialized!
	cli

#load gdtr!
	lgdt	gdtr

#load idtr!
	lidt	idtr

#set the PE bit of cr0!
	mov	$0x01,%ax
	lmsw	%ax

#jump to protected mode!
	ljmp	$KERNEL_CODE_SELECTOR,$0x7e00


####################data#########################
.balign 4
	.word	0x0000
gdtr:
	.word 	GDT_SIZE<<3-1
	.long	GDT_ADDRESS

	.word	0x0000
idtr:
	.word	IDT_SIZE<<3-1
	.long	IDT_ADDRESS

.org 0x1fe
	.word 	0xaa55

