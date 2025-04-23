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

    // FSM sequencial
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            op_a   <= 0; nA <= 0;
            op_b   <= 0; nB <= 0;
            inB    <= 0;
            acc    <= 0;
            mul_cnt<= 0;
        end else begin
            state <= next;
            case (state)
                IDLE: if (cmd <= DIG_MAX) begin
                          op_a <= cmd;
                          nA   <= 1;
                      end
                IN_A: if (cmd <= DIG_MAX) begin
                          if (nA < 8) begin
                              op_a <= op_a*10 + cmd;
                              nA <= nA+1;
                          end else next <= ERROR;
                      end else if (cmd==CMD_PLUS||cmd==CMD_MINUS||cmd==CMD_MUL) begin
                          op_sel <= cmd;
                      end
                OP: if (cmd <= DIG_MAX) begin
                        inB <= 1;
                        op_b <= cmd;
                        nB   <= 1;
                    end
                IN_B: if (cmd <= DIG_MAX) begin
                          if (nB < 8) begin
                              op_b <= op_b*10 + cmd;
                              nB <= nB+1;
                          end else next <= ERROR;
                      end else if (cmd==CMD_RES) begin
                          if (op_sel==CMD_PLUS)  acc <= op_a+op_b;
                          else if (op_sel==CMD_MINUS) acc <= (op_a>=op_b?op_a-op_b:32'hFFFFFFFF);
                          else begin acc<=0; mul_cnt<=op_b; end
                      end
                COMPUTE: if (mul_cnt>0) begin
                             acc<=acc+op_a;
                             mul_cnt<=mul_cnt-1;
                          end
                DONE: ;
                ERROR: ;
            endcase
        end
    end

    
endmodule