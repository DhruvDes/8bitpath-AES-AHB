`timescale 1ns/1ps

module mixcolumns_tb;

    logic [127:0] state_in;
    logic [127:0] state_out;

    // DUT
    mixcolumns dut (
        .state_in (state_in),
        .state_out(state_out)
    );

    // Task to apply and display results
    task run_test(input [127:0] din);
        begin
            state_in = din;
            #1;
            $display("IN : %032h", din);
            $display("OUT: %032h", state_out);
            $display("----------------------------");
        end
    endtask

    initial begin
        $display("\n======== AES MixColumns Testbench ========");

        // Test Vector 1 (example)
        run_test(128'hd4_bf_5d_30_e0_b4_52_ae_b8_41_11_f1_1e_27_98_e5);
        // Expected: 04_66_81_e5_e0_cb_19_9a_48_f8_d3_7a_28_06_26_4c
        // Verify with software AES

        // Test Vector 2
        run_test(128'h00_11_22_33_44_55_66_77_88_99_aa_bb_cc_dd_ee_ff);

        // Test Vector 3 (identity-like)
        run_test(128'h01010101010101010101010101010101);

        $display("======== Test Complete ========");
        $finish;
    end

endmodule
