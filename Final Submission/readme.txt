AES_core_Design_n_TB
│
├── Design_files/        # RTL design files for the AES Core(including BIST)
│
├── TB_files/            # Testbench files for AES Core (including BIST)
│
├── makefile.vcs         # Makefile used to compile, elaborate, simulate, and launch Verdi
│
└── readme_aes.txt       # Additional details on using makefile.vcs (this file)


Final_Design_n_TB
│
├── aes_core/        # AES core implementation (Will be instantiated in the Ahb design)
│
├── design/          # RTL design source files for the Overall Integrated Design
│
├── tb/              # Testbench files for the overall integrated design
│
├── makefile.vcs     # Makefile used to run simulation more information in readme_ip.txt
│
└── readme_ip.txt    # Documentation on how to use the makefile.vcs


Verification_proof_submission/ # Images of all the coverage performed and proof of completion on type of tests by the testbench.