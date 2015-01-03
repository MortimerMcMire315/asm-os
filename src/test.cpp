#include "multiboot.h"
#include <stdlib.h>
#include <iostream>

using namespace std;
int main() {
    cout<<sizeof(aout_symbol_table_t)<<endl;
    cout<<sizeof(elf_section_header_table_t)<<endl;
    cout<<sizeof(multiboot_info_t)<<endl;
}
