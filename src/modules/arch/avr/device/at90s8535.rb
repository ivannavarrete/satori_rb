
require 'avrdevice'

class AT90S8535 < AvrDevice
	description	"Description for At90s8535."
	memory		"sram",		0x60..0x25F
	memory		"eeprom",	0x0..0x1FF
	memory		"flash",	0x0..0x1FFF
end
