module aes128_core (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,              // start encryption
    input  logic [127:0] plaintext,
    input  logic [127:0] cipher_key,
    output logic [127:0] ciphertext,
    output logic         done);

//internal signals    
    
    logic [127:0]  S_box_out;
    logic [3:0]    round;
    logic [127:0]  state, next_state;
    logic [127:0]  round_key;
    logic [127:0]  next_round_key;
    logic          busy;


//instantiating the modules

    logic [127:0] sub_bytes_out;
    logic [127:0] shift_rows_out;
    logic [127:0] mix_columns_out;
    logic [127:0] add_round_out;

    aes_sbox SBOX (
        .sboxw (plaintext),
        .new_sboxw (sub_bytes_out)
    );

    AES_shift_rows SHIFT (
        .state_in  (sub_bytes_out),
        .state_out (shift_rows_out)
    );

    mixcolumns MIXCOLOUMNS (
        .state_in  (shift_rows_out),
        .state_out (mix_columns_out)
    );

    add_round_key  (
        .state_in  ( (round == 4'd10) ? shift_rows_out : mix_columns_out ),
        .round_key (cipher_key),
        .state_out (add_round_out)
    );

//active low rest 


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            round   <= 4'd0;
            busy    <= 1'b0;
            state   <= '0;
            round_key <= '0;
            done    <= 1'b0;

        end else begin

            if (start && !busy) begin
                // Initial AddRoundKey
                state     <= plaintext ^ cipher_key;
                round_key <= cipher_key;
                busy      <= 1'b1;
                round     <= 4'd1;
                done      <= 1'b0;

            end 
            else if (busy) begin

                state     <= add_round_out;
                round_key <= next_round_key;

                if (round == 4'd10) begin
                    // Final round complete
                    ciphertext <= add_round_out;
                    busy      <= 1'b0;
                    done      <= 1'b1;
                end 
                else begin
                    round <= round + 4'd1;
                end
            end
        end
    end

endmodule