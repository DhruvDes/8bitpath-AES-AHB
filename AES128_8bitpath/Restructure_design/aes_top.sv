//--------------------------------------------------
// FILE NAME: aes_top.sv
// DEPARTMENT: computer engineering
// AUTHOR: chirranjeavi moorthi
// AUTHOR'S EMAIL: cm6855@nyu.edu
//--------------------------------------------------
//KEY WORDS : Aes core
//--------------------------------------------------
//PURPOSE : Aes core module
//--------------------------------------------------


module aes_top (
                    rst, 
                    clk, 
                    key_in, 
                    data_in, 
                    data_out, 
                    data_valid, 
                    done
                );

    input rst; 
    input clk;
    input [7:0] key_in;
    input [7:0] data_in;
    output [7:0] data_out;
    output logic data_valid;
  	output logic done;

    //key scheduler controller
    logic [3:0] round_cnt_w;
    logic input_sel; 
    logic sbox_sel;
    logic last_out_sel; 
    logic bit_out_sel;
    logic [7:0] rcon_en;
    logic [3:0] cnt;
    logic [7:0] round_cnt;

    // logic [2:0] state;
    logic [7:0] round_key_delayedata_out; 
    logic [7:0] round_key_last_out;
    logic [1:0] c3;
    logic pld;
    logic [7:0] mc_en_reg;
    logic pld_reg;
    logic [7:0] mc_en;
    logic [7:0] data_out;
    logic [7:0] data_out_w;
  	logic [3:0] internal_count;

    always @ (posedge clk)
    begin
        data_out <= data_out_w;
    end

    assign pld = pld_reg;
    assign mc_en = mc_en_reg;
    assign round_cnt_w = round_cnt[7:4];

//instantion of key expansion 

    key_expansion key (
                          key_in, 
                          round_key_delayedata_out, 
                          round_cnt_w, round_key_last_out, 
                          clk, input_sel, 
                          sbox_sel, 
                          last_out_sel, 
                          bit_out_sel, 
                          rcon_en, 
                          rst
                       );

//instantion of data path

    aes_data_path data_path (
                                data_in, 
                                data_out_w, 
                                pld, 
                                c3, 
                                clk, 
                                mc_enable, 
                                round_key_delayedata_out, 
                                round_key_last_out, 
                                rst);


    enum logic [2:0] {
                        load, 
                        b1st, 
                        b2nd, 
                        b3rd, 
                        norm, 
                        shif
                        
                     } state;  
    
//FSM for key schedule

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

// always block for mux select 

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

//always blck for round counter 
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


   
//shifiting row FSM

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
            endcase
        end
    end

//blcok to enable mixing coloumn

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

//always block for parallel load data

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

    always @(posedge clk)
    begin
        if (rst == 1'b1)
        begin
            data_valid <= 1'b0;
            internal_count <= 'h0;
            DONE <= 0;
        end
        else
        begin
          if (round_cnt >= 8'h90)
            begin
                data_valid <= 1'b1;
                internal_count <= internal_count + 1;
              
              if (internal_count == 15)begin 
              		DONE <= 1;
              end 
            end
        end
    end
endmodule




