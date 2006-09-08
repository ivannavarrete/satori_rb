
#include <ruby.h>
//#include <string>

#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <termios.h>
#include <unistd.h>


void Init_serial();

static VALUE Initialize(VALUE self, VALUE device_name);
static VALUE Send(VALUE self, VALUE data, VALUE dsize);
static VALUE Receive(VALUE self, VALUE data, VALUE dsize);
static VALUE Baud(VALUE self);
static VALUE DataBits(VALUE self);
static VALUE StopBits(VALUE self);


//std::string name;	// name of serial device file
int dev;			// device file descriptor


/**
 *
 */
static VALUE Initialize(VALUE self, VALUE device_name) {
	//CheckSafeStr(device_name);	// throws TypeError exception if not a string

	dev = open(RSTRING(device_name)->ptr, O_RDWR | O_NOCTTY | O_SYNC);

	//// @Todo: Remove this hardcoded initialization; place into caller
	struct termios mode;
	cfmakeraw(&mode);
	
	cfsetispeed(&mode, B38400);						// 38400 baud
	cfsetospeed(&mode, B38400);
	mode.c_cflag = (mode.c_cflag & ~CSIZE) | CS8;	// 8 data bits
	mode.c_cflag &= ~CSTOPB;						// 1 stop bit
	
	if (tcsetattr(dev, TCSADRAIN, &mode) < 0)
		printf("Initialize: tcsetattr()\n");
	////

	return Qnil;
}


/**
 *
 */
static VALUE Send(VALUE self, VALUE data, VALUE dsize) {
	printf("send\n");

	char *data_ptr = RSTRING(data)->ptr;

	char echo_byte;
	unsigned int i;

	for (i=0; i<NUM2INT(dsize); ++i) {
		if (write(dev, data_ptr+i, 1) < 0)
			printf("write error\n"); // throw runtime error
		if (read(dev, &echo_byte, 1) < 0)
			printf("read echo error\n"); // throw runtime error
	}

	return Qnil;
}


/**
 *
 */
static VALUE Receive(VALUE self, VALUE data, VALUE dsize) {
	printf("receive\n");

	char *data_ptr = RSTRING(data)->ptr;
	uint32_t data_size = NUM2INT(dsize);

	uint32_t i;
	int res;

	for (i=res=0; i<data_size; ++i) {
		res = read(dev, data_ptr, data_size-i);
		if (res < 0)
			printf("read error\n"); // throw runtime error
	}

	return Qnil;
}


/**
 * Get the baud rate of the serial device.
 */
static VALUE Baud(VALUE self) {
	return Qnil;
}


static VALUE DataBits(VALUE self) {
	return Qnil;
}


static VALUE StopBits(VALUE self) {
	return Qnil;
}


VALUE class_serial;

void Init_serial() {
	class_serial = rb_define_class("Serial", rb_cIO);
	rb_define_method(class_serial, "initialize", Initialize, 1);
	rb_define_method(class_serial, "send", Send, 2);
	rb_define_method(class_serial, "receive", Receive, 2);
	rb_define_method(class_serial, "baud", Baud, 0);
	rb_define_method(class_serial, "data_bits", DataBits, 0);
	rb_define_method(class_serial, "stop_bits", StopBits, 0);
}
