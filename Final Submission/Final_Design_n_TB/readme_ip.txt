Make file expects this folder structure.

Final_Design_n_TB/
│
├── design/        # RTL design source files
│
├── aes_core/      # AES core components (optional submodules)
│
├── tb/            # UVM testbench files
│   ├── dpi/       # DPI-C source files (.cpp)
│   └── testbench.sv
│
├── makefile.vcs   # Simulation Makefile
└── readme_ip.txt  # Documentation


Run Compile only:
make -f makefile.vcs compile

Run Simulation only:
make -f makefile.vcs run

Run verdi only:
make -f makefile.vcs verdi

Run Compile + sumiulation only:
make -f makefile.vcs all

Run to clean up all the generated files:
make -f makefile.vcs clean
