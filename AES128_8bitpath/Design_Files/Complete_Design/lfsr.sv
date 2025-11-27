//--------------------------------------------------
// FILE NAME: lfsr.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : lfsr
//--------------------------------------------------
//PURPOSE : used for bist operation
//--------------------------------------------------

module lfsr #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'b0110_0011, 
    parameter logic [WIDTH-1:0] SEED = 8'h01
)(
    clk,
    rst,
    enable,
    q
);


    input  logic clk;
    input  logic rst;
    input  logic enable;
    output logic [WIDTH-1:0] q;

    logic feedback;
    logic [3:0] count; 

    // XOR-reduction of selected tap bits
    assign feedback = ^(q & TAPS);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= SEED;
            count <= 0;
        end 
        else if (enable) begin
            q <= { q[WIDTH-2:0], feedback };
            count <= count + 1;
            if (count == 15)
                q <= q; // no-op, but logically redundant
        end
    end

endmodule


