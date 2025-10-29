// Code your design here
`include "if.sv"



  module example_adder(design_v.example_adder pins);

always_ff @(posedge pins.clk) begin
    if(pins.rst == 1) pins.adder_example_out <= 0;
    else pins.adder_example_out <= pins.adder_example_a_in + pins.adder_example_b_in; 
end
endmodule
