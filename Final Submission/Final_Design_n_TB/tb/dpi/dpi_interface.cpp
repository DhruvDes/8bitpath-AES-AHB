#include "svdpi.h"
#include <cstdio>
#include <iostream>
#include <iomanip>
// #include "aes_core.cpp"


using namespace std;

// Include AES declarations (from aes_core.cpp)
extern unsigned char* ExpandKey(unsigned char key[16]);
extern unsigned char* Encrypt(unsigned char* plaintext, unsigned char* expanded_key);

// ----------------------------------------------------------------------
// DPI entry point: connects SystemVerilog logic [127:0] → AES C code
// ----------------------------------------------------------------------
extern "C" void aes_encrypt_dpi(
    const svLogicVecVal *plaintext,
    const svLogicVecVal *key,
    svLogicVecVal *ciphertext
) {
    const int WORDS = 4; // 128 bits / 32 bits = 4
    uint8_t pt[16];
    uint8_t k[16];

    // ------------------------------------------------------------
    // Flatten 128-bit (4×32-bit) aval words into byte arrays (big-endian)
    // ------------------------------------------------------------
    for (int w = 0; w < WORDS; ++w) {
        uint32_t val_pt = plaintext[w].aval;
        uint32_t val_key = key[w].aval;
        int base = (WORDS - 1 - w) * 4; // MSB first
        for (int b = 0; b < 4; ++b) {
            pt[base + b] = (val_pt >> (8 * (3 - b))) & 0xFF;
            k[base + b]  = (val_key >> (8 * (3 - b))) & 0xFF;
        }
    }

    // ------------------------------------------------------------
    // Print incoming values
    // ------------------------------------------------------------
//     cout << "(C++) plaintext = 0x";
//     for (int i = 0; i < 16; ++i) cout << hex << setw(2) << setfill('0') << (int)pt[i];
//     cout << endl;

//     cout << "(C++) key       = 0x";
//     for (int i = 0; i < 16; ++i) cout << hex << setw(2) << setfill('0') << (int)k[i];
//     cout << endl;

    // ------------------------------------------------------------
    // Perform AES encryption
    // ------------------------------------------------------------
    unsigned char* expanded = ExpandKey(k);
    unsigned char* cipher   = Encrypt(pt, expanded);

    // ------------------------------------------------------------
    // Convert ciphertext bytes → 4×32-bit aval words (big-endian)
    // ------------------------------------------------------------
    for (int w = 0; w < WORDS; ++w) {
        uint32_t val = 0;
        int base = (WORDS - 1 - w) * 4;
        for (int b = 0; b < 4; ++b) {
            val = (val << 8) | cipher[base + b];
        }
        ciphertext[w].aval = val;
        ciphertext[w].bval = 0; // no X/Z bits
    }

    // ------------------------------------------------------------
    // Print ciphertext for debug
    // ------------------------------------------------------------
//     cout << "(C++) ciphertext = 0x";
//     for (int i = 0; i < 16; ++i) cout << hex << setw(2) << setfill('0') << (int)cipher[i];
//     cout << endl;

    delete[] expanded;
    delete[] cipher;
}


// extern "C" void aes_encrypt_dpi(
//   const svLogicVecVal *plaintext,
//   const svLogicVecVal *key,
//   svLogicVecVal *ciphertext
// ) {
//   // 128 bits / 32 bits per word = 4 words
//   const int WORDS = 4;


//   // Print plaintext (aval only, ignore X/Z in bval for now)

//   std::printf("(C) plaintext = 0x");
//   for (int i = WORDS - 1; i >= 0; --i) {
//     std::printf("%08x", plaintext[i].aval);
//   }
//   std::printf("\n");


//   // Print key

//   std::printf("(C) key       = 0x");
//   for (int i = WORDS - 1; i >= 0; --i) {
//     std::printf("%08x", key[i].aval);
//   }
//   std::printf("\n");


//   // just copy plaintext → ciphertext (identity function)

//   for (int i = 0; i < WORDS; ++i) {
//     ciphertext[i].aval = plaintext[i].aval; // data bits
//     ciphertext[i].bval = 0;                 // mark all bits as 0/1 (no X/Z)
//   }
// }
