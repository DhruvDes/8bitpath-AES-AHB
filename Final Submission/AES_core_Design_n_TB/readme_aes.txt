expected structure by the makefile.

Design_files/        # RTL design files for AES Core
TB_files/            # Testbench files
TB_files/dpi/        # DPI .cpp files used by UVM testbench
makefile.vcs         # This Makefile
readme_ip.txt        # Documentation


Run Compile only:
make -f makefile.vcs compile

Run Simulation only:
make -f makefile.vcs run

Run verdi only:
make -f makefile.vcs verdi

Run Compile + sumiulation only:
make -f makefile.vcs al

Run Compile + Simulation + openverdi:
make -f makefile.vcs all

Run to clean up all the generated files:
make -f makefile.vcs clean
