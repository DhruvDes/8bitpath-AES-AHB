module aes_top_bist_assert(
    input   is_bist, 
                rst, 
                clk,
         en_lsfr_misr,
    
    input [7:0]key_in,
     input [7:0]d_in,
    
   input[7:0] d_out,
    input d_vld, DONE
    
  
  );


property done_goes_high_after_dval;
    @(posedge clk) disable iff (rst) d_vld |-> ##[14:$] DONE;
endproperty 

property illegal_signals_when_rst;
    @(posedge clk) 
        (rst) |=> (d_vld == 0 && DONE == 0); 
endproperty

property check_if_is_bist_works;
    @(posedge clk) disable iff (rst) $rose(is_bist) |-> ##[10:$] d_vld == 1; 
endproperty

property bist_enabled_but_not_shiftreg;
    @(posedge clk) disable iff (rst) (is_bist) |-> (##1 en_lsfr_misr == 1 || en_lsfr_misr == 1); 
endproperty
// faulty property verified in waveforms but not working in verdi
// Done_goes_high_after_dval : assert property (done_goes_high_after_dval); 
Illegal_signals_when_rst : assert property (illegal_signals_when_rst);
Check_if_is_bist_works : assert property (check_if_is_bist_works); 
Bist_enabled_but_not_shiftreg : assert property (bist_enabled_but_not_shiftreg);

endmodule
