module calculadora (
    input logic [3:0] cmd,
    input logic clock,
    input logic reset,

    output logic [1:0] status,
    output logic [3:0] data,    
    output logic [2:0] position 
);

    // comandos
    localparam logic [3:0]
        DIG_MIN   = 4'b0000, 
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
    logic [31:0] op_a;  
    logic [31:0] op_b;  
    logic [31:0] acc;
    logic [31:0] mul_cnt;
    logic [3:0]  op_sel;

    // controle de quantos dígitos já recebidos (op_a/op_b)
    logic [3:0] nA; 
    logic [3:0] nB; 
    logic       inB; 

    // sinais de saída para o módulo control
    logic [3:0] calc_data_out;
    logic [2:0] calc_position_out;

    // saída
    assign data = calc_data_out;
    assign position = calc_position_out; // Saída de 3 bits

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            op_a   <= 0; nA <= 0;
            op_b   <= 0; nB <= 0;
            inB    <= 0;
            acc    <= 0;
            mul_cnt<= 0;
            op_sel <= 0; // limpa operador selecionado

            // limpa as saídas para o Control
            calc_data_out <= 4'd0;
            calc_position_out <= 3'd0; // posição 0

        end else begin
            state <= next;
            case (state)
                IDLE:
                    if (cmd >= DIG_MIN && cmd <= DIG_MAX) begin
                        op_a <= cmd;
                        nA   <= 1;  
                        calc_data_out <= cmd;
                        calc_position_out <= 3'd0;
                    end
                IN_A:
                    if (cmd >= DIG_MIN && cmd <= DIG_MAX) begin
                        if (nA < 8) begin
                            op_a <= op_a * 10 + cmd;
                            nA   <= nA + 1;
                            calc_data_out <= cmd;
                            calc_position_out <= nA[2:0];
                        end else begin
                        end
                    end else if (cmd == CMD_PLUS || cmd == CMD_MINUS || cmd == CMD_MUL) begin
                        op_sel <= cmd;
                        inB    <= 0;
                        op_b   <= 0; nB <= 0;
                        calc_data_out <= CMD_CLR;
                        calc_position_out <= 3'd0;

                    end else if (cmd == CMD_CLR) begin
                         calc_position_out <= 3'd0;
                    end

                OP:
                    if (cmd >= DIG_MIN && cmd <= DIG_MAX) begin
                        inB <= 1;
                        op_b <= cmd;
                        nB   <= 1;
                        calc_data_out <= cmd;
                        calc_position_out <= 3'd0;
                    end else if (cmd == CMD_CLR) begin
                         calc_data_out <= CMD_CLR;
                         calc_position_out <= 3'd0;
                    end else if (cmd == CMD_PLUS || cmd == CMD_MINUS || cmd == CMD_MUL) begin
                        op_sel <= cmd;
                         calc_data_out <= cmd;
                         calc_position_out <= 3'd0;
                    end

                IN_B:
                    if (cmd >= DIG_MIN && cmd <= DIG_MAX) begin
                        if (nB < 8) begin
                            op_b <= op_b * 10 + cmd;
                            nB   <= nB + 1;

                             calc_data_out <= cmd;
                             calc_position_out <= nB[2:0];
                        end else begin
                        end
                    end else if (cmd == CMD_RES) begin
                         if (op_sel == CMD_PLUS) begin
                             acc <= op_a + op_b;
                         end else if (op_sel == CMD_MINUS) begin
                             acc <= (op_a >= op_b ? op_a - op_b : 32'hFFFFFFFF); // Subtração combinacional
                         end else if (op_sel == CMD_MUL) begin
                             acc <= 0; // Começa acumulação do zero
                             mul_cnt <= op_b; // Número de somas a realizar (Op_B vezes)
                         end
                    end else if (cmd == CMD_CLR) begin
                        op_b <= 0; nB <= 0; inB <= 0;
                         calc_data_out <= CMD_CLR; // Sinaliza para o Control limpar a entrada de B
                         calc_position_out <= 3'd0;
                    end

                COMPUTE:
                    if (mul_cnt > 0) begin
                        acc <= acc + op_a;       // Realiza uma soma
                        mul_cnt <= mul_cnt - 1;  // Decrementa o contador de somas
                    end

                DONE:
                    if (cmd == CMD_CLR) begin
                         calc_data_out <= CMD_CLR; // Sinaliza para o Control limpar o display
                         calc_position_out <= 3'd0;
                    end else if (cmd >= DIG_MIN && cmd <= DIG_MAX) begin
                    end

                ERROR:
                    if (cmd == CMD_CLR) begin
                         calc_data_out <= CMD_CLR; // Sinaliza para o Control limpar o display
                         calc_position_out <= 3'd0;
                    end

            endcase
        end
    end

    always_comb begin
        next = state;
        case (state)
            IDLE:    if (cmd >= DIG_MIN && cmd <= DIG_MAX) next = IN_A; // Se recebeu um dígito, vai para IN_A
            IN_A:    if (cmd == CMD_PLUS || cmd == CMD_MINUS || cmd == CMD_MUL) next = OP; // Se recebeu um operador, vai para OP
                     else if (cmd >= DIG_MIN && cmd <= DIG_MAX && nA == 8) next = ERROR; // Overflow de dígitos em IN_A
                     else if (cmd == CMD_CLR) next = IDLE; // Clear em IN_A volta para IDLE
            OP:      if (cmd >= DIG_MIN && cmd <= DIG_MAX) next = IN_B; // Se recebeu um dígito (primeiro de B), vai para IN_B
                     else if (cmd == CMD_CLR) next = IDLE; // Clear em OP volta para IDLE
                     else if (cmd == CMD_RES) next = ERROR; // Resultado sem B em OP vai para ERROR
            IN_B:    if (cmd == CMD_RES) // Se recebeu '=', determina próximo estado
                         next = (op_sel == CMD_MUL ? COMPUTE : DONE); // Vai para COMPUTE se multiplicação, DONE caso contrário
                     else if (cmd >= DIG_MIN && cmd <= DIG_MAX && nB == 8) next = ERROR; // Overflow de dígitos em IN_B
                     else if (cmd == CMD_CLR) next = OP; // Clear em IN_B volta para OP (para re-entrar B)
            COMPUTE: if (mul_cnt == 32'd0) next = DONE; // Terminou a multiplicação, vai para DONE
            DONE:    if (cmd == CMD_CLR || (cmd >= DIG_MIN && cmd <= DIG_MAX)) next = IDLE; // Clear ou novo dígito em DONE volta para IDLE (inicia nova op)
            ERROR:   if (cmd == CMD_CLR) next = IDLE; // Clear em ERROR volta para IDLE
        endcase
    end

    // status e data de saída
    always_comb begin
        case (state)
            IDLE, IN_A, OP, IN_B, DONE:
                status = 2'd0; // PRONTA
            COMPUTE:
                status = 2'd1; // OCUPADA
            ERROR:
                status = 2'd2; // ERRO
            default:
                status = 2'd2;
        endcase
    end

endmodule