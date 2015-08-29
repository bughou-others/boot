# vim:tabstop=8 shiftwidth=8
#file:			boot_sector.s
#author:		bughou@gmail.com
#last modified:		2009.12.17

GDT_ADDRESS		=0x01000	#全局描述符表的地址
GDT_SIZE		=0x05		#全局描述符表的长度
IDT_ADDRESS		=GDT_ADDRESS+GDT_SIZE<<3	#中断描述符表的地址
IDT_SIZE		=0x31		#中断描述符表的长度
KERNEL_CODE_SELECTOR	=0x01<<3	#内核代码段的选择符
KERNEL_DATA_SELECTOR	=0x02<<3	#内核数据段的选择符
USER_CODE_SELECTOR	=0x03<<3+3	#用户代码段的选择符
USER_DATA_SELECTOR	=0x04<<3+3	#用户数据段的选择符

KEYBOARD_BUFFER 	=0xe0
HD_BUFFER		=0xe4
HD_DO			=0xe8
TICK			=0xf4
TICK100			=0xf8
CURSOR			=0xf0
DELAY			=0x00eb00eb
HZ			=100
.macro screen row,column
	0xb8000+(\row*80+\column)*2
.endm


