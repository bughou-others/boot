# vim:tabstop=8 shiftwidth=8
#file:			makefile
#author:		bughou@gmail.com
#last modified:		2009.12.17

my.img:	boot_sector.img service.img set_up.img
	cat boot_sector.img service.img set_up.img > my.img

boot_sector.img:boot_sector.o
	ld boot_sector.o -o boot_sector.img --oformat binary -Ttext 0x00
service.img:service.o
	ld service.o -o service.img --oformat binary -Ttext 0x01000
set_up.img:set_up.o
	ld set_up.o -o set_up.img --oformat binary -Ttext 0x7e00

boot_sector.o:boot_sector.s
	as boot_sector.s -o boot_sector.o
service.o:service.s
	as service.s -o service.o
set_up.o:set_up.s
	as set_up.s -o set_up.o


