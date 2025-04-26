`timescale 1ns / 1ps

module calculadora_top_tb;

    logic clock;
    logic reset;
    logic [3:0] cmd;

    logic [1:0] status;
    logic [3:0] data;
    logic [3:0] position;
    logic [63:0] segments;
    logic [31:0] result;

    // clock
    parameter CLK_PERIOD = 10;

    calculadora_top dut_top (
        .clock(clock),
        .reset(reset),
        .cmd(cmd),
        .status(status),
        .data(data),
        .position(position),
        .segments(segments),
        .result(result)
    );

    always begin
        # (CLK_PERIOD / 2);
        clock = ~clock;
    end

    initial begin
        clock = 0;
        reset = 1;
        cmd   = 4'b0;

        @(posedge clock);
        @(posedge clock);
        reset = 0;
        @(posedge clock);
        $display("--- Reset Completo e Liberado ---");

        // (12 + 34 = 46)

        $display("--- Test Case 1: Adicao (12 + 34 = 46) ---");
        cmd = 4'd1; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd2; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1010; @(posedge clock); $display("Time=%0t: Cmd=%h (+), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, status, data, position, segments);
        cmd = 4'd3; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd4; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1110; @(posedge clock); $display("Time=%0t: Cmd=%h (=), Status=%b, Data=%h, Pos=%h", $time, cmd, status, data, position);
        @(posedge clock);
        $display("Time=%0t: calculadora DONE. Result=%d (0x%h), Status=%b", $time, result, result, status);
        $display("Time=%0t: Segments=%h (Ainda nao atualizado com o resultado)", $time, segments);

        repeat (33) @(posedge clock);
        $display("Time=%0t: Adicao - Conversao BCD Finalizada. Status=%b, Result=%d (0x%h)", $time, status, result, result);
        $display("Time=%0t: Segments=%h (Deve mostrar 46)", $time, segments);

        cmd = 4'b1111; @(posedge clock); $display("Time=%0t: Cmd=%h (CLR), Status=%b", $time, cmd, status);
        @(posedge clock); $display("Time=%0t: Apos Clear - Status=%b, Segments=%h (Limpo?)", $time, status, segments);


        // (50 - 15 = 35)
        $display("--- Test Case 2: Subtracao (50 - 15 = 35) ---");
        cmd = 4'd5; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd0; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1011; @(posedge clock); $display("Time=%0t: Cmd=%h (-), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, status, data, position, segments);
        cmd = 4'd1; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd5; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1110; @(posedge clock); $display("Time=%0t: Cmd=%h (=), Status=%b, Data=%h, Pos=%h", $time, cmd, status, data, position);

        @(posedge clock); $display("Time=%0t: calculadora DONE. Result=%d (0x%h), Status=%b", $time, result, result, status);
        repeat (33) @(posedge clock);
        $display("Time=%0t: Subtracao - Conversao BCD Finalizada. Status=%b, Result=%d (0x%h)", $time, status, result, result);
        $display("Time=%0t: Segments=%h (Deve mostrar 35)", $time, segments);

        cmd = 4'b1111; @(posedge clock); $display("Time=%0t: Cmd=%h (CLR), Status=%b", $time, cmd, status);
        @(posedge clock); $display("Time=%0t: Apos Clear - Status=%b, Segments=%h", $time, status, segments);


        // (7 * 8 = 56)
        $display("--- Test Case 3: Multiplicacao (7 * 8 = 56) ---");
        cmd = 4'd7; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1100; @(posedge clock); $display("Time=%0t: Cmd=%h (*), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, status, data, position, segments);
        cmd = 4'd8; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'b1110; @(posedge clock); $display("Time=%0t: Cmd=%h (=), Status=%b, Data=%h, Pos=%h", $time, cmd, status, data, position); // COMPUTE

        repeat (8 + 1) begin
            @(posedge clock);
            $display("Time=%0t: Multiplicando... Status=%b, Data=%h, Pos=%h, Segments=%h", $time, status, data, position, segments);
        end
        $display("Time=%0t: calculadora DONE. Result=%d (0x%h), Status=%b", $time, result, result, status);
        repeat (33) @(posedge clock);
        $display("Time=%0t: Multiplicacao - Conversao BCD Finalizada. Status=%b, Result=%d (0x%h)", $time, status, result, result);
        $display("Time=%0t: Segments=%h (Deve mostrar 56)", $time, segments);

        cmd = 4'b1111; @(posedge clock); $display("Time=%0t: Cmd=%h (CLR), Status=%b", $time, cmd, status);
        @(posedge clock); $display("Time=%0t: Apos Clear - Status=%b, Segments=%h", $time, status, segments);


        // ERRO (Mais de 8 digitos para Op_A)
        $display("--- Test Case: ERRO (Overflow de Digitos) ---");
        cmd = 4'd1; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd2; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd3; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd4; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd5; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd6; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd7; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd8; @(posedge clock); $display("Time=%0t: Cmd=%h (%d), Status=%b, Data=%h, Pos=%h, Segments=%h", $time, cmd, cmd, status, data, position, segments);
        cmd = 4'd9; @(posedge clock);
        $display("Time=%0t: Cmd=%h (%d), ENTRADA DE 9o DIGITO...", $time, cmd, cmd);
        @(posedge clock);
        $display("Time=%0t: Apos 9o Digito - Status=%b (Esperado ERRO = 2'b10)", $time, status);
        @(posedge clock);
        $display("Time=%0t: Status=%b, Result=%d (0x%h), Segments=%h (Deve mostrar ERRO)", $time, status, result, result, segments);


        cmd = 4'b1111; @(posedge clock); $display("Time=%0t: Cmd=%h (CLR) em ERRO, Status=%b", $time, cmd, status);
        @(posedge clock);
        $display("Time=%0t: Apos Clear em ERRO - Status=%b, Segments=%h", $time, status, segments);


        # (CLK_PERIOD * 20);
        $finish;
    end

endmodule