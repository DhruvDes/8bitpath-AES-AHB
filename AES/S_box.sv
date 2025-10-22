module S_box (
    input logic [7:0] in,
    output logic [7:0] out
);

    

    logic [7:0] Sbox_data [0:7];

    initial begin
        // Initialize ROM from a hex file (e.g., "rom_init.hex")
        $readmemh("S_box.hex", Sbox_data); 
    end

    assign out = Sbox_data[in];

endmodule