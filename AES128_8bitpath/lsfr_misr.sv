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


module misr #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'hB8,
    parameter logic [WIDTH-1:0] SEED = 8'h00
)(
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] sig
);
    logic feedback;
    logic [4:0] start_cnt;   // enough bits to count to 17
    logic start_phase_done;

    assign feedback = ^(sig & TAPS);
    assign start_phase_done = (start_cnt >= 5'd17);

    always_ff @(posedge clk) begin
        if (rst) begin
            sig <= SEED;
            start_cnt <= 0;
        end else if (en) begin
            // count first 17 cycles, then start updating
            if (!start_phase_done)
                start_cnt <= start_cnt + 1'b1;
            else
                sig <= ({sig[WIDTH-2:0], feedback}) ^ data_in;
        end
    end
endmodule
