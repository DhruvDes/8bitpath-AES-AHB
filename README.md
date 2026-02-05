# 8bitpath-AES-AHB
Project for Soc Design, Follows a paper proposal for 8bitpath AES acclerator with AHB interface


<img width="1154" height="1014" alt="chip_w_mesaurements" src="https://github.com/user-attachments/assets/a628a493-e749-499b-9173-eec1da14809b" />

### File structure for porject
AES_core_Design_n_TB

   -Design_files/    # RTL design files for the AES Core (including BIST)
   -TB_files/        # Testbench files for AES Core (including BIST)
   -makefile.vcs     # Compiles, elaborates, simulates, and launches Verdi
   -readme_aes.txt   # Usage details for makefile.vcs

Final_Design_n_TB

   -aes_core/        # AES core implementation (instantiated in AHB design)
   -design/          # RTL source files for the overall integrated design
   -tb/              # Testbench files for the overall integrated design
   -makefile.vcs     # Simulation script (see readme_ip.txt for details)
   -readme_ip.txt    # Documentation on how to use the makefile.vcs


Verification_proof_submission/ # Images of all the coverage performed and proof of completion on type of tests by the testbench.
