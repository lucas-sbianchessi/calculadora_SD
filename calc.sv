module calculadora (
    input logic [3] cmd,
    input logic clock,
    input logic reset,
    
    output logic [1] status,
    output logic [3] data,
    output logic [3] position
);
    // comandos
    localparam logic [3:0]
        DIG_MAX   = 4'b1001,
        CMD_PLUS  = 4'b1010,
        CMD_MINUS = 4'b1011,
        CMD_MUL   = 4'b1100,
        CMD_RES   = 4'b1110,
        CMD_CLR   = 4'b1111;

    // estados
    typedef enum logic [2:0] {IDLE, IN_A, OP, IN_B, COMPUTE, DONE, ERROR} state_t;
    state_t state, next;

    // registradores de operandos e resultado
    logic [31:0] op_a, op_b, acc;
    logic [31:0] mul_cnt;
    logic [3:0]  op_sel;

    // controle de quantos dígitos já recebidos (op_a/op_b)
    logic [3:0] nA, nB;
    logic       inB;

    // saída
    assign position = 3'd0;
endmodule