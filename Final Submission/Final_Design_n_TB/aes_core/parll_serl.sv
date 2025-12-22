module parll_serl_conv (input clk, rst, pld, input [7:0] din, output[7:0]dout, input [31:0]pdin);
  

    logic [7:0] reg3, reg2, reg1, reg0;

    logic [7:0] mux1_o, mux2_o, mux3_o;
// module mux2_1(
//   input [7:0] In1, In2,
//   output [7:0] Out,
//               input sel);
  mux2_1 mux0 (.In1(pdin[31:24]), 
               .In2(reg0), 
               .Out(dout),   
               .sel(pld));
               
  mux2_1 mux1 (.In1(pdin[23:16]), 
               .In2(reg1), 
               .Out(mux1_o),
               .sel(pld));
  
               mux2_1 mux2 (.In1(pdin[15: 8]), 
                            .In2(reg2), 
                            .Out(mux2_o),
                            .sel(pld));
  
               mux2_1 mux3 (.In1(pdin[ 7: 0]),
                            .In2(reg3), 
                            .Out(mux3_o),
                            .sel(pld));

    always @ (posedge clk)
      if (rst) begin
        reg3 <='h0;
        reg2 <='h0;
        reg1 <='h0;
        reg0 <='h0;
        
        
        
      end else begin
        reg3 <= din;
        reg2 <= mux3_o;
        reg1 <= mux2_o;
        reg0 <= mux1_o;
    end
endmodule
        
