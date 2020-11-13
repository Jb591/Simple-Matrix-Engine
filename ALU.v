module ALU (outputDataBus, inputDataBus, adressBus, instructionData, executionData, clock, reset);

input wire clock, reset;
input wire [15 : 0] adressBus; 
reg iTranspose;
reg iMultiply; 
reg iScale;
reg driveTheBus;
reg driveTheExe;

input wire [31 : 0] instructionData; // Insruction Data
input [255 : 0] inputDataBus;  // the data bus that will be read in 
output [255 : 0] outputDataBus; // the data bus that will be sent out 
inout [3 : 0] executionData; // communication between ALU and EXE
reg [31 : 0] instrData;
reg [7 : 0] exeData;

// Enable Modules :
// Enable Instruction -> 4'h0
// Enable Memory -> 4'h1
// Enable ALU -> 4'h2
// Enable EXE -> 4'h3
// Enable Register -> 4'h4
parameter instructionEnable = 4'h0; 
parameter memoryEnable = 4'h1; 
parameter ALUEnable = 4'h2; 
parameter EXEEnable = 4'h3; 
parameter RegisterEnable = 4'h4;

// Initializing Data
reg [255 : 0] result, source1, source2, status, outputRegister, finalResult; 
reg [15 : 0] ScrMatrix1 [3 : 0] [3 : 0]; // The matrix 2D arays that will be used each 16 bits wide 
reg [15 : 0] ScrMatrix2 [3 : 0] [3 : 0]; // The matrix 2D arays that will be used each 16 bits wide 
reg [15 : 0] extraMatrix [3 : 0] [3 : 0]; // to store multiplication, transpose and scale

// Using our 16 bit address bus [15 : 0]
// Last 4 bits will be used to state what module were in [15 : 12]
// Next 4 bits of adressBus will be used for the location in InstrROM [11 : 8]
// Next 4 bits will be used for the address in Memory [7 : 4]
// First 4 bits will be used for the address in Register [3 : 0]
 
// opcode values from instruction Data
parameter add       = 4'h0;
parameter sub       = 4'h1;
parameter transpose = 4'h2;
parameter scale     = 4'h3;
parameter multiply  = 4'h4;
parameter stop      = 4'h5;

always @ (negedge clock) // set our values
begin
    outputRegister = 255'd0;
    instrData = 15'd0;
    exeData = 3'd0;
    iTranspose = 0;
    iMultiply = 0; 
    iScale = 0;
    driveTheBus = 0;
    driveTheExe = 0;
end

// ALU state machine 
parameter startState = 4'h1; // wait until told what to do
parameter commandRecieved = 4'h0; // it recieved a command // did not use but it worked to my advantage that i didnt use it
parameter getSource1 = 4'h2; // wait for next command
parameter getSource2 = 4'h3; // wait for next command
parameter executeMath = 4'h4; // wait until ALU is done Meaning we need a signal bit
parameter sendDone = 4'hf; // get next instruction, sike, tell EXE done
parameter moveResult = 4'h5; // Move result to dataBus


