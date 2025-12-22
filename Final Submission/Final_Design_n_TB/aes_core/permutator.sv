module permutator (input clk, rst, 
                         input [7:0] d_in, 
                         output [7:0] d_out, 
                         input[1:0]c3);

    logic c0, c1, c2;
    logic [7:0] mux0_o, mux1_o, mux2_o;
    logic [7:0] reg12, reg11, reg10, reg9, reg8, reg7, reg6, reg5, reg4, reg3, reg2, reg1;

    assign c0 = ~ (c3[1] | c3[0]);
    assign c1 = ~ (c3[1] | (~ c3[0])); 
    assign c2 = ~ ((~ c3[1]) | c3[0]);

  
// module mux4_1(
//   input [7:0] In1, In2, In3, In4,
//   output [7:0] Out,
//   input [1:0] sel);

  //     mux4_1 chaos_mux (
  //         .In1(str_in),
//         .In2(r9),
//         .In3(r5),
//         .In4(r1),
//         .Out(noodle_out),
//         .sel(che_bits)
//     );

  
  mux4_1 mux_4_1 (.In1(d_in), 
                  .In2(reg9), 
                  .In3(reg5), 
                  .In4(reg1), 
                  .Out(d_out), 
                  .sel(c3));
  
    // module mux2_1(
//   input [7:0] In1, In2,
//   output [7:0] Out,
//               input sel);
  mux2_1 mux0 (.In1(reg1), 
  .In2(d_in), 
  .Out(mux0_o), 
  .sel(c0));
  
  
  mux2_1 mux1 (.In1(reg1),
   .In2(reg9), 
   .Out(mux1_o),
    .sel(c1));
  
  mux2_1 mux2 (.In1(reg1),
   .In2(reg5),
    .Out(mux2_o), 
    .sel(c2));

    always @ (posedge clk)
      if (rst) begin 
      
      
        reg12 <= 'h0;
        reg11 <= 'h0;
        reg10 <= 'h0;
        reg9  <= 'h0;
        reg8  <= 'h0;
        reg7  <= 'h0;
        reg6  <= 'h0;
        reg5  <= 'h0;
        reg4  <= 'h0;
        reg3  <= 'h0;
        reg2  <= 'h0;
        reg1  <= 'h0;
      
      
      
      end else begin
        reg12 <= mux0_o;
        reg11 <= reg12;
        reg10 <= reg11;
        reg9  <= reg10;
        reg8  <= mux1_o;
        reg7  <= reg8;
        reg6  <= reg7;
        reg5  <= reg6;
        reg4  <= mux2_o;
        reg3  <= reg4;
        reg2  <= reg3;
        reg1  <= reg2;
    end
endmodule

// module wobble_shuffle_machine (
//     input          florp_clk, splat_reset,
//     input  [7:0]   noodle_in,
//     output [7:0]   noodle_out,
//     input  [1:0]   cheese_bits
// );


//     logic wow0, wow1, wow2;
//     logic [7:0] blip0, blip1, blip2;
//     logic [7:0] r12, r11, r10, r9, r8, r7, r6, r5, r4, r3, r2, r1;



//     // more mux madness
//     mux2_1 m0 (
//         .In1(r1),
//         .In2(noodle_in),
//         .Out(blip0),
//         .sel(wow0)
//     );

//     mux2_1 m1 (
//         .In1(r1),
//         .In2(r9),
//         .Out(blip1),
//         .sel(wow1)
//     );

//     mux2_1 m2 (
//         .In1(r1),
//         .In2(r5),
//         .Out(blip2),
//         .sel(wow2)
//     );
        
