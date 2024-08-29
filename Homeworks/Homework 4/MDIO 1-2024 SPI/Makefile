tarea: testbench_spi.v spi.ys # Archivos requeridos
	#yosys -s spi.ys # Corre sintesis
	iverilog -o salida testbench_spi.v # Corre Icarus
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
