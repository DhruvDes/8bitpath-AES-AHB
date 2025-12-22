class ahb_cover extends uvm_subscriber#(reply_pkt);
      reply_pkt  tx;
  
      `uvm_component_utils(ahb_cover)
      covergroup ahb_cg;
          h_w_r_ite : coverpoint tx.hwrite;
          burst_type : coverpoint tx.hburst{
            bins single = {0};
            bins incr4 = {3'b011};
            bins incr8 = {3'b101};
          }
          trans_type : coverpoint tx.htrans{
            bins IDLE = {2'b00};
            bins NONSEQ = {2'b10};
            bins SEQ = {2'b11};
          }
          err : coverpoint tx.hresp;
      endgroup

      covergroup write_against_burst_Typs;
          wr_t : coverpoint tx.hwrite{
            bins write  = {1};
          }

          wbrst : coverpoint tx.hburst{
            bins single = {0};
            bins incr4 = {3'b011};
            bins incr8 = {3'b101};
          } 

          Write_against_all_valid_burst : cross wr_t, wbrst;
        
      endgroup


      covergroup read_against_burst_Typs;
        rd_t : coverpoint tx.hwrite{
          bins read  = {0};
        }

        rbrst : coverpoint tx.hburst{
          bins single = {0};
          bins incr4 = {3'b011};
        } 

        Read_against_all_valid_burst : cross rd_t, rbrst;
      
    endgroup


    
      function new (string name, uvm_component parent);
          super.new(name, parent);
        ahb_cg = new();
        write_against_burst_Typs = new();
        read_against_burst_Typs = new();
     
      endfunction
   
      virtual function void write(T t);
          $cast(tx, t);
          ahb_cg.sample();
          write_against_burst_Typs.sample();
          read_against_burst_Typs.sample();
    
      endfunction
    endclass
    