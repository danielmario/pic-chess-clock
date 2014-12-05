OBJECTS = main.o isr.o
OUTPUT = chess-clock.hex

all:	$(OUTPUT)
#	hexsize $(OUTPUT) 2048

$(OUTPUT):	$(OBJECTS)
	gplink --map -c -o $(OUTPUT) $(OBJECTS)

%.o:	%.asm
	gpasm -c $<

clean:
	rm -f *.o *.lst *.map *.hex *.cod *.cof

