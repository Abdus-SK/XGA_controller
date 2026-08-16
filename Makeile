# Makefile for XGA_controller simulation (Icarus Verilog)

SRC   = XGA_controller.sv shift_r.sv FB.sv
TB    = tb_XGA.sv
SIM   = sim.out
FLAGS = -g2012 -DSIM

.PHONY: all run view clean

all: $(SIM)

$(SIM): $(SRC) $(TB)
	iverilog $(FLAGS) -o $(SIM) $(SRC) $(TB)

run: $(SIM)
	vvp $(SIM)

view: run
	convert frame0.ppm frame0.png

clean:
	rm -f $(SIM) *.ppm *.png *.vcd