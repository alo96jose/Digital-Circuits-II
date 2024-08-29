tarea: testbench.v mdio.ys # Only run if file testbench.v is available.
	#yosys -s mdio.ys # Corre sintesis
	iverilog -o salida testbench.v # Corre Icarus
	vvp salida # Corre la simulacion
	gtkwave waves.gtkw # Muestra las formas de ondas preacomodadas

# Next is the format for a Makefile:
# target: prerequisites
#(TAB)command
#(TAB)command
#(TAB)commando

# To eliminate trash files
clean:
	rm .*.swp # Remove .v.swp files or similar
