module Project(
	input        CLOCK_50,
	input        RESET_N,
	input  [3:0] KEY,
	input  [9:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [9:0] LEDR
);

  parameter DBITS    =32;
  parameter INSTSIZE =32'd4;
  parameter INSTBITS =32;
  parameter REGNOBITS=4;
  parameter IMMBITS  =16;
  parameter STARTPC  =32'h100;
  parameter ADDRHEX  =32'hFFFFF000;
  parameter ADDRLEDR =32'hFFFFF020;
  parameter ADDRKEY  =32'hFFFFF080;
  parameter ADDRSW   =32'hFFFFF090;
  // Change this to fmedian.mif before submitting
  parameter IMEMINITFILE="fmedian.mif";
  parameter IMEMADDRBITS=16;
  parameter IMEMWORDBITS=2;
  parameter IMEMWORDS=(1<<(IMEMADDRBITS-IMEMWORDBITS));
  parameter DMEMADDRBITS=16;
  parameter DMEMWORDBITS=2;
  parameter DMEMWORDIDXBITS = DMEMADDRBITS-DMEMWORDBITS;
  parameter DMEMWORDS=(1<<(DMEMADDRBITS-DMEMWORDBITS));
  
  parameter OP1BITS  =6;
  parameter OP1_EXT  =6'b000000;
  parameter OP1_BEQ  =6'b001000;
  parameter OP1_BLT  =6'b001001;
  parameter OP1_BLE  =6'b001010;
  parameter OP1_BNE  =6'b001011;
  parameter OP1_JAL  =6'b001100;
  parameter OP1_LW   =6'b010010;
  parameter OP1_SW   =6'b011010;
  parameter OP1_ADDI =6'b100000;
  parameter OP1_ANDI =6'b100100;
  parameter OP1_ORI  =6'b100101;
  parameter OP1_XORI =6'b100110;

  
  // Add parameters for secondary opcode values
    
  /* OP2 */
  parameter OP2BITS  = 8;
  parameter OP2_EQ   = 8'b00001000;
  parameter OP2_LT   = 8'b00001001;
  parameter OP2_LE   = 8'b00001010;
  parameter OP2_NE   = 8'b00001011;

  parameter OP2_ADD  = 8'b00100000;
  parameter OP2_AND  = 8'b00100100;
  parameter OP2_OR   = 8'b00100101;
  parameter OP2_XOR  = 8'b00100110;
  parameter OP2_SUB  = 8'b00101000;
  parameter OP2_NAND = 8'b00101100;
  parameter OP2_NOR  = 8'b00101101;
  parameter OP2_NXOR = 8'b00101110;
  parameter OP2_RSHF = 8'b00110000;
  parameter OP2_LSHF = 8'b00110001;
  
  // ALU function values
  parameter ALUBITS = 4;
  parameter ALU_ADD = 4'b0000;
  parameter ALU_AND = 4'b0001;
  parameter ALU_OR  = 4'b0010;
  parameter ALU_XOR = 4'b0011;
  parameter ALU_SUB = 4'b0100;
  parameter ALU_NAND= 4'b0101;
  parameter ALU_NOR = 4'b0110;
  parameter ALU_NXOR= 4'b0111;
  parameter ALU_RSHF= 4'b1000;
  parameter ALU_LSHF= 4'b1001;
  parameter ALU_EQ  = 4'b1010;
  parameter ALU_LT  = 4'b1011;
  parameter ALU_LE  = 4'b1100;
  parameter ALU_NE  = 4'b1101;
  
  parameter HEXBITS  = 24;
  parameter LEDRBITS = 10;
  
  // The reset signal comes from the reset button on the DE0-CV board
  // RESET_N is active-low, so we flip its value ("reset" is active-high)
  wire clk,locked;
  // The PLL is wired to produce clk and locked signals for our logic
  Pll myPll(
    .refclk(CLOCK_50),
	 .rst      (!RESET_N),
	 .outclk_0 (clk),
    .locked   (locked)
  );
  wire reset=!locked;
 
  /*************** BUS *****************/
  // Create the processor's bus
  tri [(DBITS-1):0] thebus;
  parameter BUSZ={DBITS{1'bZ}};  

  /*************** PC *****************/
  // Create PC and connect it to the bus
  reg [(DBITS-1):0] PC;
  reg LdPC, DrPC, IncPC;
     
  //Data path
  always @(posedge clk or posedge reset) begin
    if(reset)
	   PC<=STARTPC;
	 else if(LdPC)
      PC<=thebus;
    else if(IncPC)
      PC<=PC+INSTSIZE;
    else
	   PC<=PC;
  end
  assign thebus=DrPC?PC:BUSZ;

  /*************** Fetch - Instruction memory *****************/  
  (* ram_init_file = IMEMINITFILE *)
  reg [(DBITS-1):0] imem[(IMEMWORDS-1):0];
  wire [(DBITS-1):0] iMemOut;
  
  assign iMemOut=imem[PC[(IMEMADDRBITS-1):IMEMWORDBITS]];
  
  /*************** Fetch - Instruction Register *****************/    
  // Create the IR (feeds directly from memory, not from bus)
  reg [(INSTBITS-1):0] IR;
  reg LdIR;
  
  //Data path
  always @(posedge clk or posedge reset)
  begin
    if(reset)
	   IR<=32'hDEADDEAD;
	 else if(LdIR)
      IR <= iMemOut;
  end
  
  
  /*************** Decode *****************/ 
  // Put the code for getting op1, rd, rs, rt, imm, etc. here 
  wire [(OP1BITS-1)    : 0] op1;
  wire [(OP2BITS-1)    : 0] op2;
  wire [(REGNOBITS-1)  : 0] rs;
  wire [(REGNOBITS-1)  : 0] rd;
  wire [(REGNOBITS-1)  : 0] rt;
  wire [(IMMBITS-1)    : 0] imm;

  //TODO: Implement instruction decomposition logic
  
  assign op1 = IR[31:26];
  assign op2 = IR[25:18];
  assign rs  = IR[7:4];
  assign rd  = IR[11:8];
  assign rt  = IR[3:0];
  assign imm = IR[23:8];
   
  /*************** sxtimm *****************/   
  wire [(DBITS-1)      : 0] sxtimm;
  reg DrOff;
  reg ShOff;
	
  assign thebus = (DrOff) ? sxtimm :
						(ShOff) ? sxtimm << 2 :
						BUSZ;
	
  /*************** Register file *****************/ 		
  // Create the registers and connect them to the bus
  reg [(DBITS-1):0] regs[15:0];

  //Control signals
  reg WrReg,DrReg;
  
  //Data signals
  reg  [(REGNOBITS-1):0] regno;
  wire [(DBITS-1)    :0] regOut;
     
  integer r;
  always @(posedge clk)
  begin: REG_WRITE
    if(WrReg&&!reset)
      regs[regno]<=thebus;
  end  
  
  assign regOut= WrReg?{DBITS{1'bX}}:regs[regno];
  assign thebus= DrReg?regOut:BUSZ;

  /***********************************************/ 

  /******************** ALU **********************/
  // Create ALU unit and connect to the bus
  //Data signals
  reg signed [(DBITS-1):0] A,B;
  reg signed [(DBITS-1):0] ALUout;
  //Control signals
  reg LdA,LdB,DrALU;
  reg [3:0] ALUfunc;
 
  //Data path
  // Receive data from bus
  always @(posedge clk) begin
    if(LdA)
      A <= thebus;
    if(LdB)
      B <= thebus;
  end  

  //TODO: Implement ALU functionality
  reg [3:0] ALUfunc_buffer;
  
  //ALU results
	always @ (*)
	begin: ALU_OPERATION
		case(ALUfunc)
			ALU_ADD: begin
				ALUout = A+B;
			end
			ALU_AND: begin
				ALUout = A&B;
			end
			ALU_OR: begin
				ALUout = A|B;
			end
			ALU_XOR: begin
				ALUout = A^B;
			end
			ALU_SUB: begin
				ALUout = A-B;
			end
			ALU_NAND: begin
				ALUout = ~(A&B);
			end
			ALU_NOR: begin
				ALUout = ~(A|B);
			end
			ALU_NXOR: begin
				ALUout = A~^B;
			end
			ALU_RSHF: begin
				ALUout = A>>>B;
			end
			ALU_LSHF: begin
				ALUout = A<<B;
			end
			ALU_EQ: begin
				ALUout = A==B;
			end
			ALU_LT: begin
				ALUout = A<B;
			end
			ALU_LE: begin
				ALUout = A<=B;
			end
			ALU_NE: begin
				ALUout = A!=B;
			end
			default: begin
				ALUout = 0;
			end
		endcase
	end

  // Connect ALU output to the bus (controlled by DrALU)
  assign thebus=DrALU?ALUout:BUSZ;

  /*************** Data Memory *****************/    
  // TODO: Put the code for data memory and I/O here  
  //Data memory
  reg [(DBITS-1):0] MAR;
  
  (* ram_init_file = IMEMINITFILE *)
  reg [(DBITS-1):0] dmem[(DMEMWORDS-1):0];
  
  reg [23:0] hex_out;
  reg [9:0] ledr_out;
  
  initial begin
	  MAR = {DBITS{1'd0}};
	  hex_out = 24'habcdef;
	  ledr_out = 10'b1010101010;
  end
  
  //Data signals
  wire [(DBITS-1):0] memin, MemVal;
  wire [(DMEMWORDIDXBITS-1):0] dmemAddr;
  
  //Control singals
  reg DrMem, WrMem, LdMAR; 
  wire MemEnable, MemWE;

  assign MemEnable = !(MAR[(DBITS-1):DMEMADDRBITS]);
  assign MemWE     = WrMem & MemEnable & !reset;

  always @(posedge clk or posedge reset)
  begin: LOAD_MAR
    if(reset) begin
      MAR<=32'b0;
    end
    else if(LdMAR) begin
      MAR<=thebus;
    end
  end
  

  //Data path
  assign dmemAddr	=	MAR[(DMEMADDRBITS-1):DMEMWORDBITS];
  assign MemVal	=	MemWE					? {DBITS{1'bX}} :
							(MAR == ADDRKEY)	? {28'd0, ~KEY} :
							(MAR == ADDRSW)	? {22'd0, SW} :
							dmem[dmemAddr];
  assign memin		=	thebus;   //Snoop the bus
	
  always @(posedge clk)
  begin: DMEM_STORE
    if(MemWE) begin
		dmem[dmemAddr] <= memin;
    end
	 else if(WrMem & !reset) begin
		if (MAR == ADDRHEX)
			hex_out <= regs[regno][23:0];
		else if (MAR == ADDRLEDR)
			ledr_out <= regs[regno][9:0];
	 end
  end
  assign thebus = DrMem ? MemVal : BUSZ;
      
  /******************** Processor state **********************/
  parameter S_BITS=6;
  parameter [(S_BITS-1):0]
    S_ZERO        = {(S_BITS){1'b0}},
    S_ONE         = {{(S_BITS-1){1'b0}},1'b1},
    S_FETCH1      = S_ZERO,						//000000
	 S_FETCH2      = S_FETCH1+S_ONE,				//000001
    S_ALUR1       = S_FETCH2+S_ONE,				//000010
	 //TODO: Define your processor states here
	 S_ALUR2			= S_ALUR1+S_ONE,				//000011
	 S_ALUR3			= S_ALUR2+S_ONE,				//000100
	 S_ALUI1			= S_ALUR3+S_ONE,				//000101
	 S_ALUI2			= S_ALUI1+S_ONE,				//000110
	 S_ALUI3			= S_ALUI2+S_ONE,				//000111
	 S_BEQ1			= S_ALUI3+S_ONE,				//001000
	 S_BEQ2			= S_BEQ1+S_ONE,				//001001
	 S_BEQ3			= S_BEQ2+S_ONE,				//001010
	 S_BNE1			= S_BEQ3+S_ONE,				//001011
	 S_BNE2			= S_BNE1+S_ONE,				//001100
	 S_BNE3			= S_BNE2+S_ONE,				//001101
	 S_BLT1			= S_BNE3+S_ONE,				//001110
	 S_BLT2			= S_BLT1+S_ONE,				//001111
	 S_BLT3			= S_BLT2+S_ONE,				//010000
	 S_BLE1			= S_BLT3+S_ONE,				//010001
	 S_BLE2			= S_BLE1+S_ONE,				//010010
	 S_BLE3			= S_BLE2+S_ONE,				//010011
	 S_BR1			= S_BLE3+S_ONE,				//010100
	 S_BR2			= S_BR1+S_ONE,					//010101
	 S_BR3			= S_BR2+S_ONE,					//010110
	 S_JAL1			= S_BR3+S_ONE,					//010111
	 S_JAL2			= S_JAL1+S_ONE,				//011000
	 S_JAL3			= S_JAL2+S_ONE,				//011001
	 S_JAL4			= S_JAL3+S_ONE,				//011010
	 S_SW1			= S_JAL4+S_ONE,				//011011
	 S_SW2			= S_SW1+S_ONE,					//011100
	 S_SW3			= S_SW2+S_ONE,					//011101
	 S_SW4			= S_SW3+S_ONE,					//011110
	 S_LW1			= S_SW4+S_ONE,					//011111
	 S_LW2			= S_LW1+S_ONE,					//100000
	 S_LW3			= S_LW2+S_ONE,					//100001
	 S_LW4			= S_LW3+S_ONE,					//100010
	 S_ERROR       = S_LW4+S_ONE;					//100011

 reg [(S_BITS-1):0] state,next_state;
  always @(state or op1 or rs or rt or rd or op2 or ALUout[0]) begin
    {LdPC,DrPC,IncPC,LdMAR,WrMem,DrMem,LdIR,DrOff,ShOff, LdA, LdB,ALUfunc,DrALU,regno,DrReg,WrReg,next_state}=
    {1'b0,1'b0, 1'b0, 1'b0, 1'b0, 1'b0,1'b0, 1'b0, 1'b0,1'b0,1'b0,   4'bX,1'b0,  4'bX, 1'b0, 1'b0,state+S_ONE};
    case(state)
      S_FETCH1: begin
			{LdIR,IncPC}={1'b1,1'b1};
			next_state=S_FETCH2;
		end
      S_FETCH2: begin
			case(op1)
				OP1_EXT: begin
					case(op2)
						OP2_EQ: begin
							ALUfunc_buffer=ALU_EQ;
							next_state=S_ALUR1;
						end
						OP2_LT: begin
							ALUfunc_buffer=ALU_LT;
							next_state=S_ALUR1;
						end
						OP2_LE: begin
							ALUfunc_buffer=ALU_LE;
							next_state=S_ALUR1;
						end
						OP2_NE: begin
							ALUfunc_buffer=ALU_NE;
							next_state=S_ALUR1;
						end
						OP2_ADD: begin
							ALUfunc_buffer=ALU_ADD;
							next_state=S_ALUR1;
						end
						OP2_AND: begin
							ALUfunc_buffer=ALU_AND;
							next_state=S_ALUR1;
						end
						OP2_OR: begin
							ALUfunc_buffer=ALU_OR;
							next_state=S_ALUR1;
						end
						OP2_XOR: begin
							ALUfunc_buffer=ALU_XOR;
							next_state=S_ALUR1;
						end
						OP2_SUB: begin
							ALUfunc_buffer=ALU_SUB;
							next_state=S_ALUR1;
						end
						OP2_NAND: begin
							ALUfunc_buffer=ALU_NAND;
							next_state=S_ALUR1;
						end
						OP2_NOR: begin
							ALUfunc_buffer=ALU_NOR;
							next_state=S_ALUR1;
						end
						OP2_NXOR: begin
							ALUfunc_buffer=ALU_NXOR;
							next_state=S_ALUR1;
						end
						OP2_RSHF: begin
							ALUfunc_buffer=ALU_RSHF;
							next_state=S_ALUR1;
						end
						OP2_LSHF: begin
							ALUfunc_buffer=ALU_LSHF;
							next_state=S_ALUR1;
						end
						default: begin
							next_state=S_ERROR;
						end
					endcase
				end
				OP1_ADDI: begin
					ALUfunc_buffer=ALU_ADD;
					next_state=S_ALUI1;
				end
				OP1_ANDI: begin
					ALUfunc_buffer=ALU_AND;
					next_state=S_ALUI1;
				end
				OP1_ORI: begin
					ALUfunc_buffer=ALU_OR;
					next_state=S_ALUI1;
				end
				OP1_XORI: begin
					ALUfunc_buffer=ALU_XOR;
					next_state=S_ALUI1;
				end
				OP1_BEQ: begin
					next_state=S_BEQ1;
				end
				OP1_BLT: begin
					next_state=S_BLT1;
				end
				OP1_BNE: begin
					next_state=S_BNE1;
				end
				OP1_BLE: begin
					next_state=S_BLE1;
				end
				OP1_JAL: begin
					next_state=S_JAL1;
				end
				OP1_LW: begin
					next_state=S_LW1;
				end
				OP1_SW: begin
					next_state=S_SW1;
				end
				default: begin
					next_state=S_ERROR;
				end
			endcase
		end
		// Put the code for the rest of the "dispatch" here	
		// Put the rest of the "microcode" here
		S_BEQ1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_BEQ2;
		end
		S_BEQ2: begin
			{LdB, DrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_BEQ3;
		end
		S_BEQ3: begin
			{ALUfunc, DrALU} = {ALU_EQ, 1'b1};
			next_state = (thebus == 1) ? S_BR1 : S_FETCH1;
		end
		S_BNE1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_BNE2;
		end
		S_BNE2: begin
			{LdB, DrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_BNE3;
		end
		S_BNE3: begin
			{ALUfunc, DrALU} = {ALU_NE, 1'b1};
			next_state = (thebus == 1) ? S_BR1 : S_FETCH1;
		end
		S_BLT1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_BLT2;
		end
		S_BLT2: begin
			{LdB, DrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_BLT3;
		end
		S_BLT3: begin
			{ALUfunc, DrALU} = {ALU_LT, 1'b1};
			next_state = (thebus == 1) ? S_BR1 : S_FETCH1;
		end
		S_BLE1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_BLE2;
		end
		S_BLE2: begin
			{LdB, DrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_BLE3;
		end
		S_BLE3: begin
			{ALUfunc, DrALU} = {ALU_LE, 1'b1};
			next_state = (thebus == 1) ? S_BR1 : S_FETCH1;
		end
		S_BR1: begin
			{DrPC, IncPC, LdA} = {1'b1, 1'b1, 1'b1};
			next_state = S_BR2;
		end
		S_BR2: begin
			{ShOff, LdB} = {1'b1, 1'b1};
			next_state = S_BR3;
		end
		S_BR3: begin
			{LdPC, DrALU, ALUfunc} = {1'b1, 1'b1, ALU_ADD};
			next_state = S_FETCH1;
		end
		S_JAL1: begin
			{DrPC, WrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_JAL2;
		end
		S_JAL2: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_JAL3;
		end
		S_JAL3: begin
			{LdB, ShOff} = {1'b1, 1'b1};
			next_state = S_JAL4;
		end
		S_JAL4: begin
			{LdPC, DrALU, ALUfunc} = {1'b1, 1'b1, ALU_ADD};
			next_state = S_FETCH1;
		end
		S_LW1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_LW2;
		end
		S_LW2: begin
			{LdB, DrOff} = {1'b1, 1'b1};
			next_state = S_LW3;
		end
		S_LW3: begin
			{LdMAR, DrALU, ALUfunc} = {1'b1, 1'b1, ALU_ADD};
			next_state = S_LW4;
		end
		S_LW4: begin
			{WrReg, DrMem, regno} = {1'b1, 1'b1, rt};
			next_state = S_FETCH1;
		end
		S_SW1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_SW2;
		end
		S_SW2: begin
			{LdB, DrOff} = {1'b1, 1'b1};
			next_state = S_SW3;
		end
		S_SW3: begin
			{LdMAR, DrALU, ALUfunc} = {1'b1, 1'b1, ALU_ADD};
			next_state = S_SW4;
		end
		S_SW4: begin
			{DrReg, WrMem, regno} = {1'b1, 1'b1, rt};
			next_state = S_FETCH1;
		end
		S_ALUI1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_ALUI2;
		end
		S_ALUI2: begin
			{LdB, DrOff} = {1'b1, 1'b1};
			next_state = S_ALUI3;
		end
		S_ALUI3: begin
			{WrReg, ALUfunc, DrALU, regno} = {1'b1, ALUfunc_buffer, 1'b1, rt};
			next_state = S_FETCH1;
		end
		S_ALUR1: begin
			{LdA, DrReg, regno} = {1'b1, 1'b1, rs};
			next_state = S_ALUR2;
		end
		S_ALUR2: begin
			{LdB, DrReg, regno} = {1'b1, 1'b1, rt};
			next_state = S_ALUR3;
		end
		S_ALUR3: begin
			{WrReg, ALUfunc, DrALU, regno} = {1'b1, ALUfunc_buffer, 1'b1, rd};
			next_state = S_FETCH1;
		end
      default: begin
			next_state=S_ERROR;
		end
    endcase
  end
	
  //TODO: Implement your processor state transition machine	 
  always @(posedge clk or posedge reset) begin
    if(reset) state<=S_FETCH1;
    else state<=next_state;
  end
  
	  
  /*************** sign-extend (SXT) *****************/       
  //TODO: Instantiate SXT module
  SXT sxt(imm, sxtimm);
  defparam sxt.IBITS = IMMBITS;
  defparam sxt.OBITS = DBITS;
  
  /*************** HEX/LEDR Output *****************/    
  //TODO: Implement output logic
  //      store to ADDRHEX or ADDRLEDR should display given values to HEX or LEDR
  assign LEDR = ledr_out;
  
  //TODO: Utilize seven segment display decoders to convert hex to actual seven-segment display control signal
  SevenSeg ss0(HEX0, hex_out[3:0], 1'b0);
  SevenSeg ss1(HEX1, hex_out[7:4], 1'b0);
  SevenSeg ss2(HEX2, hex_out[11:8], 1'b0);
  SevenSeg ss3(HEX3, hex_out[15:12], 1'b0);
  SevenSeg ss4(HEX4, hex_out[19:16], 1'b0);
  SevenSeg ss5(HEX5, hex_out[23:20], 1'b0);
  
  // Debug
  /*SevenSeg ss0(HEX0, 1'b0, 1'b1);
  SevenSeg ss1(HEX1, regs[9], 1'b0);
  SevenSeg ss2(HEX2, ALUfunc, 1'b0);
  SevenSeg ss3(HEX3, regs[8], 1'b0);
  SevenSeg ss4(HEX4, state[3:0], 1'b0);
  SevenSeg ss5(HEX5, state[5:4], 1'b0);*/
  
  // Display next PC
  /*SevenSeg ss0(HEX0, iMemOut[3:0], 1'b0);
  SevenSeg ss1(HEX1, iMemOut[7:4], 1'b0);
  SevenSeg ss2(HEX2, iMemOut[11:8], 1'b0);
  SevenSeg ss3(HEX3, iMemOut[15:12], 1'b0);
  SevenSeg ss4(HEX4, iMemOut[19:16], 1'b0);
  SevenSeg ss5(HEX5, iMemOut[23:20], 1'b0);
  assign LEDR = iMemOut[31:24];*/
endmodule

module SXT(IN,OUT);
  parameter IBITS;
  parameter OBITS;
  input  [(IBITS-1):0] IN;
  output [(OBITS-1):0] OUT;
  assign OUT={{(OBITS-IBITS){IN[IBITS-1]}},IN};
endmodule

