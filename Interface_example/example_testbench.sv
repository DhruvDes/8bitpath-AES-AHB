module tb();
  design_v dif();  
  
  
  example_adder dut(.pins(dif)); 


  
  initial begin
    dif.clk = 0;
    dif.rst = 1;
    #10 dif.rst = 0;
  end


  always #5 dif.clk = ~dif.clk;

  initial begin
    repeat (10) begin
      @(negedge dif.clk);
      dif.adder_example_a_in <= $urandom;
      dif.adder_example_b_in <= $urandom;
    end
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end

endmodule