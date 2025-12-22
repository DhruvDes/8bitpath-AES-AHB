module key_expansion(input [7:0]key_in,  
                     output [7:0] rk_delayed_out, 
                     input [3:0] round_cnt, 
                     output [7:0] rk_last_out, 
                     input clk, 
                     input input_sel, 
                     sbox_sel, 
                     last_out_sel, 
                     bit_out_sel, 
                     input [7:0] rcon_en,
                     input rst);
  

    logic [7:0] r15, r14, r13, r12, r11, r10, r9, r8, r7, r6, r5, r4, r3, r2, r1, r0, r_redun;
    logic [7:0] rcon_sbox_o, sbox_o, rcon_o, sbox_in, mux_in_o, mux_bit_o, rcon_num;
    
    function [7:0] rcon;
      input [3:0] x;
        casex (x)
          4'b0000: rcon = 8'h01;
          4'b0001: rcon = 8'h02;
          4'b0010: rcon = 8'h04;
          4'b0011: rcon = 8'h08;
          4'b0100: rcon = 8'h10;
          4'b0101: rcon = 8'h20;
          4'b0110: rcon = 8'h40;
          4'b0111: rcon = 8'h80;
          4'b1000: rcon = 8'h1b;
          4'b1001: rcon = 8'h36;
          default: rcon = 8'h01;
          
//             casex (x)
//           4'b0000: rcon = 8'h01;
//           4'b0001: rcon = 8'h02;
//           4'b0010: rcon = 8'h04;
//           4'b0011: rcon = 8'h08;
//           4'b0100: rcon = 8'h20;
//           4'b0101: rcon = 8'h00;
//           4'b0110: rcon = 8'h30;
//           4'b0111: rcon = 8'h00;
//           4'b1000: rcon = 8'h1b;
//           4'b1001: rcon = 8'h36;
//           default: rcon = 8'h01;
//         endcase
        endcase
    endfunction

    assign rcon_num = rcon(round_cnt);


    assign rcon_sbox_o = sbox_o ^ rcon_o;
    assign rcon_o = rcon_en & rcon_num;
    assign rk_delayed_out = r12;
    
// module mux2_1(
//   input [7:0] In1, In2,
//   output [7:0] Out,
//               input sel);
  	mux2_1 mux_in (.In1(rk_last_out), 
                   .In2(key_in), 
                   .Out(mux_in_o), 
                   .sel(input_sel));
    mux2_1 mux_sbox (.In1(r13), 
                     .In2(r_redun), 
                     .Out(sbox_in), 
                     .sel(sbox_sel));
  
    mux2_1 mux_bit (.In1((r4 ^ rk_last_out)),
                    .In2(r4), .Out(mux_bit_o),
                    .sel(bit_out_sel)); 
     mux2_1 mux_last_out (.In1(r0), 
                          .In2( r0 ^ rcon_sbox_o),
                          .Out(rk_last_out),
                          .sel(last_out_sel));

  bSbox sboxcan (.A(sbox_in),
                 .Q(sbox_o));




//     logic [7:0] r_stageA, r_stageB, r_stageC;
//     always @(posedge clk) begin
//         if (rst) begin
//             r_stageA <= '0;
//             r_stageB <= '0;
//             r_stageC <= '0;
//         end else begin
//             r_stageA <= key_in;
//             r_stageB <= r_stageA ^ r_stageC;
//             r_stageC <= r_stageB;
//         end
//     end
//     //
//     // Early function

//     function automatic [7:0] rcon_old(input [3:0] idx);
//         case (idx)
//             4'h0: rcon_old = 8'h01;
//             4'h1: rcon_old = 8'h02;
//             default: rcon_old = 8'h1F;
//         endcase
//     endfunction

  
    always @ (posedge clk)
    begin
      if (rst) begin 
            
        r15 <= 'h0;
        r14 <= 'h0;
        r13 <= 'h0;
        r12 <= 'h0;
        r11 <= 'h0;
        r10 <= 'h0;
        r9 <=  'h0;
        r8 <=  'h0;
        r7 <=  'h0;
        r6 <=  'h0;
        r5 <=  'h0;
        r4 <=  'h0;
        r3 <=  'h0;
        r2 <=  'h0;
        r1 <=  'h0;
        r0 <=  'h0;
   
      
      
      
      
      end else begin 
      
      
        r15 <= mux_in_o;
        r14 <= r15;
        r13 <= r14;
        r12 <= r13;
        r11 <= r12;
        r10 <= r11;
        r9 <= r10;
        r8 <= r9;
        r7 <= r8;
        r6 <= r7;
        r5 <= r6;
        r4 <= r5;
        r3 <= mux_bit_o;
        r2 <= r3;
        r1 <= r2;
        r0 <= r1;
        

      end
    end
    
    always @ (posedge clk)
    begin
        if (rcon_en == 8'hff)
        begin
            r_redun <= r12;
        end
    end 
endmodule
