# vim:tabstop=8 shiftwidth=8
#file:			set_up.s
#author:		bughou@gmail.com
#last modified:		2009.12.17
#function:
#			1. initialise the segment registers and global varibles
#			   in protected mode.
#			2. rearrange 8259A interrupt vectors.
#			3. initialise 8354 timer.
#			4. enalbe interrupt.
#note:
#			1. this file is loaded at 0x7e00.
#			2. this is the first file starts to run in protected mode.
#			3. the 'ld' prameter '-Ttext' should be 0x7e00.
.include "header.s"
.text
.global _start
_start:

#now,we have got into protected mode!
	mov	$KERNEL_DATA_SELECTOR,%eax
	mov	%eax,%ds
	mov	%eax,%es
	mov	%eax,%ss
	mov	%eax,%fs
	mov	%eax,%gs
	mov	$0x9fc00,%esp
	movl	$(0xb8000+(80+40)*2),CURSOR #CGA buffer address.
	movl	$0x00,TICK
	movb	$0 ,TICK100

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

	mov	$0xff,%al	#OCW1 mask interrupt request.
	outb	$0x21
	.long	DELAY
	outb	$0xa1


#initialise 8254 timer0!
	mov	$0x36,%al
	outb	$0x43
	mov	$(1193180*2/HZ)&0xff,%al
	outb	$0x40
	mov	$(1193180*2/HZ)>>0x08,%al
	outb	$0x40

	mov	$0xf8,%al
	outb	$0x21
	#mov	$0xbf,%al
	#outb	$0xa1

	sti

	mov	$str0,%esi
	mov	$0xb8000,%edi
	int	$0x30
	mov	$str1,%esi
	mov	$(0xb8000+40*2),%edi
	int	$0x30
	mov	$str2,%esi
	mov	$(0xb8000+80*2),%edi
	int	$0x30

1:	hlt
	jmp	1b	
########################data######################
str0:
	.asciz	"timer0 interrupt test:"
str1:
	.asciz	"00000000:00"
str2:
	.asciz	"keyboard interrupt test:"
.org	0x600



