
module calculadora_top (
    input logic clock,      // Sinal de clock principal
    input logic reset,      // Sinal de reset principal
    input logic [3:0] cmd,  // Entrada de comando/dígito do usuário

    output logic [1:0] status,
    output logic [3:0] data,
    output logic [3:0] position,

    output logic [63:0] segments,
    output logic [31:0] result   
);
  //Fios internos para conectar o módulo calculadora
    logic [1:0] calc_status;
    logic [3:0] calc_data;
    logic [2:0] calc_position_3bit;

    // Fios internos para conectar ao módulo control
    logic [3:0] ctrl_position_in;
    logic [3:0] ctrl_digit_in;

    // Fio interno para conectar a nova saída de segmentos do módulo control
    logic [63:0] display_segments_from_control;


    // Conecta as portas do calculadora_top às portas de entrada/saída do calculadora.
    calculadora dut_calculadora (
        .clock(clock),
        .reset(reset),
        .cmd(cmd),
        .status(calc_status),
        .data(calc_data),
        .position(calc_position_3bit)
    );

    // Conexões entre o calculadora e o control
    assign ctrl_digit_in = calc_data;
    assign ctrl_position_in = {1'b0, calc_position_3bit};


    // Instancia o módulo de controle (control) e conecta as entradas/saídas
    control dut_control (
        .clock(clock),
        .reset(reset),
        .position(ctrl_position_in),
        .digit(ctrl_digit_in),
        .segments_out(display_segments_from_control)
    );


    // Conectaa as saídas do calculadora_top às saídas dos módulos internos
    assign status = calc_status;
    assign data = calc_data;
    assign position = ctrl_position_in;
    assign segments = display_segments_from_control;

endmodule