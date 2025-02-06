void printInstructions()
{
    unsigned int inst;
    
    while(memory.load_mem(pc) != 0)
    {
        inst = 0;
        for(int i = 3; i >= 0; i--)
        {
            inst = inst | (memory.load_mem(pc + i) << (i * 8));
        }
        printf("%x:\t%08x\n",pc,inst);
        pc+=4;
    }
}

uint32_t load_word(unsigned int address) {
    uint32_t value = 0;
    for (int i = 0; i < 4; ++i) {
        value |= (memory.load_mem(address + i) << (i * 8));
    }
    return value;
}

uint16_t load_halfword(unsigned int address) {
    uint16_t value = 0;
    for (int i = 0; i < 2; ++i) {
        value |= (memory.load_mem(address + i) << (i * 8));
    }
    return value;
}

uint8_t load_byte(unsigned int address) {
    return memory.load_mem(address);
}

void store_word(unsigned int address, unsigned int value) {
    for (int i = 0; i < 4; ++i) {
        memory.store_mem(address + i, static_cast<uint8_t>((value >> (i * 8)) & 0xFF));
    }
    printf("Stored Word %x:\t%08x\n", address, value);
}

void store_halfword(unsigned int address, unsigned int value) {
    for (int i = 0; i < 2; ++i) {
        memory.store_mem(address + i, static_cast<uint8_t>((value >> (i * 8)) & 0xFF));
    }
    printf("Stored Half Word %x:\t%04x\n", address, value & 0xFFFF);
}

void store_byte(unsigned int address, unsigned int value) {
    memory.store_mem(address, static_cast<uint8_t>(value & 0xFF));
    printf("Stored Byte %x:\t%02x\n", address, value & 0xFF);
}