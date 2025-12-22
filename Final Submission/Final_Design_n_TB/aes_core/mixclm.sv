//* GPT CODE IGNORE *//
// module inv_mixcolumn_8 (din, en, dout0, dout1, dout2, dout3, clk);
//     input  [7:0] din;
//     input  [7:0] en;
//     output [7:0] dout0, dout1, dout2, dout3;
//     input  clk;

//     logic  [7:0] reg0, reg1, reg2, reg3;
//     logic [7:0] mul2, mul4, mul8;
//     logic [7:0] mul9, mulB, mulD, mulE;

//     // Multiply by 2 in GF(2^8)
//     assign mul2 = {din[6:4], din[3] ^ din[7], din[2] ^ din[7], din[1], din[0] ^ din[7], din[7]};
//     // Multiply by 4 = (×2 of ×2)
//     assign mul4 = {mul2[6:4], mul2[3] ^ mul2[7], mul2[2] ^ mul2[7], mul2[1], mul2[0] ^ mul2[7], mul2[7]};
//     // Multiply by 8 = (×2 of ×4)
//     assign mul8 = {mul4[6:4], mul4[3] ^ mul4[7], mul4[2] ^ mul4[7], mul4[1], mul4[0] ^ mul4[7], mul4[7]};

//     // Compose inverse multipliers
//     assign mul9 = mul8 ^ din;                 // ×9 = ×8 ⊕ ×1
//     assign mulB = mul8 ^ mul2 ^ din;          // ×B = ×8 ⊕ ×2 ⊕ ×1
//     assign mulD = mul8 ^ mul4 ^ din;          // ×D = ×8 ⊕ ×4 ⊕ ×1
//     assign mulE = mul8 ^ mul4 ^ mul2;         // ×E = ×8 ⊕ ×4 ⊕ ×2

//     always @(posedge clk) begin
//         reg0 <= mulE ^ (reg1 & en);  // corresponds to 0x0E * d0 ⊕ ...
//         reg1 <= mulB ^ (reg2 & en);  // corresponds to 0x0B * d1 ⊕ ...
//         reg2 <= mulD ^ (reg3 & en);  // corresponds to 0x0D * d2 ⊕ ...
//         reg3 <= mul9 ^ (reg0 & en);  // corresponds to 0x09 * d3 ⊕ ...
//     end

//     assign dout0 = reg0;
//     assign dout1 = reg1;
//     assign dout2 = reg2;
//     assign dout3 = reg3;
// endmodule


module mixcolumn_8 (input clk, rst, 
                    input[7:0] din, en, 
                    output [7:0] dout0, dout1, dout2, dout3);

    
    logic [7:0] reg0, reg1, reg2, reg3;
    logic [7:0] din02, din03;
    
    assign din02 = {din[6:4], din[3] ^ din[7], din[2] ^ din[7] , din[1], din[0] ^ din[7], din[7]};
    assign din03 = {din[7] ^ din[6], din[6] ^ din[5], din[5] ^ din[4], din[4] ^ din[3] ^ din[7], din[3] ^ din[2] ^ din[7] , din[2] ^ din[1], din[1] ^ din[0] ^ din[7], din[0] ^ din[7]};

    always @ (posedge clk)
      if (rst) begin
        
        reg0 <= 'h0;
        reg1 <= 'h0;
        reg2 <= 'h0;
        reg3 <= 'h0;
        
        
        end else begin
        reg0 <= din ^ (reg1 & en);
        reg1 <= din ^ (reg2 & en);
        reg2 <= din03 ^ (reg3 & en);
        reg3 <= din02 ^ (reg0 & en);
    end

    assign dout0 = reg0;
    assign dout1 = reg1;
    assign dout2 = reg2;
    assign dout3 = reg3;
endmodule


