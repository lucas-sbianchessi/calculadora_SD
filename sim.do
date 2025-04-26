# sim.do

# Criar 'work'.
vlib work
vmap work work


# Compilar os arquivos VHDL.
vcom -2008 display.vhd
vcom -2008 control.vhd


# Compilar os arquivos Verilog.
vlog calculadora.sv
vlog calculadora_top.sv
vlog calculadora_top_tb.sv


# Iniciar a simulacao.
vsim work.calculadora_top_tb


# Wave
add wave /dut_top/*

# Rodar
run 0

# Fim do script sim.do