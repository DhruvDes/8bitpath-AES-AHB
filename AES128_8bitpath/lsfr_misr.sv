module lfsr #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'b0110_0011, 
    parameter logic [WIDTH-1:0] SEED = 8'h01
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    output logic [WIDTH-1:0] q
);

    logic feedback;
    logic [3:0] count; 

    // XOR-reduction of selected tap bits
    assign feedback = ^(q & TAPS);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= SEED;
            count <= 0;
        end 
        else if (en) begin
            q <= { q[WIDTH-2:0], feedback };
            count <= count + 1;
            if (count == 15)
                q <= q; // no-op, but logically redundant
        end
    end

endmodule


// 8-bit MISR (Fibonacci style) using primitive poly x^8 + x^6 + x^5 + x^4 + 1 (taps=0xB8)
module misr #(
    parameter int WIDTH = 8,
    // Use a *different* primitive from your stimulus LFSRs to reduce correlation.
    parameter logic [WIDTH-1:0] TAPS = 8'hB8,  // 1011_1000
    parameter logic [WIDTH-1:0] SEED = 8'h00   // typical to start at 0
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
  input  logic [WIDTH-1:0] data_in,   // DUT outputs (8-bit)
    output logic [WIDTH-1:0] sig        // running signature
);
    logic feedback;
    // parity (XOR-reduction) of tapped bits = feedback bit
    assign feedback = ^(sig & TAPS);

    always_ff @(posedge clk) begin
        if (rst)
            sig <= SEED;
        else if (en)
            // shift + XOR in parallel data (MISR behavior)
            sig <= ({sig[WIDTH-2:0], feedback}) ^ data_in;
    end
endmodule