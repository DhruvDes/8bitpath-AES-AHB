`timescale 1ns/1ps

module tb_AES_shiftrows;

    // DUT signals
    logic [127:0] state_in;
    logic [127:0] state_out;

    // Instantiate the Device Under Test (DUT)
    AES_shiftrows dut (
        .state_in(state_in),
        .state_out(state_out)
    );

    initial begin
        $display("===========================================");
        $display(" AES ShiftRows Transformation Testbench ");
        $display("===========================================");

        // Example AES 128-bit input (column-major order)
        // Standard AES test vector (from FIPS-197)
        state_in = 128'h00112233445566778899aabbccddeeff;

        #5; // Wait for combinational logic to settle

        $display("Input State  : %032h", state_in);
        $display("Output State : %032h", state_out);

        // Expected output (after ShiftRows step)
        // For input 00112233445566778899aabbccddeeff,
        // AES ShiftRows gives: 00112233445566778899aabbccddeeff → 0055aaFF... (depends on order)
        
        $display("===========================================");
        $finish;
    end

endmodule