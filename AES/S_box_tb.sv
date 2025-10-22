// tb_aes_sbox.sv
`timescale 1ns/1ps

module S_box_tb;

    // Testbench signals
    logic [7:0] in;
    logic [7:0] out;

    // Instantiate DUT
    S_box dut (
        .in(in),
        .out(out)
    );

    // Expected output values for specific test addresses
    logic [7:0] expected [0:3];

    initial begin
        // Known AES S-box values
        expected[0] = 8'h63; // S-box[0x00]
        expected[1] = 8'h7C; // S-box[0x01]
        expected[2] = 8'h77; // S-box[0x02]
        expected[3] = 8'h7B; // S-box[0x03]

        $display("==== AES S-BOX ROM TEST START ====");

        // Small delay for ROM to initialize
        #5;

        // Run a few address checks
        for (int i = 0; i < 4; i++) begin
            addr = i[7:0];
            #5;
            if (data_out === expected[i])
                $display("PASS: Addr=%02h -> Data=%02h", addr, data_out);
            else
                $display("FAIL: Addr=%02h -> Data=%02h (Expected=%02h)", addr, data_out, expected[i]);
        end

        // Optional random test (unverified)
        in = 8'h10; #5;
        $display("INFO: Addr=%02h -> Data=%02h", in, out);

        $display("==== AES S-BOX ROM TEST COMPLETE ====");
        $finish;
    end

endmodule
