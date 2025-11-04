`timescale 1ns/1ps

module add_round_key_tb;

    logic [127:0] state_in;
    logic [127:0] round_key;
    logic [127:0] state_out;

    add_round_key dut (
        .state_in(state_in),
        .round_key(round_key),
        .state_out(state_out)
    );

    initial begin
        $display("\n=== AES AddRoundKey Test ===");

        // Example input + key
        state_in  = 128'h00112233445566778899aabbccddeeff;
        round_key = 128'h000102030405060708090a0b0c0d0e0f;
        #1;

        $display("state_in : %032h", state_in);
        $display("roundkey : %032h", round_key);
        $display("state_out: %032h", state_out);

        // Expected: XOR result
        // 00112233 ^ 00010203 = 00102030
        // => full result: 0010203340506277889180b0c0d3d1f0
        $finish;
    end

endmodule
