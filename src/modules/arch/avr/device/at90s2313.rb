
require 'avrdevice'


class AT90S2313 < AvrDevice
	description	"Description for At90s2313."
	memory		"sram",		0x60..0x25F
	memory		"eeprom",	0x0..0x1FF
	memory		"flash",	0x0..0xFFF
end
