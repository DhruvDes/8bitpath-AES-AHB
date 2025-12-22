`include "data_path_one.sv"
`include "permutator.sv"
`include "key_expansion.sv"
`include "mixclm.sv"
`include "mux.sv"
`include "parll_serl.sv"
`include "canright_Sbox.sv"
// `include "rom_sbox"

module aes_8_bit (
  input  logic   rst, clk,
  input  logic  [7:0] key_in, d_in, 
  output logic  [7:0]  data_out,
  output logic  DONE,  data_valid 
);  



    logic [3:0] round_cnt_w;
    logic input_sel, sbox_sel, last_out_sel, bit_out_sel;
    logic [7:0] rcon_en;
    logic [3:0] cnt;
    logic [7:0] round_cnt;

    logic [7:0] rk_delayed_out, rk_last_out;
    logic [1:0] c3;
    logic pld;
    logic [7:0] mc_en_reg;
    logic pld_reg;
    logic [7:0] mc_en;
    logic [7:0] d_out;
    logic [7:0] d_out_w;
  	logic [3:0] Internal_count;
    logic DONE_internal,  data_valid_internal; 

    always @ (posedge clk)
    begin
        data_out <= d_out_w;
    end

    assign pld = pld_reg;
    assign mc_en = mc_en_reg;
    assign round_cnt_w = round_cnt[7:4];

  data_path_one data_path (
    .clk(clk),
    .rst(rst),
    .d_in(d_in), 
    .d_out(d_out_w), 
    .pld(pld), 
    .c3(c3), 

    .mc_en(mc_en), 
    .rk_delayed_out(rk_delayed_out), 
    .rk_last_out(rk_last_out)

  );
  
  
  
  
    key_expansion key (
      .clk(clk), 
      .rst(rst), 
      .key_in(key_in), 
      .rk_delayed_out(rk_delayed_out), 
      .round_cnt(round_cnt_w), 
      .rk_last_out(rk_last_out), 
                  
      .input_sel(input_sel), 
      .sbox_sel(sbox_sel), 
      .last_out_sel(last_out_sel), 
      .bit_out_sel(bit_out_sel), 
      .rcon_en(rcon_en)
    
    );
  


    enum logic [2:0] {load, b1st, b2nd, b3rd, norm, shif} state;  
  
    assign data_valid = data_valid_internal;
    assign DONE = DONE_internal;
        always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            data_valid_internal <= 1'b0;
            Internal_count <= 'h0;
            DONE_internal <= 0;
        end
        else
        begin
          if (round_cnt >= 8'h90)
            begin
                data_valid_internal <= 1'b1;
                Internal_count <= Internal_count + 1;
              
              if (Internal_count == 15)begin 
              		DONE_internal <= 1;
              end 
            end
        end
    end
      //mux select and rcon enable for key schedule
    always @ (*)
    begin
        case(state)
            load: 
            begin
                input_sel <= 1'b0;
                sbox_sel <= 1'b1;
                last_out_sel <= 1'b0;
                bit_out_sel <= 1'b0;
                rcon_en <= 8'h00;
            end

            b1st:
            begin
                input_sel <= 1'b1;
                sbox_sel <= 1'b1;
                last_out_sel <= 1'b0;
                bit_out_sel <= 1'b1;
                rcon_en <= 8'hFF;
            end
                 
            b2nd:
            begin
                input_sel <= 1'b1;
                sbox_sel <= 1'b1;
                last_out_sel <= 1'b0;
                bit_out_sel <= 1'b1;
                rcon_en <= 8'h00;
            end

            b3rd:
            begin
                input_sel <= 1'b1;
                sbox_sel <= 1'b0;
                last_out_sel <= 1'b0;
                bit_out_sel <= 1'b1;
                rcon_en <= 8'h00;
            end

            norm:
            begin
                input_sel <= 1'b1;
                sbox_sel <= 1'b0;
                last_out_sel <= 1'b1;
                bit_out_sel <= 1'b1;
                rcon_en <= 8'h00;
            end

            shif:
            begin
                input_sel <= 1'b1;
                sbox_sel <= 1'b0;
                last_out_sel <= 1'b1;
                bit_out_sel <= 1'b0;
                rcon_en <= 8'h00;
            end

            default: 
            begin
                input_sel <= 1'b0;
                sbox_sel <= 1'b1;
                last_out_sel <= 1'b0;
                bit_out_sel <= 1'b0;
                rcon_en <= 8'h00;
            end
        endcase
    end
    //state machine for key schedule
    always @ (posedge clk)
    begin
      if (rst == 1'b1) 
        begin
		  	
          state <= load;
          cnt <= 4'h0;
         
        end
        else
        begin
            case (state)
                load: 
                begin
                    cnt <= cnt + 4'h1;
                    if (cnt == 4'hf)
                    begin
                        state <= b1st;
                        cnt <= 4'h0;
                    end
                end

                b1st:
                begin
                    state <= b2nd;
                    cnt <= 4'h0;
                end

                b2nd:
                begin
                    cnt <= cnt + 4'h1;
                    if (cnt == 4'h1)
                    begin
                        state <= b3rd;
                        cnt <= 4'h0;
                    end
                end
                
                b3rd:
                begin
                    state <= norm;
                    cnt <= 4'h0;
                end

                norm: 
                begin
                    cnt <= cnt + 4'h1;
                    if(cnt == 4'h7)
                    begin
                        state <= shif;
                        cnt <= 4'h0;
                    end
                end

                shif:
                begin
                    cnt <= cnt + 4'h1;
                    if(cnt == 4'h3)
                    begin
                        state <= b1st;
                        cnt <= 4'h0;
                    end
                end
            endcase
        end
    end



    //round counter
    always @ (posedge clk)
    begin
        if (rst == 1'b1 || cnt == 4'hf || round_cnt_w == 4'ha)
        begin
            round_cnt <= 6'h00;
        end
        else
        begin
            round_cnt <= round_cnt + 6'h01;
        end
    end


   
    //state machine shift row
    always @ (posedge clk)
    begin
        if (state == load) 
        begin
            c3 <= 2'h3;
        end
        else
        begin
            case (round_cnt[3:0])
                4'h0: c3 <= 2'h2;
                4'h1: c3 <= 2'h1;
                4'h2: c3 <= 2'h0;
                4'h3: c3 <= 2'h3;
                4'h4: c3 <= 2'h2;
                4'h5: c3 <= 2'h1;
                4'h6: c3 <= 2'h1;
                4'h7: c3 <= 2'h3;
                4'h8: c3 <= 2'h2;
                4'h9: c3 <= 2'h3;
                4'hA: c3 <= 2'h2;
                4'hB: c3 <= 2'h3;
                4'hC: c3 <= 2'h3;
                4'hD: c3 <= 2'h3;
                4'hE: c3 <= 2'h3;
                4'hF: c3 <= 2'h3;
//                 4'h0: c3 <= 2'h5;
//                 4'h1: c3 <= 2'h1;
//                 4'h2: c3 <= 2'h0;
//                 4'h3: c3 <= 2'h1;
//                 4'h4: c3 <= 2'h2;
//                 4'h5: c3 <= 2'h1;
//                 4'h6: c3 <= 2'h1;
//                 4'h7: c3 <= 2'h3;
//                 4'h8: c3 <= 2'h2;
//                 4'h9: c3 <= 2'h3;
//                 4'hA: c3 <= 2'h3;
//                 4'hB: c3 <= 2'h3;
//                 4'hC: c3 <= 2'h3;
//                 4'hD: c3 <= 2'h3;
//                 4'hE: c3 <= 2'h3;
//                 4'hF: c3 <= 2'h3;
            endcase
        end
    end

    //mixcoloumn enable
    always @ (posedge clk)
    begin
        if (round_cnt[1:0] == 2'b11)
        begin
            mc_en_reg <= 8'h00;
        end
        else
        begin
            mc_en_reg <= 8'hFF;
        end
    end

    //parelle load
    always @ (posedge clk)
    begin
        if (state == load)
        begin
            pld_reg <= 1'b0;
        end
        else
        begin
            if (round_cnt[1:0] == 2'b11)
            begin
                pld_reg <= 1'b1;
            end
            else
            begin
                pld_reg <= 1'b0;
            end
        end
    end
endmodule




