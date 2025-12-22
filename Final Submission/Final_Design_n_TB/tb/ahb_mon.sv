class reply_pkt extends uvm_object;

    `uvm_object_utils_begin(reply_pkt)
      `uvm_field_sarray_int(key, UVM_ALL_ON)
      `uvm_field_sarray_int(pt, UVM_ALL_ON)
      `uvm_field_sarray_int(ct,     UVM_ALL_ON)
      `uvm_field_int(hresp,         UVM_ALL_ON)
      `uvm_field_int(hsize,         UVM_ALL_ON)
      `uvm_field_int(hburst,        UVM_ALL_ON)
      `uvm_field_int(haddr,        UVM_ALL_ON)
      `uvm_field_int(hwrite,        UVM_ALL_ON)
      `uvm_field_int(htrans,        UVM_ALL_ON)
    `uvm_object_utils_end
  
    function new(string name = "reply_pkt");
      super.new(name);
    endfunction
  
    logic [31:0] key [4];
    logic [31:0] pt  [4];
    logic [31:0] ct  [4];

    logic        hresp;
    logic [2:0]  hsize;
    logic [2:0]  hburst;
    logic [31:0] haddr;
    logic        hwrite;
    logic [1:0] htrans;
   
  endclass
  
  class ahb_mon extends uvm_monitor;
    `uvm_component_utils(ahb_mon)
  
    uvm_analysis_port #(reply_pkt) ap;
    uvm_analysis_port #(reply_pkt) ap_cov;
  

    virtual ahb_if vif;
  

    logic [31:0] key_buf [4];   // 0x10, 0x14, 0x18, 0x1C
    logic [31:0] pt_buf  [4];   // 0x20, 0x24, 0x28, 0x2C
    logic [31:0] ct_buf  [4];   // 0x30, 0x34, 0x38, 0x3C
  
    int key_count;
    int pt_count;
    int ct_count;
  
    bit  have_input_block; // 4 KEY + 4 PT seen
    bit  resp_error_seen;  // any HRESP error in this block
  
    // For meta on last CT access
    logic [2:0] last_size;
    logic [2:0] last_burst;
    logic [31:0] last_addr;
    bit          last_write;
   trans_t prev_trans = IDLE;
   reply_pkt rpk, rpk_cov;

    function new(string name="ahb_mon", uvm_component parent=null);
      super.new(name, parent);
    
    endfunction
  
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      ap_cov = new("ap_cov", this);
      if (!uvm_config_db#(virtual ahb_if)::get(this, "interface", "ahb_vif", vif)) begin
        `uvm_fatal(get_type_name(), "Failed to get ahb_vif for monitor")
      end
    endfunction
  
    function void send_reply_pkt();
      reply_pkt pkt = reply_pkt::type_id::create("pkt", this);
  
      pkt.hresp  = resp_error_seen;
      pkt.hsize  = last_size;
      pkt.hburst = last_burst;
      pkt.haddr = last_addr;
      pkt.hwrite = last_write;
  
      for (int i = 0; i < 4; i++) begin
        pkt.key[i] = key_buf[i];
        pkt.pt[i]  = pt_buf[i];
        pkt.ct[i]  = ct_buf[i];
      end
  
      `uvm_info("AHB_MON",
        $sformatf("Sending reply_pkt:\n  KEY=%p\n  PT =%p\n  CT =%p",
                  key_buf, pt_buf, ct_buf),
        UVM_MEDIUM)
  
      ap.write(pkt);
  
      // Clear for next block
      resp_error_seen  = 0;
      key_count        = 0;
      pt_count         = 0;
      ct_count         = 0;
      have_input_block = 0;
    endfunction
 
    task run_phase(uvm_phase phase);
      forever begin 
        wait(vif.hrstn == 1);
        @(posedge vif.hclk);
        
        case(vif.htrans)

          IDLE : begin 

            case (prev_trans) 
            
               IDLE : begin end

               BUSY : begin end

              NONSEQ : begin 

                data_phase();

              end

              SEQ : begin 
                data_phase();

              end
            
            
            endcase // IDLE case

          end // IDLE

          BUSY : begin 
            case (prev_trans)
              IDLE : begin end
              BUSY : begin end

              NONSEQ : begin 
                data_phase();
              end

              SEQ : begin 
                data_phase();
              end

            endcase// BUSY case
          end // BUSY 

          NONSEQ : begin 
            case(prev_trans)
              IDLE : begin
                // data_phase();
                collect_address();

              end
              BUSY : begin
               
              end
              NONSEQ : begin
                data_phase();
                collect_address();
              end
              SEQ : begin
                data_phase();
               collect_address();
              end
            endcase 
          end// NONSEQ 

        
        
          SEQ : begin
            case (prev_trans)
              IDLE : begin
                
              end
              BUSY : begin
               
              end
              NONSEQ : begin
           
                data_phase();
                collect_address();
 

               
              end
              SEQ : begin
                data_phase();
                collect_address();
               
              end
            endcase // SEQ case
          end // SEQ 

        endcase// main case




        prev_trans = trans_t'(vif.htrans);


      
      end // Foever end
    endtask : run_phase
    
    int count = 0;
    int count_read =0;
    logic [127:0] cipher_text_buff, key_buff, pt_buff; 
    task collect_address();
      rpk = reply_pkt::type_id::create("rpk");
      rpk_cov = reply_pkt::type_id::create("rpk_cov");
      rpk.haddr = vif.haddr;
      rpk.hwrite = vif.hwrite;
      rpk.hburst = vif.hburst; 
      rpk.htrans = vif.htrans;
      rpk.hsize = vif.hsize;
    


    endtask
    
    
    task data_phase();
    //  `uvm_info(get_type_name(), $sformatf("rpk.write_read : %h, Address : %h", rpk.hwrite, rpk.haddr), UVM_NONE)
      rpk_cov = reply_pkt::type_id::create("rpk_cov");

      rpk_cov.htrans = vif.htrans;
      ap_cov.write(rpk_cov);

      if (rpk.hwrite == 1 && vif.hreadyOut && vif.hrstn && vif.hresp != 1) begin
// `uvm_info(get_type_name(), $sformatf(" writing to address : %h, data :  %h, state : %h", rpk.haddr, vif.hwdata, vif.htrans), UVM_MEDIUM)
            
        if(rpk.haddr inside {[32'h10 : 32'h1C]})begin 
          key_buff = {key_buff[95:0], vif.hwdata}; 
          rpk_cov.hwrite = 1;
          rpk_cov.hburst = rpk.hburst; 
          rpk_cov.htrans = rpk.htrans;
          rpk_cov.hresp = 0;
          ap_cov.write(rpk_cov);
        end
        else if (rpk.haddr inside {[32'h20 : 32'h2c]})begin 
          pt_buff = {pt_buff[95:0], vif.hwdata}; 
          rpk_cov.hwrite = 1;
          rpk_cov.hburst = rpk.hburst; 
          rpk_cov.htrans = rpk.htrans;
          rpk_cov.hresp = 0;
          ap_cov.write(rpk_cov);
        end
      
      end //  if (rpk.hwrite && vif.hreadyOut && vif.hrstn && vif.hresp != 1)
      
      if (rpk.hwrite == 0 && vif.hreadyOut && vif.hrstn && vif.hresp != 1)begin
      // `uvm_info(get_type_name(), $sformatf("reading from address : %h, data :  %h, state : %h", rpk.haddr, vif.hrdata,vif.htrans), UVM_NONE)
        if(rpk.haddr inside {[32'h30 : 32'h3C]})begin 
          rpk_cov.hwrite = 0;
          rpk_cov.hburst = rpk.hburst; 
          rpk_cov.htrans = rpk.htrans;
          ap_cov.write(rpk_cov);

          cipher_text_buff = {cipher_text_buff[95:0], vif.hrdata};
          count_read += 1;
          // $display("%h", count_read);
        end
      end // (rpk.hwrite == 0 && vif.hreadyOut && vif.hrstn && vif.hresp != 1)


      if(vif.hresp == 1)begin 
        // $display("address intf %h", vif.haddr);
        // $display("address rpk %h", rpk.haddr);
        // $display("burst rpk %h", rpk.hburst);
        // $display("burst intf %h", vif.hburst);
        rpk.hresp = 1;
        ap.write(rpk);
        ap_cov.write(rpk);
      end


      if (count_read == 4) begin
        count_read = 0;
        // `uvm_info(get_type_name(), $sformatf("key_buffer : %h", key_buff), UVM_NONE)
        // `uvm_info(get_type_name(), $sformatf("key_buffer : %h", pt_buff), UVM_NONE)
        // `uvm_info(get_type_name(),$sformatf("ct_buffer : %h",cipher_text_buff), UVM_NONE)
        rpk.ct[3] = cipher_text_buff[127:96];
        rpk.ct[2] = cipher_text_buff[95:64];
        rpk.ct[1] = cipher_text_buff[63:32];
        rpk.ct[0] = cipher_text_buff[31:0];

        rpk.key[3] = key_buff[127:96];
        rpk.key[2] = key_buff[95:64];
        rpk.key[1] = key_buff[63:32];
        rpk.key[0] = key_buff[31:0];


        rpk.pt[3] = pt_buff[127:96];
        rpk.pt[2] = pt_buff[95:64];
        rpk.pt[1] = pt_buff[63:32];
        rpk.pt[0] = pt_buff[31:0];
        // rpk.print();
        rpk.hresp =0;
        ap.write(rpk);

      end

    endtask : data_phase


  endclass : ahb_mon
  