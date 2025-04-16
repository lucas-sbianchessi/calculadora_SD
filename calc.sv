module calculadora (
    input logic [3] cmd,
    input logic clock,
    input logic reset,
    
    output logic [2] status,
    output logic [4] data,
    output logic [4] position
);
    logic[32] data_reg;
    logic    rest_ctrl;

    control control(
        .position(position),
        .digit(data),
        .clock(clock),
        .reset(reset),
    ); //acertar essa porra
    
    //processo botar
    casee(cmd)
        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100
        4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001: begin
        status = b'00;
        data_reg = data_reg * 10 + cmd;
        position = position + 1;

        status = b'01;
        end

    end case; 
endmodule
