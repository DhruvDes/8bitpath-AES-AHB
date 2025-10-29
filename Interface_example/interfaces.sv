interface design_v;
  
parameter tsetup = 1;
parameter thold = 1;


bit clk;
bit rst;
bit [3:0]adder_example_a_in;
bit [3:0]adder_example_b_in;
logic [3:0]adder_example_out;
  
bit [127:0] zipher, plain; 
  

// Dictates the direction od data form the perspective of the Tb to the design 
clocking adder_example_cb @(posedge clk);
output adder_example_a_in, adder_example_b_in, clk, rst;
input adder_example_out;
endclocking

// put the signals form the designs perspective
// continiue on the example adder to see how to use it
modport example_adder(
input adder_example_a_in, adder_example_b_in,clk, rst,
output adder_example_out
);
  

  modport aes_machine(
  input plain,
  output zipher
  ); 

  
endinterface 



// module aes (design_v.aes_machine aes_pins);

  
//   assign aes_pins.zipher = aes_pins.plain;

// endmodule



// module aes (input [127:0] plain, output [127:0] zipher );

//   assign zipher = plain;

// endmodule



