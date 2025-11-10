//--------------------------------------------------
//File name: aes_shift_row.sv
//Author : chirranjeavi Moorthi
//Author : Email:cm685@nyu.edu
//Department: Computer Engineering 
//--------------------------------------------------
//Release History
//Verison 1
//Purpose : AES INVERSE ROM SBOX 
//This file has a module for AES inverse Sbox using case statement which is synthesizable 
//--------------------------------------------------


module aes_shiftrows (
     state_in,    // Input state
     state_out    // ShiftRows result
);

input  logic [127:0] state_in;     // 128-bit input 
output logic [127:0] state_out;    // 128-bit output 
   
    wire [7:0] s [0:15];  //before shift
    wire [7:0] so[0:15];  // after shift

    // Break input into bytes
    assign {
        s[15], s[14], s[13], s[12],
        s[11], s[10], s[9],  s[8],
        s[7],  s[6],  s[5],  s[4],
        s[3],  s[2],  s[1],  s[0]
    } = state_in;

    // ShiftRows transformation
    
    assign so[0]  = s[0];
    assign so[1]  = s[5];
    assign so[2]  = s[10];
    assign so[3]  = s[15];

    assign so[4]  = s[4];
    assign so[5]  = s[9];
    assign so[6]  = s[14];
    assign so[7]  = s[3];

    assign so[8]  = s[8];
    assign so[9]  = s[13];
    assign so[10] = s[2];
    assign so[11] = s[7];

    assign so[12] = s[12];
    assign so[13] = s[1];
    assign so[14] = s[6];
    assign so[15] = s[11];

// combaining outputs after shifting

    assign state_out = {
        so[15], so[14], so[13], so[12],
        so[11], so[10], so[9],  so[8],
        so[7],  so[6],  so[5],  so[4],
        so[3],  so[2],  so[1],  so[0]
    };

endmodule
