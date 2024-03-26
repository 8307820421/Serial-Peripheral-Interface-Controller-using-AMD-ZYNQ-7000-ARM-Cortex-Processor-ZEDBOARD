`timescale 1ns / 1ps
module spi_design(
input clock,  // input clock is 100mhz 
input reset,
input [7:0] data_in,  // 8bit data sending
input load_data,     // declared for new data
                      // to be stored
output reg done_send,  // data has been send
output  spi_clock,    // it should be 10mhz 
                        //as per data sheet
output reg  spi_data  // data has been send
);

reg [2:0] counter =0;  // decclared to count
// the pulses and used to minimize the clock 
//frequency up to 10 mhz .
reg [2:0] data_count;  //counting the clock 
//pulse during transition
reg [7:0] shiftReg;   // data sored in siso register
reg [1:0] state;       // fsm requirement
reg clock_10;
reg clock_enable ;

assign spi_clock = (clock_enable == 1)? clock_10:1'b1;

always @ (posedge clock)
begin
if (counter !=4)  // transition betewwen 0 and 1 is 4 
//ns thus required to minimize the clock up to 10mhz
// per transition from 0 to 1 in spi clock
counter = counter +1;
else 
counter <=0;
end

initial clock_10 <=0;
always @ (posedge clock)
begin
if(counter==4) // clock will be transmit data at
// negedge clock and display at posedge clock on oled
clock_10 = ~clock_10;
end
// fsm for data trnasmission one bit at a time
localparam IDLE = 'd0,
            SEND = 'd1,
            DONE = 'd2;
            
 always @(negedge clock_10 )
  begin
  if(reset) // firstly reset declared
    begin
    state <=IDLE;
    data_count <= 0;
    done_send <= 1'b0;
    clock_enable<=0;
    spi_data = 1'b1;
    end
    
  else
  begin
  case(state) // fsm state decleration
  IDLE:begin
  if(load_data)
  begin
     shiftReg <= data_in;
     state <= SEND;
     data_count <=0;
  end
  end
  
  SEND : begin
  spi_data <= shiftReg[7];
  shiftReg <= {shiftReg[6:0],1'b0};
  clock_enable <= 1;
  if (data_count !=7)
  data_count <=data_count+1;
  else
  begin
  state<=DONE;
  end
  end
  
  DONE : begin
  clock_enable <=0 ;
  done_send <=1'b1;
  if (!load_data)
  begin
  done_send<= 1'b0;
  state<=IDLE;
  end
  end
  
  endcase
  end
  end
 endmodule




