//--------------------------------------------------
//File name: aes_inv_sbox_rom.sv
//Author : chirranjeavi Moorthi
//Author : Email:cm685@nyu.edu
//Department: Computer Engineering 
//--------------------------------------------------
//Release History
//Verison 1
//Purpose : AES INVERSE ROM SBOX 
//This file has a module for AES inverse Sbox using case statement which is synthesizable 
//--------------------------------------------------

module key_exp_rot_word (
    word1,
    word_out
);

input logic [31:0] word1;
input logic [31:0] word_out;


assign word_out = { word1[23:0], word1[31:24] };

endmodule
   

