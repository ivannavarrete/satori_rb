
require 'lib/deviceinfo'


class AvrDeviceInfo < DeviceInfo
	name		"AT90S8535"
	desciption	"foo"
	memory		:sram,		0x60-0x25F
	memory		:eeprom,	0x0-0x1FF
	memory		:flash,		0x0-0x1FFF
end
