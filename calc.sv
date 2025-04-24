module calculadora (
    input  logic [3:0]  cmd,      // dígito (0-9) ou comando
    input  logic        clock,
    input  logic        reset,
    output logic [1:0]  status,   // 0=idle,1=busy,2=error
    output logic [3:0]  data,     // dígito atual para Display_Ctrl
    output logic [2:0]  position  // posição do display (0..7)
);

    //--- Comandos
    localparam logic [3:0]
        DIG_MAX   = 4'd9,
        CMD_PLUS  = 4'd10,
        CMD_MINUS = 4'd11,
        CMD_MUL   = 4'd12,
        CMD_RES   = 4'd14,
        CMD_CLR   = 4'd15;

    //--- FSM States
    typedef enum logic [2:0] {IDLE, IN_A, OP, IN_B, COMPUTE, DONE, ERROR} state_t;
    state_t state, next;

    //--- Operandos e acumuladores
    logic unsigned [31:0] op_a, op_b, acc;
    logic unsigned [31:0] mul_cnt;
    logic [3:0]           op_sel;
    logic [3:0]           nA, nB;
    logic                 inB;

    //--- Shift-register para 8 dígitos
    logic [3:0] shift_reg [0:7];
    logic [2:0] disp_ptr;
    // potências de 10 para conversão em DONE
    localparam int unsigned POW10 [0:7] = '{10000000,1000000,100000,10000,1000,100,10,1};

    //--- Identificadores de tipo de comando
    wire is_digit = (cmd <= DIG_MAX);
    wire is_plus  = (cmd == CMD_PLUS);
    wire is_minus = (cmd == CMD_MINUS);
    wire is_mul   = (cmd == CMD_MUL);
    wire is_res   = (cmd == CMD_RES);
    wire is_clr   = (cmd == CMD_CLR);

    //--- FSM Seq
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            op_a   <= 0; nA <= 0;
            op_b   <= 0; nB <= 0;
            op_sel <= 0;
            acc    <= 0; mul_cnt <= 0;
            inB    <= 0;
        end else begin
            state <= next;
            case (state)
                IDLE: if (is_digit) begin
                          op_a <= cmd;
                          nA   <= 1;
                      end
                IN_A: if (is_digit) begin
                          if (nA < 8) begin op_a <= op_a*10 + cmd; nA <= nA + 1; end
                          else next <= ERROR;
                      end else if (is_plus || is_minus || is_mul) begin
                          op_sel <= cmd;
                      end
                OP: if (is_digit) begin
                        inB  <= 1;
                        op_b <= cmd;
                        nB   <= 1;
                    end
                IN_B: if (is_digit) begin
                          if (nB < 8) begin op_b <= op_b*10 + cmd; nB <= nB + 1; end
                          else next <= ERROR;
                      end else if (is_res) begin
                          // iniciar cálculo
                          if (op_sel == CMD_PLUS) begin
                              acc <= op_a + op_b;
                              if (op_a + op_b >= 100000000) next <= ERROR;
                          end else if (op_sel == CMD_MINUS) begin
                              if (op_a >= op_b) acc <= op_a - op_b;
                              else next <= ERROR;
                          end else begin
                              acc     <= 0;
                              mul_cnt <= op_b;
                          end
                      end
                COMPUTE: if (mul_cnt > 0) begin
                             acc     <= acc + op_a;
                             mul_cnt <= mul_cnt - 1;
                          end
                DONE: ;
                ERROR: ;
            endcase
        end
    end

    //--- Next-state logic
    always_comb begin
        next = state;
        unique case (state)
            IDLE:   if (is_digit)         next = IN_A;
            IN_A:   if (is_plus||is_minus||is_mul) next = OP;
            OP:     if (inB)             next = IN_B;
            IN_B:   if (is_res)          next = (op_sel==CMD_MUL?COMPUTE:DONE);
            COMPUTE:if (mul_cnt == 0)    next = DONE;
            DONE:   if (is_clr)          next = IDLE;
            ERROR:  if (is_clr)          next = IDLE;
        endcase
    end

    //--- Status output
    always_comb begin
        case (state)
            COMPUTE: status = 2'd1;  // OCUPADA
            ERROR:   status = 2'd2;  // ERRO
            default: status = 2'd0;  // IDLE ou DONE ou recebendo
        endcase
    end

    //--- Shift-register & display pointer
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 8; i++) shift_reg[i] <= 4'd0;
            disp_ptr <= 3'd0;
            inB      <= 0;
        end else begin
            // clear display ao iniciar operação
            if (state == IN_A && (is_plus||is_minus||is_mul)) begin
                for (int i = 0; i < 8; i++) shift_reg[i] <= 4'd0;
            end
            // shift input de dígito
            else if ((state==IDLE||state==IN_A||state==IN_B) && is_digit) begin
                for (int i = 0; i < 7; i++) shift_reg[i] <= shift_reg[i+1];
                shift_reg[7] <= cmd;
            end
            // carregar resultado em DONE
            else if (state == DONE) begin
                for (int i = 0; i < 8; i++) begin
                    shift_reg[i] <= (acc / POW10[i]) % 10;
                end
            end
            // varredura do display
            disp_ptr <= disp_ptr + 1;
        end
    end

    assign position = disp_ptr;
    assign data     = shift_reg[disp_ptr];

endmodule