always @ (posedge clock)
begin
    if (adressBus [15 : 12] == ALUEnable)
    begin
        case (executionData)
            startState: // Starting 
                status = inputDataBus;
            getSource1: 
            begin
                source1 = inputDataBus;
                ScrMatrix1[0][0] = inputDataBus[15 : 0];
                ScrMatrix1[0][1] = inputDataBus[31 : 16];
                ScrMatrix1[0][2] = inputDataBus[47 : 32];
                ScrMatrix1[0][3] = inputDataBus[63 : 48];

                ScrMatrix1[1][0] = inputDataBus[79 : 64];
                ScrMatrix1[1][1] = inputDataBus[95 : 80];
                ScrMatrix1[1][2] = inputDataBus[111 : 96];
                ScrMatrix1[1][3] = inputDataBus[127 : 112];

                ScrMatrix1[2][0] = inputDataBus[143 : 128];
                ScrMatrix1[2][1] = inputDataBus[159 : 144];
                ScrMatrix1[2][2] = inputDataBus[175 : 160];
                ScrMatrix1[2][3] = inputDataBus[191 : 176];

                ScrMatrix1[3][0] = inputDataBus[207 : 192];
                ScrMatrix1[3][1] = inputDataBus[223 : 208];
                ScrMatrix1[3][2] = inputDataBus[227 : 224];
                ScrMatrix1[3][3] = inputDataBus[255 : 228];
                exeData[3 : 0] = sendDone;
                driveTheExe = 1;
            end // source 1 end
            getSource2: 
            begin
                source2 = inputDataBus;
                ScrMatrix2[0][0] = inputDataBus[15 : 0];
                ScrMatrix2[0][1] = inputDataBus[31 : 16];
                ScrMatrix2[0][2] = inputDataBus[47 : 32];
                ScrMatrix2[0][3] = inputDataBus[63 : 48];

                ScrMatrix2[1][0] = inputDataBus[79 : 64];
                ScrMatrix2[1][1] = inputDataBus[95 : 80];
                ScrMatrix2[1][2] = inputDataBus[111 : 96];
                ScrMatrix2[1][3] = inputDataBus[127 : 112];

                ScrMatrix2[2][0] = inputDataBus[143 : 128];
                ScrMatrix2[2][1] = inputDataBus[159 : 144];
                ScrMatrix2[2][2] = inputDataBus[175 : 160];
                ScrMatrix2[2][3] = inputDataBus[191 : 176];

                ScrMatrix2[3][0] = inputDataBus[207 : 192];
                ScrMatrix2[3][1] = inputDataBus[223 : 208];
                ScrMatrix2[3][2] = inputDataBus[227 : 224];
                ScrMatrix2[3][3] = inputDataBus[255 : 228];
                exeData[3 : 0] = sendDone;
                driveTheExe = 1;
            end // Source 2 end

            executeMath:
            begin
                case (instructionData[31 : 24]) // the last 8 bits from instruction Data a.k.a opcode

                add: // Add the two matrix 
                begin 
                    outputRegister[15 : 0] = ScrMatrix1[0][0] + ScrMatrix2[0][0];
                    outputRegister[31 : 16] = ScrMatrix1[0][1] + ScrMatrix2[0][1];
                    outputRegister[47 : 32] = ScrMatrix1[0][2] + ScrMatrix2[0][2];
                    outputRegister[63 : 48] = ScrMatrix1[0][3] + ScrMatrix2[0][3];

                    outputRegister[79 : 64] = ScrMatrix1[1][0] + ScrMatrix2[1][0];
                    outputRegister[95 : 80] = ScrMatrix1[1][1] + ScrMatrix2[1][1];
                    outputRegister[111 : 96] = ScrMatrix1[1][2] + ScrMatrix2[1][2];
                    outputRegister[127 : 112] = ScrMatrix1[1][3] + ScrMatrix2[1][3];

                    outputRegister[143 : 128] = ScrMatrix1[2][0] + ScrMatrix2[2][0];
                    outputRegister[159 : 144] = ScrMatrix1[2][1] + ScrMatrix2[2][1];
                    outputRegister[175 : 160] = ScrMatrix1[2][2] + ScrMatrix2[2][2];
                    outputRegister[191 : 176] = ScrMatrix1[2][3] + ScrMatrix2[2][3];

                    outputRegister[207 : 192] = ScrMatrix1[3][0] + ScrMatrix2[3][0];
                    outputRegister[223 : 208] = ScrMatrix1[3][1] + ScrMatrix2[3][1];
                    outputRegister[239 : 224] = ScrMatrix1[3][2] + ScrMatrix2[3][2];
                    outputRegister[255 : 240] = ScrMatrix1[3][3] + ScrMatrix2[3][3];
                    exeData[3 : 0] = sendDone;
                    driveTheExe = 1;
                end
                sub: // Matrix Substitution 
                begin 
                    outputRegister[15 : 0] = ScrMatrix1[0][0] - ScrMatrix2[0][0];
                    outputRegister[31 : 16] = ScrMatrix1[0][1] - ScrMatrix2[0][1];
                    outputRegister[47 : 32] = ScrMatrix1[0][2] - ScrMatrix2[0][2];
                    outputRegister[63 : 48] = ScrMatrix1[0][3] - ScrMatrix2[0][3];

                    outputRegister[79 : 64] = ScrMatrix1[1][0] - ScrMatrix2[1][0];
                    outputRegister[95 : 80] = ScrMatrix1[1][1] - ScrMatrix2[1][1];
                    outputRegister[111 : 96] = ScrMatrix1[1][2] - ScrMatrix2[1][2];
                    outputRegister[127 : 112] = ScrMatrix1[1][3] - ScrMatrix2[1][3];

                    outputRegister[143 : 128] = ScrMatrix1[2][0] - ScrMatrix2[2][0];
                    outputRegister[159 : 144] = ScrMatrix1[2][1] - ScrMatrix2[2][1];
                    outputRegister[175 : 160] = ScrMatrix1[2][2] - ScrMatrix2[2][2];
                    outputRegister[191 : 176] = ScrMatrix1[2][3] - ScrMatrix2[2][3];

                    outputRegister[207 : 192] = ScrMatrix1[3][0] - ScrMatrix2[3][0];
                    outputRegister[223 : 208] = ScrMatrix1[3][1] - ScrMatrix2[3][1];
                    outputRegister[239 : 224] = ScrMatrix1[3][2] - ScrMatrix2[3][2];
                    outputRegister[255 : 240] = ScrMatrix1[3][3] - ScrMatrix2[3][3];
                    exeData[3 : 0] = sendDone;
                    driveTheExe = 1;
                end // sub end statement
                transpose: // Matrix Transpose
                begin 
                    extraMatrix[0][0] = ScrMatrix1[0][0];
                    extraMatrix[0][1] = ScrMatrix1[1][0];
                    extraMatrix[0][2] = ScrMatrix1[2][0];
                    extraMatrix[0][3] = ScrMatrix1[3][0];

                    extraMatrix[1][0] = ScrMatrix1[0][1];
                    extraMatrix[1][1] = ScrMatrix1[1][1];
                    extraMatrix[1][2] = ScrMatrix1[2][1];
                    extraMatrix[1][3] = ScrMatrix1[3][1];
                    
                    extraMatrix[2][0] = ScrMatrix1[0][2];
                    extraMatrix[2][1] = ScrMatrix1[1][2];
                    extraMatrix[2][2] = ScrMatrix1[2][2];
                    extraMatrix[2][3] = ScrMatrix1[3][2];

                    extraMatrix[3][0] = ScrMatrix1[0][3];
                    extraMatrix[3][1] = ScrMatrix1[1][3];
                    extraMatrix[3][2] = ScrMatrix1[0][3];
                    extraMatrix[3][3] = ScrMatrix1[3][3];
                    exeData[3 : 0] = sendDone;
                    driveTheExe = 1;
                    iTranspose = 1; // signaled that its transposed so unroll ScrMatrix2 into outputRegister
                end // multiply end
                multiply: // Matrix Multiply
                begin
                    extraMatrix[0][0] = (ScrMatrix1[0][0] * ScrMatrix2[0][0]) + (ScrMatrix1[0][1] * ScrMatrix2[1][0]) + (ScrMatrix1[0][2] * ScrMatrix2[2][0]) + (ScrMatrix1[0][3] * ScrMatrix2[3][0]);
                    extraMatrix[0][1] = (ScrMatrix1[0][0] * ScrMatrix2[0][1]) + (ScrMatrix1[0][1] * ScrMatrix2[1][1]) + (ScrMatrix1[0][2] * ScrMatrix2[2][1]) + (ScrMatrix1[0][3] * ScrMatrix2[3][1]);
                    extraMatrix[0][2] = (ScrMatrix1[0][0] * ScrMatrix2[0][2]) + (ScrMatrix1[0][1] * ScrMatrix2[1][2]) + (ScrMatrix1[0][2] * ScrMatrix2[2][2]) + (ScrMatrix1[0][3] * ScrMatrix2[3][2]);
                    extraMatrix[0][3] = (ScrMatrix1[0][0] * ScrMatrix2[0][3]) + (ScrMatrix1[0][1] * ScrMatrix2[1][3]) + (ScrMatrix1[0][2] * ScrMatrix2[2][3]) + (ScrMatrix1[0][3] * ScrMatrix2[3][3]);

                    extraMatrix[1][0] = (ScrMatrix1[1][0] * ScrMatrix2[0][0]) + (ScrMatrix1[1][1] * ScrMatrix2[1][0]) + (ScrMatrix1[1][2] * ScrMatrix2[2][0]) + (ScrMatrix1[1][3] * ScrMatrix2[3][0]);
                    extraMatrix[1][1] = (ScrMatrix1[1][0] * ScrMatrix2[0][1]) + (ScrMatrix1[1][1] * ScrMatrix2[1][1]) + (ScrMatrix1[1][2] * ScrMatrix2[2][1]) + (ScrMatrix1[1][3] * ScrMatrix2[3][1]);
                    extraMatrix[1][2] = (ScrMatrix1[1][0] * ScrMatrix2[0][2]) + (ScrMatrix1[1][1] * ScrMatrix2[1][2]) + (ScrMatrix1[1][2] * ScrMatrix2[2][2]) + (ScrMatrix1[1][3] * ScrMatrix2[3][2]);
                    extraMatrix[1][3] = (ScrMatrix1[1][0] * ScrMatrix2[0][3]) + (ScrMatrix1[1][1] * ScrMatrix2[1][3]) + (ScrMatrix1[1][2] * ScrMatrix2[2][3]) + (ScrMatrix1[1][3] * ScrMatrix2[3][3]);

                    extraMatrix[2][0] = (ScrMatrix1[2][0] * ScrMatrix2[0][0]) + (ScrMatrix1[2][1] * ScrMatrix2[1][0]) + (ScrMatrix1[2][2] * ScrMatrix2[2][0]) + (ScrMatrix1[2][3] * ScrMatrix2[3][0]);
                    extraMatrix[2][1] = (ScrMatrix1[2][0] * ScrMatrix2[0][1]) + (ScrMatrix1[2][1] * ScrMatrix2[1][1]) + (ScrMatrix1[2][2] * ScrMatrix2[2][1]) + (ScrMatrix1[2][3] * ScrMatrix2[3][1]);
                    extraMatrix[2][2] = (ScrMatrix1[2][0] * ScrMatrix2[0][2]) + (ScrMatrix1[2][1] * ScrMatrix2[1][2]) + (ScrMatrix1[2][2] * ScrMatrix2[2][2]) + (ScrMatrix1[2][3] * ScrMatrix2[3][2]);
                    extraMatrix[2][3] = (ScrMatrix1[2][0] * ScrMatrix2[0][3]) + (ScrMatrix1[2][1] * ScrMatrix2[1][3]) + (ScrMatrix1[2][2] * ScrMatrix2[2][3]) + (ScrMatrix1[2][3] * ScrMatrix2[3][3]);

                    extraMatrix[3][0] = (ScrMatrix1[3][0] * ScrMatrix2[0][0]) + (ScrMatrix1[3][1] * ScrMatrix2[1][0]) + (ScrMatrix1[3][2] * ScrMatrix2[2][0]) + (ScrMatrix1[3][3] * ScrMatrix2[3][0]);
                    extraMatrix[3][1] = (ScrMatrix1[3][0] * ScrMatrix2[0][1]) + (ScrMatrix1[3][1] * ScrMatrix2[1][1]) + (ScrMatrix1[3][2] * ScrMatrix2[2][1]) + (ScrMatrix1[3][3] * ScrMatrix2[3][1]);
                    extraMatrix[3][2] = (ScrMatrix1[3][0] * ScrMatrix2[0][2]) + (ScrMatrix1[3][1] * ScrMatrix2[1][2]) + (ScrMatrix1[3][2] * ScrMatrix2[2][2]) + (ScrMatrix1[3][3] * ScrMatrix2[3][2]);
                    extraMatrix[3][3] = (ScrMatrix1[3][0] * ScrMatrix2[0][3]) + (ScrMatrix1[3][1] * ScrMatrix2[1][3]) + (ScrMatrix1[3][2] * ScrMatrix2[2][3]) + (ScrMatrix1[3][3] * ScrMatrix2[3][3]);
                    iMultiply = 1; // signaled that we multiplied
                    exeData[3 : 0] = sendDone;
                    driveTheExe = 1;
                end // multiply End
                scale: // Matrix Scaling By 6 
                begin
                    extraMatrix[0][0] = ScrMatrix1[0][0] * instructionData[7 : 0]; // Immideate Value of 6
                    extraMatrix[0][1] = ScrMatrix1[0][1] * instructionData[7 : 0];
                    extraMatrix[0][2] = ScrMatrix1[0][2] * instructionData[7 : 0];
                    extraMatrix[0][3] = ScrMatrix1[0][3] * instructionData[7 : 0];

                    extraMatrix[1][0] = ScrMatrix1[1][0] * instructionData[7 : 0];
                    extraMatrix[1][1] = ScrMatrix1[1][1] * instructionData[7 : 0];
                    extraMatrix[1][2] = ScrMatrix1[1][2] * instructionData[7 : 0];
                    extraMatrix[1][3] = ScrMatrix1[1][3] * instructionData[7 : 0];

                    extraMatrix[2][0] = ScrMatrix1[2][0] * instructionData[7 : 0];
                    extraMatrix[2][1] = ScrMatrix1[2][1] * instructionData[7 : 0];
                    extraMatrix[2][2] = ScrMatrix1[2][2] * instructionData[7 : 0];
                    extraMatrix[2][3] = ScrMatrix1[2][3] * instructionData[7 : 0];

                    extraMatrix[3][0] = ScrMatrix1[3][0] * instructionData[7 : 0];
                    extraMatrix[3][1] = ScrMatrix1[3][1] * instructionData[7 : 0];
                    extraMatrix[3][2] = ScrMatrix1[3][2] * instructionData[7 : 0];
                    extraMatrix[3][3] = ScrMatrix1[3][3] * instructionData[7 : 0];
                    iScale = 1; // signaled that we scaled
                    exeData[3 : 0] = sendDone;
                    driveTheExe = 1;
                end // scale End
                stop: // Matrix Stating to stop
                begin
                    $stop;
                    exeData[3 : 0] = sendDone;
                end
                endcase // mathCase End
            end // execute Math End
            sendDone: // Tell exe Done
            begin
                exeData[3 : 0] = 4'hf;
            end // sendDone End

            moveResult:
            begin
                if (iScale || iMultiply || iTranspose) // we used the extraMatrix so we will unroll this matrix into outputRegister
                begin 
                    outputRegister[15 : 0] = extraMatrix[0][0];
                    outputRegister[31 : 16] = extraMatrix[0][1];
                    outputRegister[47 : 32] = extraMatrix[0][2];
                    outputRegister[63 : 48] = extraMatrix[0][3];

                    outputRegister[79 : 64] = extraMatrix[1][0];
                    outputRegister[95 : 80] = extraMatrix[1][1];
                    outputRegister[111 : 96] = extraMatrix[1][2];
                    outputRegister[127 : 112] = extraMatrix[1][3];

                    outputRegister[143 : 128] = extraMatrix[2][0];
                    outputRegister[159 : 144] = extraMatrix[2][1];
                    outputRegister[175 : 160] = extraMatrix[2][2];
                    outputRegister[191 : 176] = extraMatrix[2][3];

                    outputRegister[207 : 192] = extraMatrix[3][0];
                    outputRegister[223 : 208] = extraMatrix[3][1];
                    outputRegister[239 : 224] = extraMatrix[3][2];
                    outputRegister[255 : 240] = extraMatrix[3][3];
                end // unrolling end
                driveTheBus = 1; // We can now change the data in the bus
                // assign our final result into our dataBus to send to MEM
            end // moveResult End 
        endcase // case statement  
    end
end

assign executionData =(driveTheExe) ? exeData : 4'dz; // talking back to EXE that were done adding and sending to MEM
assign outputDataBus = (driveTheBus) ? outputRegister : 256'dz; // Loading the output value into a register 

endmodule