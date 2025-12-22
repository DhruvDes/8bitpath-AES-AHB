module bist_ctrl (
    input  logic clk,          
    input  logic rst_n,        
    input  logic is_bist,      

    output logic bist_rst,     
    output logic en_lsfr_misr  
);

    logic is_bist_q;  

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            is_bist_q      <= 1'b0;
            bist_rst       <= 1'b1;  
            en_lsfr_misr   <= 1'b0;
        end else begin
            is_bist_q <= is_bist;
            if (is_bist & ~is_bist_q) begin
                bist_rst     <= 1'b1;    
                en_lsfr_misr <= 1'b0;   
            end else begin
                bist_rst     <= 1'b0;    
                en_lsfr_misr <= is_bist;
            end
        end
    end

endmodule
