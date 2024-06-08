
The source code is in C language and is a .c file.

If running using a GNU compiler please give the below commands to create an executable file and run it.

For Open Page Policy give this command in  cmd to create an executable file-
"gcc L1.c -DOPEN -o L1_open"

An executable file named L1_open will be created. To run that file give the following command in cmd-
For default input(trace.txt) and output(dram.txt) file - "./L1_open"

To give custom input and output file names: "./L1_open 'input_file' 'output_file'

For Closed Page Policy give this command in  cmd to create an executable file-
"gcc L1.c -DCLOSED -o L1_closed"

An executable file named L1_closed will be created. To run that file give the following command in cmd-
For default input(trace.txt) and output(dram.txt) files - "./L1_closed"

To give custom input and output file names: "./L1_closed 'input_file' 'output_file'"

Running these commands will create an output file for the corresponding policy.