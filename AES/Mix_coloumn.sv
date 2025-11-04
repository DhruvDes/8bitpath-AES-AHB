// 1 coloumn 

module mixcolumn (
    input  logic [31:0] col_in,     // input column: {s0, s1, s2, s3}
    output logic [31:0] col_out     // output mixed column
);

    logic [7:0] s0, s1, s2, s3;
    logic [7:0] o0, o1, o2, o3;

    // Galois field multiply by 2
    function automatic [7:0] xtime(input [7:0] b);
        xtime = (b[7] ? (b << 1) ^ 8'h1B : (b << 1));
    endfunction

    // Galois field multiply
    function automatic [7:0] gm2(input [7:0] b);
        gm2 = xtime(b);
    endfunction

    function automatic [7:0] gm3(input [7:0] b);
        gm3 = gm2(b) ^ b;
    endfunction

    always_comb begin
        {s0, s1, s2, s3} = col_in;

        o0 = gm2(s0) ^ gm3(s1) ^ s2      ^ s3;
        o1 = s0      ^ gm2(s1) ^ gm3(s2) ^ s3;
        o2 = s0      ^ s1      ^ gm2(s2) ^ gm3(s3);
        o3 = gm3(s0) ^ s1      ^ s2      ^ gm2(s3);

        col_out = {o0, o1, o2, o3};
    end

endmodule


//For all 128 bits

module mixcolumns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    logic [31:0] col_in [3:0];
    logic [31:0] col_out[3:0];

    genvar i;

    // Split into 4 columns
    generate
        for (i = 0; i < 4; i++) begin
            assign col_in[i] = state_in[127-(i*32) -: 32];
            mixcolumn m (
                .col_in (col_in[i]),
                .col_out(col_out[i])
            );
            assign state_out[127-(i*32) -: 32] = col_out[i];
        end
    endgenerate

endmodule
