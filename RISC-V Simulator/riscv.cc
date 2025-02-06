#include <iostream>
#include <map>
#include <fstream>
#include <sstream>

using namespace std;

unsigned int stackAddress;

class Memory {
public:
    Memory() {}

    // Function to allocate memory
    void store_mem(unsigned int address, uint8_t value) {
        Mem[address] = value;
    }

    // Function to retrieve value from memory
    uint8_t load_mem(unsigned int address) {
        if (Mem.find(address) != Mem.end()) {
            return Mem[address];
        } else {
            cerr << "Address not found in memory!" << endl;
            return 0;
        }
    }

    // Function to print memory
    void printMemory() {
        for (const auto& pair : Mem) {
            printf("Address: %x Value: %02x\n", pair.first, pair.second);
        }
    }

private:
    map<unsigned int, uint8_t> Mem;
};

// Declare the Memory object as a global variable
Memory memory;
unsigned int pc = 0;
#include "load_store.h"


void loadMemoryImage(const string& filename) 
{
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Failed to open memory image file: " << filename << endl;
        return;
    }

    string line;
    while (getline(file, line)) {
        size_t pos = line.find(':');
        if (pos != string::npos) {
            string addressStr = line.substr(0, pos);
            string valueStr = line.substr(pos + 1);

            // Remove leading and trailing whitespaces from addressStr and valueStr
            addressStr.erase(0, addressStr.find_first_not_of(" \t\n\r\f\v"));
            addressStr.erase(addressStr.find_last_not_of(" \t\n\r\f\v") + 1);
            valueStr.erase(0, valueStr.find_first_not_of(" \t\n\r\f\v"));
            valueStr.erase(valueStr.find_last_not_of(" \t\n\r\f\v") + 1);

            unsigned int address = strtoul(addressStr.c_str(), nullptr, 16);
            unsigned int value = strtoul(valueStr.c_str(), nullptr, 16);

            for (int i = 0; i < 4; ++i) {
                memory.store_mem(address + i, static_cast<uint8_t>((value >> (i * 8)) & 0xFF));
            }
        }
    }
}


int main(int argc, char* argv[]) {
    string memoryImageFile = "program.mem";
    unsigned int startingAddress = 0;
    stackAddress = 65536;

    if (argc > 1) {
        memoryImageFile = argv[1];
    }
    if (argc > 2) {
        startingAddress = stoi(argv[2]);
    }
    if (argc > 3) {
        stackAddress = stoi(argv[3]);
    }

    // Load memory image from file
    loadMemoryImage(memoryImageFile);


    //printInstructions();

    printf("Word at address 0x4: %08x\n", load_word(0x4));
    printf("Halfword at address 0x4: %04x\n", load_halfword(0x4));
    printf("Byte at address 0x4: %02x\n", load_byte(0x4));

    return 0;
}
