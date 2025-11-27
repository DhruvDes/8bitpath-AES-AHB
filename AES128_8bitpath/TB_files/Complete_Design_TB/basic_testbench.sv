`timescale 1ns/1ps

module tb_ip_top;

  // ------------------------------------------------------------
  // AHB-Lite master signals
  // ------------------------------------------------------------
  reg         HCLK;
  reg         HRESETn;

  reg         HSEL;
  reg [31:0]  HADDR;
  reg [1:0]   HTRANS;
  reg         HWRITE;
  reg [2:0]   HSIZE;
  reg [31:0]  HWDATA;
  reg         HREADY;   // master-side ready (we drive this to 1)
  reg [2:0]HBURST;
  wire [31:0] HRDATA;
  wire        HREADYOUT;
  wire        HRESP;

  // ------------------------------------------------------------
  // DUT instance (your top-level)
  // ------------------------------------------------------------
  ip_top dut (
    .HCLK     (HCLK),
    .HRESETn  (HRESETn),
    .HSEL     (HSEL),
    .HADDR    (HADDR),
    .HTRANS   (HTRANS),
    .HWRITE   (HWRITE),
    .HSIZE    (HSIZE),
    .HWDATA   (HWDATA),
    .HREADY   (HREADY),
    .HBURST(HBURST),
    .HRDATA   (HRDATA),
    .HREADYOUT(HREADYOUT),
    .HRESP    (HRESP)
  );

  // ------------------------------------------------------------
  // Clock + reset
  // ------------------------------------------------------------
  initial begin
    HCLK = 0;
    forever #5 HCLK = ~HCLK;  // 100 MHz
  end

  initial begin
    HRESETn = 0;
    HSEL    = 0;
    HADDR   = 32'h0;
    HTRANS  = 2'b00;
    HWRITE  = 1'b0;
    HSIZE   = 3'b010;  // 32-bit
    HWDATA  = 32'h0;
    HREADY  = 1'b1;    // master always ready

    #100;
    HRESETn = 1;
  end

  // ------------------------------------------------------------
  // AHB address constants (must match ahb_pkg in your RTL)
  // ------------------------------------------------------------
  localparam [31:0] REG_CTRL0_ADDR = 32'h00; // 0x00
  localparam [31:0] REG_CTRL1_ADDR = 32'h04; // 0x04
  localparam [31:0] REG_STAT0_ADDR = 32'h08; // 0x08

  localparam [31:0] REG_KEY0_ADDR  = 32'h10;
  localparam [31:0] REG_KEY1_ADDR  = 32'h14;
  localparam [31:0] REG_KEY2_ADDR  = 32'h18;
  localparam [31:0] REG_KEY3_ADDR  = 32'h1C;

  localparam [31:0] REG_PT0_ADDR   = 32'h20;
  localparam [31:0] REG_PT1_ADDR   = 32'h24;
  localparam [31:0] REG_PT2_ADDR   = 32'h28;
  localparam [31:0] REG_PT3_ADDR   = 32'h2C;

  localparam [31:0] REG_CT0_ADDR   = 32'h30;
  localparam [31:0] REG_CT1_ADDR   = 32'h34;
  localparam [31:0] REG_CT2_ADDR   = 32'h38;
  localparam [31:0] REG_CT3_ADDR   = 32'h3C;

  // ------------------------------------------------------------
  // AHB write task
  // ------------------------------------------------------------
  task automatic ahb_write(input [31:0] addr, input [31:0] data);
  begin
    // ADDRESS PHASE
    HSEL   <= 1'b1;
    HTRANS <= 2'b10;      // NONSEQ
    HWRITE <= 1'b1;
    HADDR  <= addr;
    HSIZE  <= 3'b010;
    HWDATA <= 32'hDEAD_BEEF; // don't care this cycle

    @(posedge HCLK);

    // DATA PHASE
    HSEL   <= 1'b0;
    HTRANS <= 2'b00;
    HWRITE <= 1'b0;
    HADDR  <= 32'h0;
    HWDATA <= data;

    @(posedge HCLK);
    @(posedge HCLK);
  end
  endtask

  // ------------------------------------------------------------
  // 3-cycle safe AHB read task
  // ------------------------------------------------------------
  task automatic ahb_read(input [31:0] addr, output [31:0] data);
  begin
    // === CYCLE 0: drive address before edge ===
    @(posedge HCLK);
    HSEL   <= 1'b1;
    HTRANS <= 2'b10;   // NONSEQ
    HWRITE <= 1'b0;
    HADDR  <= addr;
    HSIZE  <= 3'b010;

    // === CYCLE 1: DUT samples, read_d gets set ===
    @(posedge HCLK);
    HSEL   <= 1'b0;
    HTRANS <= 2'b00;

    // === CYCLE 2: HRDATA valid (read_d == 1) ===
    @(posedge HCLK);
    data = HRDATA;

    // Optional idle
    @(posedge HCLK);
  end
  endtask

  // ------------------------------------------------------------
  // NIST AES-128 test vectors
  // ------------------------------------------------------------

  // Vector #1 (FIPS-197 C.1)
  localparam [127:0] KEY_128 = 128'h00010203_04050607_08090A0B_0C0D0E0F;
  localparam [127:0] PT_128  = 128'h00112233_44556677_8899AABB_CCDDEEFF;
  localparam [127:0] CT_128_GOLDEN
                     = 128'h69C4E0D8_6A7B0430_D8CDB780_70B4C55A;

  // Vector #2 (NIST SP 800-38A, AES-128-ECB, block #1)
  localparam [127:0] KEY_128_2 = 128'h2B7E1516_28AED2A6_ABF71588_09CF4F3C;
  localparam [127:0] PT_128_2  = 128'h6BC1BEE2_2E409F96_E93D7E11_7393172A;
  localparam [127:0] CT_128_GOLDEN_2
                     = 128'h3AD77BB4_0D7A3660_A89ECAF3_2466EF97;

  // ------------------------------------------------------------
  // Main test sequence
  // ------------------------------------------------------------
  initial begin : main_test
    reg [31:0] status;
    reg [31:0] ct0, ct1, ct2, ct3;
    reg [127:0] ct_bus;
    integer bist_timeout;
    integer norm_timeout;

    // Wait for reset deassertion
    @(posedge HRESETn);
    repeat (5) @(posedge HCLK);

    $display("[%0t] === Reset complete ===", $time);

    // ============================================================
    // PHASE 1: BIST MODE
    // ============================================================
    $display("[%0t] >>> Starting BIST mode test...", $time);

    // Enable BIST via REG_CTRL1 bit0 = 1
    ahb_write(REG_CTRL1_ADDR, 32'h0000_0001);

    // Small delay
    repeat (5) @(posedge HCLK);

    // Poll STAT0 until done (bit0) is set, with timeout & traces
    bist_timeout = 0;
    do begin
      ahb_read(REG_STAT0_ADDR, status);
      bist_timeout++;

      if (bist_timeout % 1000 == 0) begin
        $display("[%0t] BIST STAT0 = 0x%08h (busy=%0b, done=%0b)  [dbg: is_bist=%0b, aes_busy=%0b, aes_done_sticky=%0b]",
                 $time, status, status[1], status[0],
                 dut.ahb.is_bist,
                 dut.ahb.aes_busy,
                 dut.ahb.aes_done_sticky);
      end

      if (bist_timeout > 200000) begin
        $fatal(1,"[%0t] BIST TIMEOUT: done never asserted. status=0x%08h, is_bist=%0b aes_busy=%0b aes_done_sticky=%0b",
               $time,
               status,
               dut.ahb.is_bist,
               dut.ahb.aes_busy,
               dut.ahb.aes_done_sticky);
      end
    end while (status[0] == 1'b0); // wait for aes_done_sticky == 1

    $display("[%0t] BIST done observed. STAT0=0x%08h", $time, status);

    // Read CT words (MISR evolution in BIST mode)
    ahb_read(REG_CT0_ADDR, ct0);
    ahb_read(REG_CT1_ADDR, ct1);
    ahb_read(REG_CT2_ADDR, ct2);
    ahb_read(REG_CT3_ADDR, ct3);

    ct_bus = {ct3, ct2, ct1, ct0};

    $display("  Reconstructed 128-bit BIST CT = 0x%032h", ct_bus);
    $display("  DUT ahb.ct_reg (hier)         = 0x%032h", dut.ahb.ct_reg);

    // Self-check: AHB CT must match internal ct_reg
    if (ct_bus !== dut.ahb.ct_reg) begin
      $error("[%0t] BIST FAIL: AHB CT != internal ct_reg", $time);
    end else begin
      $display("[%0t] BIST PASS: AHB CT matches internal ct_reg.", $time);
    end

    // Disable BIST for normal mode
    ahb_write(REG_CTRL1_ADDR, 32'h0000_0000);
    repeat (5) @(posedge HCLK);

    // ============================================================
    // PHASE 2: NORMAL AES ENCRYPTION (NIST vector #1)
    // ============================================================
    $display("[%0t] >>> Starting NORMAL mode AES test #1...", $time);

    // Program 128-bit KEY into 4x32-bit regs (word order matches RTL)
    ahb_write(REG_CTRL0_ADDR, 32'h0000_0001); // request START
    ahb_write(REG_KEY0_ADDR, KEY_128[ 31:  0]);
    ahb_write(REG_KEY1_ADDR, KEY_128[ 63: 32]);
    ahb_write(REG_KEY2_ADDR, KEY_128[ 95: 64]);
    ahb_write(REG_KEY3_ADDR, KEY_128[127: 96]);

    // Program 128-bit PT into 4x32-bit regs
    ahb_write(REG_PT0_ADDR, PT_128[ 31:  0]);
    ahb_write(REG_PT1_ADDR, PT_128[ 63: 32]);
    ahb_write(REG_PT2_ADDR, PT_128[ 95: 64]);
    ahb_write(REG_PT3_ADDR, PT_128[127: 96]);

    $display("[%0t] DBG3#1 (after KEY/PT writes): aes_busy=%0b aes_done_sticky=%0b",
             $time,
             dut.ahb.aes_busy,
             dut.ahb.aes_done_sticky);

    repeat (5) @(posedge HCLK);

    // Poll STAT0 until done (bit0) is set, with timeout & traces
    norm_timeout = 0;
    do begin
      ahb_read(REG_STAT0_ADDR, status);
      norm_timeout++;

      if (norm_timeout % 1000 == 0) begin
        $display("[%0t] NORMAL#1 STAT0 = 0x%08h (busy=%0b, done=%0b)  [dbg: aes_busy=%0b, aes_done_sticky=%0b, data_valid=%0b, done=%0b]",
                 $time,
                 status,
                 status[1], status[0],
                 dut.ahb.aes_busy,
                 dut.ahb.aes_done_sticky,
                 dut.aes.data_valid,
                 dut.aes.done);
      end

      if (norm_timeout > 200000) begin
        $fatal(1,"[%0t] NORMAL#1 TIMEOUT: done never asserted. status=0x%08h", $time, status);
      end
    end while (status[0] == 1'b0);

    $display("[%0t] NORMAL#1 done observed. STAT0=0x%08h", $time, status);

    // Read CT words (normal AES ciphertext)
    ahb_read(REG_CT0_ADDR, ct0);
    ahb_read(REG_CT1_ADDR, ct1);
    ahb_read(REG_CT2_ADDR, ct2);
    ahb_read(REG_CT3_ADDR, ct3);

    ct_bus = {ct3, ct2, ct1, ct0};

    $display("  Reconstructed 128-bit CT #1 = 0x%032h", ct_bus);
    $display("  DUT ahb.ct_reg (hier)       = 0x%032h", dut.ahb.ct_reg);
    $display("  Expected NIST AES-128 CT #1 = 0x%032h", CT_128_GOLDEN);

    // Self-check 1: AHB CT must match internal ct_reg
    if (ct_bus !== dut.ahb.ct_reg) begin
      $error("[%0t] NORMAL#1 FAIL (INTERNAL): AHB CT != internal ct_reg", $time);
    end else begin
      $display("[%0t] NORMAL#1 INTERNAL PASS: AHB CT matches internal ct_reg.", $time);
    end

    // Self-check 2: Compare against NIST golden
    if (ct_bus !== CT_128_GOLDEN) begin
      $error("[%0t] NORMAL#1 FAIL (GOLDEN): AES CT != NIST expected.\n  Got      = 0x%032h\n  Expected = 0x%032h",
             $time, ct_bus, CT_128_GOLDEN);
    end else begin
      $display("[%0t] NORMAL#1 GOLDEN PASS: AES CT matches NIST vector #1.", $time);
    end

    // ============================================================
    // PHASE 3: NORMAL AES ENCRYPTION (NIST vector #2)
    // ============================================================
    $display("[%0t] >>> Starting NORMAL mode AES test #2...", $time);

    // Program 128-bit KEY for vector #2
    ahb_write(REG_CTRL0_ADDR, 32'h0000_0001); // request START again
    ahb_write(REG_KEY0_ADDR, KEY_128_2[ 31:  0]);
    ahb_write(REG_KEY1_ADDR, KEY_128_2[ 63: 32]);
    ahb_write(REG_KEY2_ADDR, KEY_128_2[ 95: 64]);
    ahb_write(REG_KEY3_ADDR, KEY_128_2[127: 96]);

    // Program 128-bit PT for vector #2
    ahb_write(REG_PT0_ADDR, PT_128_2[ 31:  0]);
    ahb_write(REG_PT1_ADDR, PT_128_2[ 63: 32]);
    ahb_write(REG_PT2_ADDR, PT_128_2[ 95: 64]);
    ahb_write(REG_PT3_ADDR, PT_128_2[127: 96]);

    $display("[%0t] DBG3#2 (after KEY/PT writes): aes_busy=%0b aes_done_sticky=%0b",
             $time,
             dut.ahb.aes_busy,
             dut.ahb.aes_done_sticky);

    repeat (5) @(posedge HCLK);

    // Poll STAT0 until done (bit0) is set, with timeout & traces
    norm_timeout = 0;
    do begin
      ahb_read(REG_STAT0_ADDR, status);
      norm_timeout++;

      if (norm_timeout % 1000 == 0) begin
        $display("[%0t] NORMAL#2 STAT0 = 0x%08h (busy=%0b, done=%0b)",
                 $time,
                 status,
                 status[1], status[0]);
      end

      if (norm_timeout > 200000) begin
        $fatal(1, "[%0t] NORMAL#2 TIMEOUT: done never asserted. status=0x%08h", $time, status);
      end
    end while (status[0] == 1'b0);

    $display("[%0t] NORMAL#2 done observed. STAT0=0x%08h", $time, status);

    // Read CT words (normal AES ciphertext) for vector #2
    ahb_read(REG_CT0_ADDR, ct0);
    ahb_read(REG_CT1_ADDR, ct1);
    ahb_read(REG_CT2_ADDR, ct2);
    ahb_read(REG_CT3_ADDR, ct3);

    ct_bus = {ct3, ct2, ct1, ct0};

    $display("  Reconstructed 128-bit CT #2 = 0x%032h", ct_bus);
    $display("  DUT ahb.ct_reg (hier)       = 0x%032h", dut.ahb.ct_reg);
    $display("  Expected NIST AES-128 CT #2 = 0x%032h", CT_128_GOLDEN_2);

    // Self-check 1: AHB CT must match internal ct_reg
    if (ct_bus !== dut.ahb.ct_reg) begin
      $error("[%0t] NORMAL#2 FAIL (INTERNAL): AHB CT != internal ct_reg", $time);
    end else begin
      $display("[%0t] NORMAL#2 INTERNAL PASS: AHB CT matches internal ct_reg.", $time);
    end

    // Self-check 2: Compare against NIST golden (#2)
    if (ct_bus !== CT_128_GOLDEN_2) begin
      $error("[%0t] NORMAL#2 FAIL (GOLDEN): AES CT != NIST expected.\n  Got      = 0x%032h\n  Expected = 0x%032h",
             $time, ct_bus, CT_128_GOLDEN_2);
    end else begin
      $display("[%0t] NORMAL#2 GOLDEN PASS: AES CT matches NIST vector #2.", $time);
    end

    $display("[%0t] *** All tests completed. ***", $time);
    #50;
    $finish;
  end

endmodule
