module example_adder(designs.example_adder pins);

always_ff @(posedge pins.clk) begin
    if(pins.rst == 1) pins.adder_example_out <= 0;
    else pins.adder_example_out <= pins.adder_example_a_in + pins.adder_example_b_in; 
end
endmodule

// with this method we can cut down on Variable errors debug in the long run
// And the whole team can have a cohesive code
