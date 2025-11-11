module aes_block_wrapper (
    input  logic         clk,
    input  logic         rst_n,       // active-low, from SoC

    // Block-level interface (to AHB controller)
    input  logic         aes_start,   // 1-cycle pulse from AHB side
    input  logic [127:0] key_block,   // key_reg  from AHB
    input  logic [127:0] pt_block,    // pt_reg   from AHB
    output logic [127:0] ct_block,    // ciphertext block
    output logic         aes_busy,    // 1 while AES is working
    output logic         aes_done,    // 1-cycle pulse at end of block

    // Optional: expose core-level status if you want
    output logic         core_done_dbg,
    output logic         core_dvld_dbg
);

    // Local connection to 8-bit AES core
    logic        core_rst;      // active-high, synchronous
    logic [7:0]  core_key_in;
    logic [7:0]  core_d_in;
    logic [7:0]  core_d_out;
    logic        core_d_vld;
    logic        core_DONE;

    assign core_done_dbg = core_DONE;
    assign core_dvld_dbg = core_d_vld;

    aes_8_bit u_aes8 (
        .rst    (core_rst),
        .clk    (clk),
        .key_in (core_key_in),
        .d_in   (core_d_in),
        .d_out  (core_d_out),
        .d_vld  (core_d_vld),
        .DONE   (core_DONE)
    );

    // Wrapper FSM: serialize 128-bit in, collect 128-bit out
    typedef enum logic [2:0] {
        S_IDLE,
        S_RESET_CORE,
        S_LOAD_IN,
        S_WAIT_OUT,
        S_COLLECT_OUT
    } state_e;

    state_e      state, state_n;

    logic [3:0]  in_idx;        // 0..15: which input byte we’re sending
    logic [3:0]  out_idx;       // 0..15: which output byte we’re collecting
    logic [127:0] ct_block_r;

    assign ct_block = ct_block_r;

    // Combinational next-state and outputs that depend on state
    always_comb begin
        // Defaults
        state_n   = state;
        core_rst  = 1'b0;
        aes_busy  = 1'b0;
        aes_done  = 1'b0;

        // Keep inputs driven; indices come from regs
        core_key_in = key_block[8*in_idx +: 8];
        core_d_in   = pt_block [8*in_idx +: 8];

        unique case (state)
            S_IDLE: begin
                aes_busy = 1'b0;
                // Wait for start pulse from AHB side
                if (aes_start) begin
                    state_n = S_RESET_CORE;
                end
            end

            S_RESET_CORE: begin
                // Synchronous reset to core: put it into 'load' state
                aes_busy = 1'b1;
                core_rst = 1'b1;       // one cycle of reset
                // Next cycle, start loading bytes
                state_n  = S_LOAD_IN;
            end

            S_LOAD_IN: begin
                aes_busy = 1'b1;
                // We stream 16 bytes, in_idx 0..15
                if (in_idx == 4'd15) begin
                    state_n = S_WAIT_OUT;
                end
            end

            S_WAIT_OUT: begin
                aes_busy = 1'b1;
                // AES core is now running rounds internally.
                // Wait until it starts asserting d_vld.
                if (core_d_vld) begin
                    state_n = S_COLLECT_OUT;
                end
            end

            S_COLLECT_OUT: begin
                aes_busy = 1'b1;
                // Stay here while we collect 16 bytes
                if (core_DONE) begin
                    // On the cycle DONE goes high we assume last byte captured
                    aes_done = 1'b1;   // 1-cycle pulse to controller
                    state_n  = S_IDLE;
                end
            end

            default: begin
                state_n  = S_IDLE;
            end
        endcase
    end

    // Sequential: indices, ct_block_r, state
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            in_idx      <= 4'd0;
            out_idx     <= 4'd0;
            ct_block_r  <= '0;
        end else begin
            state <= state_n;

            case (state)
                S_IDLE: begin
                    in_idx  <= 4'd0;
                    out_idx <= 4'd0;
                end

                S_RESET_CORE: begin
                    in_idx  <= 4'd0;
                    out_idx <= 4'd0;
                    ct_block_r <= '0;
                end

                S_LOAD_IN: begin
                    // present core_key_in/core_d_in for current in_idx (combinational)
                    // increment index each cycle
                    if (in_idx != 4'd15) begin
                        in_idx <= in_idx + 4'd1;
                    end
                end

                S_WAIT_OUT: begin
                    // nothing to update until d_vld appears
                    out_idx <= 4'd0;
                end

                S_COLLECT_OUT: begin
                    // As long as d_vld is asserted, capture bytes
                    if (core_d_vld && out_idx <= 4'd15) begin
                        ct_block_r[8*out_idx +: 8] <= core_d_out;
                        if (out_idx != 4'd15) begin
                            out_idx <= out_idx + 4'd1;
                        end
                    end
                end

                default: ;
            endcase
        end
    end

endmodule
