# Simplistic Matrix Engine

For this project I created a basic matrix unit that could be utilized in deep learning. The matrix unit  will perform matrix multiplication, scaler multiplication, subtraction, addition and transposition. A testbench will place a starting set of matrix RAM and place opcodes fro the execution unit to perform the matrix functions using the matrix modules.

## Porject Details

* All math functions will have a clear input set to zero.
* The register value needs to be able to be written back into memeory location
* All matricies will be 4x4 16 bit deep
* Matrix multiplier will multiply two 4x4 matrix and return a 4x4 matrix
* Scalar multiplication is multiplying a matrix by single number
* Add and subtract will add and subtract 2 4x4 matrix
* Transpose will flip a matrix along a diagnol
* The test bench will Start the clock and toggle reset
* Execution engine will fetch the first opcode from instruction memory and begin execution.
* The execution engine will direct the transfer of data between the memory, the appropriate matrix modules and memory
* The execution engine will continue executing programs until is finds a STOP opcode.
* The test bench will display an output waveform to determine correct operation.

## Test Bench Operation

Load 2 matrix’s into RAM. Load opcodes into RAM for the execution unit.
Opertaions to be performed:

1. Add the first matrix to the second matrix and store the result in memory
2. Subtract the first matrix from the result in step 1 and store the result somewhere else in memory
3. Transpose the result from step 1 store in memory
4. Scale the result in step 3 store in a register
5. Multiply the result from step 4 by the result in step 3, store in memory

## Project Recommendation

### **Execution Engine**

Generate my own opcode set that will include opcodes for:

* STOP
* Matrix Addition to/from memory, to/from register
* Matrix Subtraction to/from memory, to/from register
* Matrix Multiply to/from memory, to/from register
* Matrix Transpose to/from memory, to/from register
* Matrix scale  to/from memory, to/from register

### Installation

Clone this repo for easy access

`git clone https://github.com/Jb591/Simple-Matrix-Engine.git`
