//--------------------------------------------------
//File name: aes_key_expround_constant_rom.sv
//Author : chirranjeavi Moorthi
//Author : Email:cm685@nyu.edu
//Department: Computer Engineering 
//--------------------------------------------------
//Release History
//Verison 1
//Purpose : AES INVERSE ROM SBOX 
//Rom for round key creation using cyphier key 
//--------------------------------------------------

module aes_key_exp_round_contant_rom (
      round_number,
      rcon
);


input  logic [3:0] round_number; // 4-bit input
output logic [31:0] rcon; // 32-bit output

always_comb 
    begin
        unique case (round_number)
            4'h1: rcon = 32'h01000000;
            4'h2: rcon = 32'h02000000;
            4'h3: rcon = 32'h04000000;
            4'h4: rcon = 32'h08000000;
            4'h5: rcon = 32'h10000000;
            4'h6: rcon = 32'h20000000;
            4'h7: rcon = 32'h40000000;
            4'h8: rcon = 32'h80000000;
            4'h9: rcon = 32'h1B000000;
            4'hA: rcon = 32'h36000000;
            default: rcon = 32'h00000000;
        endcase
    end 
endmodule