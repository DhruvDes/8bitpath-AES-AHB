

class ahb_subor extends uvm_driver#(m_a_transaction);
  `uvm_component_utils(ahb_subor)

  function new(string name="ahb_subor", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual ahb_if s_if;

  // 8 input regs (32-bit each) -> 256-bit block (key[0..3] + pt[4..7])
  logic [31:0] in_reg  [0:7];

  // 4 output regs (ciphertext)
  logic [31:0] out_reg [0:3];

  // AES block signals
  logic [127:0] key_reg;
  logic [127:0] pt_reg;
  logic [127:0] ct_reg;

  // Bookkeeping
  int reg_write_cnt;
  bit busy_flag;
  int stall_cnt;

  // Address map (word aligned)
  localparam logic [31:0] IN_BASE_ADDR   = 32'h0000_0010; // 04..20 (8 words)
  localparam logic [31:0] IN_LAST_ADDR   = 32'h0000_002C;
  localparam logic [31:0] OUT_BASE_ADDR  = 32'h0000_0030; // 24..30 (4 words)
  localparam logic [31:0] OUT_LAST_ADDR  = 32'h0000_003C;

  // Number of wait-state cycles while "computing" AES
  localparam int AES_STALL_CYCLES = 4;

  // Latched address-phase information (AHB pipeline)
  logic [31:0] latched_addr;
  bit          latched_write;
  logic [2:0]  latched_size;
  bit          latched_valid;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ahb_if)::get(this,"interface","ahb_vif",s_if))
      `uvm_error(get_type_name(),"No vif")
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Reset state
    reg_write_cnt = 0;
    busy_flag     = 0;
    stall_cnt     = 0;
    key_reg       = '0;
    pt_reg        = '0;
    ct_reg        = '0;
    latched_valid = 0;

    foreach (in_reg[i])  in_reg[i]  = 32'h0;
    foreach (out_reg[i]) out_reg[i] = 32'h0;

    s_if.hresp     <= 0;
    s_if.hrdata    <= 0;
    s_if.hreadyOut <= 1;

    forever begin
      @(posedge s_if.hclk);

      if (!s_if.hrstn) begin
        // Asynchronous reset
        s_if.hresp      <= 0;
        s_if.hrdata     <= 0;
        s_if.hreadyOut  <= 1;

        reg_write_cnt   <= 0;
        busy_flag       <= 0;
        stall_cnt       <= 0;
        key_reg         <= '0;
        pt_reg          <= '0;
        ct_reg          <= '0;

        foreach (in_reg[i])  in_reg[i]  <= 32'h0;
        foreach (out_reg[i]) out_reg[i] <= 32'h0;

        latched_addr   <= '0;
        latched_write  <= 0;
        latched_size   <= 3'b000;
        latched_valid  <= 0;
      end
      else begin
        // Default response = OKAY
        s_if.hresp <= 0;

        // --------------------------------------------------
        // 1) Stall / busy handling
        // --------------------------------------------------
        if (busy_flag) begin
          s_if.hreadyOut <= 0;

          if (stall_cnt > 0)
            stall_cnt <= stall_cnt - 1;
          else
            busy_flag <= 0; // will release next cycle (readyOut goes back to 1)
        end
        else begin
          s_if.hreadyOut <= 1;
        end

        // --------------------------------------------------
        // 2) DATA PHASE: service latched transfer
        // --------------------------------------------------
        if (latched_valid && !busy_flag) begin
          handle_transfer(latched_addr, latched_write, latched_size);
        end

        // --------------------------------------------------
        // 3) ADDRESS PHASE: latch next transfer
        // --------------------------------------------------
        latched_valid <= 0; // default

        // AHB-Lite: accept NEW transfer only when not busy and htrans is valid
        if (!busy_flag &&
            s_if.hsel &&
            (s_if.htrans inside {NONSEQ, SEQ})) begin

          latched_addr  <= s_if.haddr;
          latched_write <= s_if.hwrite;
          latched_size  <= s_if.hsize;
          latched_valid <= 1;
        end
      end
    end
  endtask

  // ------------------------------------------------------
  // Transfer handler (runs in DATA PHASE)
  // ------------------------------------------------------
  task handle_transfer(
    input logic [31:0] addr,
    input bit          is_write,
    input logic [2:0]  size
  );
    int idx;
    logic [31:0] r32;  // local read data
    logic [31:0] w32;  // local write data

    // ---------------- ADDRESS DECODE ----------------
    // Input region?
    bit in_region  = (addr >= IN_BASE_ADDR)  &&
                     (addr <= IN_LAST_ADDR)  &&
                     (addr[1:0] == 2'b00);
    // Output region?
    bit out_region = (addr >= OUT_BASE_ADDR) &&
                     (addr <= OUT_LAST_ADDR) &&
                     (addr[1:0] == 2'b00);

    if (in_region)
      idx = (addr - IN_BASE_ADDR) >> 2;   // 0..7
    else if (out_region)
      idx = (addr - OUT_BASE_ADDR) >> 2;  // 0..3
    else begin
      // Invalid address
      s_if.hresp  <= 1;  // ERROR
      s_if.hrdata <= 0;
      return;
    end

    // ---------------- WRITE PATH (key + pt) ----------------
    if (is_write) begin
      // Only allow writes into IN region
      if (!in_region || (idx < 0) || (idx > 7)) begin
        s_if.hresp  <= 1;
        s_if.hrdata <= 0;
        return;
      end

      // Only allow 32-bit writes
      if (size != 3'b010) begin
        s_if.hresp  <= 1;
        s_if.hrdata <= 0;
        return;
      end

      // Data phase write data
      w32 = s_if.hwdata;

      in_reg[idx] = w32;

      if (reg_write_cnt < 8)
        reg_write_cnt++;

      // When all 8 words are written, do AES and start busy stall
      if (reg_write_cnt == 8) begin
        reg_write_cnt = 0;
        do_aes_encrypt();          // fills out_reg[0..3]
        busy_flag   <= 1;
        stall_cnt   <= AES_STALL_CYCLES;
      end

      s_if.hrdata <= 0; // writes don't return data
    end

    // ---------------- READ PATH (ciphertext) ----------------
    else begin
      // Only allow reads from OUT region
      if (!out_region || (idx < 0) || (idx > 3)) begin
        s_if.hresp <= 1;   // ERROR
        r32        = 32'h0;
      end
      else begin
        r32 = out_reg[idx];
      end

      s_if.hrdata <= r32;
    end
  endtask

  // ------------------------------------------------------
  // AES DPI call + output register update
  // ------------------------------------------------------
  task do_aes_encrypt();
    // Pack key and plaintext from 8 input regs
    key_reg = {in_reg[0], in_reg[1], in_reg[2], in_reg[3]};
    pt_reg  = {in_reg[4], in_reg[5], in_reg[6], in_reg[7]};
    $display("key_reg : %0h", key_reg);
    $display("key_reg : %0h", pt_reg);
    // Call DPI AES
    aes_encrypt_dpi(pt_reg, key_reg, ct_reg);
    $display("key_reg : %0h", ct_reg);
    
    // Map 128-bit ciphertext into 4 words @ 0x24, 0x28, 0x2C, 0x30
    out_reg[0] = ct_reg[127:96];
    out_reg[1] = ct_reg[95:64];
    out_reg[2] = ct_reg[63:32];
    out_reg[3] = ct_reg[31:0];
  endtask

endclass
