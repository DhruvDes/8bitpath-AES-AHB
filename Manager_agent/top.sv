`include "ahb_pkd.sv"
import ahb_pkg :: *;

module top;

initial begin 
    run_test("ahb_base_test");
end

endmodule