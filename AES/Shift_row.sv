module AES_shiftrows (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // Byte aliasing for clarity
    // AES state (4x4 matrix): column-major order
    wire [7:0] s0  = state_in[127:120];
    wire [7:0] s1  = state_in[119:112];
    wire [7:0] s2  = state_in[111:104];
    wire [7:0] s3  = state_in[103:96];
    wire [7:0] s4  = state_in[95:88];
    wire [7:0] s5  = state_in[87:80];
    wire [7:0] s6  = state_in[79:72];
    wire [7:0] s7  = state_in[71:64];
    wire [7:0] s8  = state_in[63:56];
    wire [7:0] s9  = state_in[55:48];
    wire [7:0] s10 = state_in[47:40];
    wire [7:0] s11 = state_in[39:32];
    wire [7:0] s12 = state_in[31:24];
    wire [7:0] s13 = state_in[23:16];
    wire [7:0] s14 = state_in[15:8];
    wire [7:0] s15 = state_in[7:0];

    assign state_out = {
        // Row 0 (no shift)
        s0,  s5,  s10, s15,
        // Row 1 (shift left by 1)
        s4,  s9,  s14, s3,
        // Row 2 (shift left by 2)
        s8,  s13, s2,  s7,
        // Row 3 (shift left by 3)
        s12, s1,  s6,  s11
    };

endmodule
