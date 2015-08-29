#there are many ways to enable a20 address line.
#no.1
	movw 	$0x2401,%ax
	int     $0x15
#no.2
	cli
enable_a20:
	inb  	$0x64
	test 	$0x02,%al
	jnz  	enable_a20
	mov	$0xbf,%al
	outb	$0x64
#no.3
	inb	$0x92
	or	$0x02,%al
	outb	$0x92
#no.4
	inb	$0xee,%al
#no.5
	call	wait_8042_empty
	mov  	$0xd1,%al
	outb  	$0x64
	call	wait_8042_empty
	mov	$0xdf,%al
	outb	$0x60
	call	wait_8042_empty



#############################routines########################
wait_8042_empty:
	.word 	0x00eb,0x00eb
	inb	$0x64
	test	$0x02,%al
	jnz	wait_8042_empty
	ret
print_eax:
	push	%eax
	push	%ebx
	push	%cx
	push	%dx
	mov	$0x08,%cl
	mov	CORSUR,%ebx
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
	pop	%eax
	ret
print_cx:
	push	%ebx
	mov	CORSUR,%ebx
	mov	%cx,(%ebx)
	add	$0x02,%ebx
	mov	%ebx,CORSUR
	pop	%ebx
	ret
#把al转换为十六进制字符串存放在dx中
hex:	
	mov %al,%dh
	mov %al,%dl
	shr $0x4,%dl
	and $0xf0f,%dx

	add $0x30,%dh
	cmp $0x3a,%dh
	jc l0
	add $0x7,%dh
l0:
	add $0x30,%dl
	cmp $0x3a,%dl
	jc l1
	add $0x7,%dl
l1:
	ret




