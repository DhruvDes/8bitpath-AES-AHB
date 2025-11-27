//--------------------------------------------------
// FILE NAME: misr.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : misr
//--------------------------------------------------
//PURPOSE : used for bist operation
//--------------------------------------------------

module misr #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'hB8,
    parameter logic [WIDTH-1:0] SEED = 8'h00
)(
    clk,
    rst,
    enable,
    data_in,
    signal
);

    input  logic clk;
    input  logic rst;
    input  logic enable;
    input  logic [WIDTH-1:0] data_in;
    output logic [WIDTH-1:0] signal;
    
    logic feedback;
    logic [4:0] start_count;   // enough bits to count to 17
    logic start_phase_done;

    assign feedback = ^(signal & TAPS);
    assign start_phase_done = (start_count >= 5'd17);

    always_ff @(posedge clk) begin
        if (rst) begin
            signal <= SEED;
            start_count <= 0;
        end else if (enable) begin
            // count first 17 cycles, then start updating
            if (!start_phase_done)
                start_count <= start_count + 1'b1;
            else
                signal <= ({signal[WIDTH-2:0], feedback}) ^ data_in;
        end
    end
endmodule
