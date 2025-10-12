interface design;
parameter tsetup = 1;
parameter thold = 1;


bit clk;
bit rst;
bit [3:0]adder_example_a_in;
bit [3:0]adder_example_b_in;
logic [3:0]adder_example_out;

// Dictates the direction od data form the perspective of the Tb to the design 
clocking adder_example_cb @(posedge clk);
output adder_example_a_in, adder_example_b_in;
input adder_example_out;
endclocking

// put the signals form the designs perspective
// continiue on the example adder to see how to use it
modport example_adder(
input adder_example_a_in, adder_example_b_in,clk, rst,
output adder_example_out
)

endinterface 