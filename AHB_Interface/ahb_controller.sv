package ahb_cpu_reg_map_pkg;
  typedef enum logic [5:0] {
      // Control / status region
      REG_CTRL0  = 6'h00,   // 0x00
      REG_CTRL1  = 6'h01,   // 0x04
      REG_STAT0  = 6'h02,   // 0x08
      REG_STAT1  = 6'h03,   // 0x0C

      // Key registers 
      REG_KEY0   = 6'h04,   // 0x10
      REG_KEY1   = 6'h05,   // 0x14
      REG_KEY2   = 6'h06,   // 0x18
      REG_KEY3   = 6'h07,   // 0x1C

      // Plaintext / data registers 
      REG_PT0    = 6'h08,   // 0x20
      REG_PT1    = 6'h09,   // 0x24
      REG_PT2    = 6'h0A,   // 0x28
      REG_PT3    = 6'h0B    // 0x2C
    
    // Ciphertext registers (128 bits total)
      REG_CT0    = 6'h0C,   // 0x30
      REG_CT1    = 6'h0D,   // 0x34
      REG_CT2    = 6'h0E,   // 0x38
      REG_CT3    = 6'h0F    // 0x3C
  } aes_reg_addr_e;

endpackage

module ahb_controller (
    //AHB Interface
  	input  logic        HCLK,
    input  logic        HRESETn,

    input  logic        HSEL,
    input  logic [31:0] HADDR,
    input  logic [1:0]  HTRANS,
    input  logic        HWRITE,
    input  logic [2:0]  HSIZE,
    input  logic [31:0] HWDATA,
    input  logic        HREADY,

    output logic [31:0] HRDATA,
    output logic        HREADYOUT,
  	output logic        HRESP,
  
  	output logic        aes_start,
  	input  logic        aes_busy 
);
  
  import ahb_cpu_reg_map_pkg::*;
  
  logic [127:0] key_reg;
  logic [127:0] pt_reg;
  logic [127:0] ct_reg;
  
  logic [31:0]  control_reg;
  logic         start_req; 
  logic         key_written;
  logic         pt_written;
  
  wire [5:0] addr_word = HADDR[7:2];
  wire trans_active = HSEL && HREADY && HTRANS[1];
  wire wr_en = trans_active && HWRITE;
  wire       rd_en        = trans_active && !HWRITE;
  
  assign HREADYOUT = 1'b1;
  assign HRESP     = 1'b0;
  
  assign aes_start = start_req && key_written && pt_written && !aes_busy;
  logic        aes_start;
    logic        aes_busy;
    logic        aes_done;
  
    logic [127:0] ct_block_wire;

    aes_block_wrapper u_aes_block (
        .clk        (HCLK),
        .rst_n      (HRESETn),
        .aes_start  (aes_start),
        .key_block  (key_reg),
        .pt_block   (pt_reg),
        .ct_block   (ct_block_wire),
        .aes_busy   (aes_busy),
        .aes_done   (aes_done),
        .core_done_dbg (),
        .core_dvld_dbg ()
    );

    // Latch ciphertext into ct_reg when AES completes a block
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            ct_reg <= '0;
        end else if (aes_done) begin
            ct_reg <= ct_block_wire;
        end
    end

  
    always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
      key_reg     <= '0;
      pt_reg      <= '0;
      control_reg <= '0;
      start_req   <= 1'b0;
      key_written <= 1'b0;
      pt_written  <= 1'b0;
    end else begin
      
      if (aes_start) begin
        start_req  <= 1'b0;
        pt_written <= 1'b0;  
		key_written <= 1'b0;
      end

      if (wr_en) begin
        unique case (aes_reg_addr_e'(addr_word))

          // CONTROL register (bit0 = START)
          REG_CTRL0: begin
            control_reg <= HWDATA;
            if (HWDATA[0])          // START bit = 1
              start_req <= 1'b1;    
          end

          // 128-bit KEY (4 words)
          REG_KEY0: key_reg[ 31:  0]  <= HWDATA;
          REG_KEY1: key_reg[ 63: 32]  <= HWDATA;
          REG_KEY2: key_reg[ 95: 64]  <= HWDATA;
          REG_KEY3: begin
            			key_reg[127: 96] <= HWDATA;
            			key_written      <= 1'b1; 
          			end

          // 128-bit plaintext (4 words)
          REG_PT0: pt_reg[ 31:  0]    <= HWDATA;
          REG_PT1: pt_reg[ 63: 32]    <= HWDATA;
          REG_PT2: pt_reg[ 95: 64]    <= HWDATA;
          REG_PT3: begin
            			pt_reg[127: 96] <= HWDATA;
            			pt_written      <= 1'b1;   
          			end

          default: ;
        endcase
      end
    end
  end

      always_comb begin
        HRDATA = 32'h0;

        if (!HWRITE && trans_active) begin
            unique case (aes_reg_addr_e'(addr_word))
                // Example: use STAT0 for DONE/BUSY
                REG_STAT0: HRDATA = {30'h0, aes_busy, aes_done};
                REG_CT0:    HRDATA = ct_reg[ 31:  0];
                REG_CT1:    HRDATA = ct_reg[ 63: 32];
                REG_CT2:    HRDATA = ct_reg[ 95: 64];
                REG_CT3:    HRDATA = ct_reg[127: 96];

                default: ;
            endcase
        end
    end

  
  
  
endmodule
