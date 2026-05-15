module control_mult(
  clk, rst, lsb_B, init, z, done, sh, reset, add
);

  input clk;
  input rst;
  input lsb_B;
  input init;
  input z;        

  output reg done;
  output reg sh;
  output reg reset;
  output reg add;

  parameter START = 3'b000;
  parameter CHECK = 3'b001;
  parameter SHIFT = 3'b010;
  parameter ADD   = 3'b011;
  parameter END   = 3'b100;

  parameter COUNT_INIT = 4;   
  reg [2:0] state, next_state;
  reg [2:0] count, next_count;
  reg [4:0] done_count;

  always @(posedge clk) begin
    if (rst) begin
        state      <= START;
        count      <= 0;
        done_count <= 0; 
    end else begin
        state      <= next_state;
        count      <= next_count;
        
        if (state == END) 
            done_count <= done_count + 1;
        else if (state == START)
            done_count <= 0;
    end
  end


  always @(*) begin
    next_state = state;
    next_count = count;
    done       = 0;
    sh         = 0;
    reset      = 0;
    add        = 0;

    case (state)
      START: begin
        reset = 1;
        if (init) begin
          next_count = COUNT_INIT; 
          next_state = CHECK;
        end
      end

      CHECK: begin
        if (lsb_B) next_state = ADD;
        else       next_state = SHIFT;
      end

      ADD: begin
        add        = 1;
        next_state = SHIFT;
      end

      SHIFT: begin
        sh = 1;
        if (count == 1) begin
          next_count = 0;
          next_state = END;
        end else begin
          next_count = count - 1;
          next_state = CHECK;
        end
      end

      END: begin
        done = 1;
        if (done_count > 28) next_state = START;
        else                 next_state = END;
      end

      default: next_state = START;
    endcase
  end

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case(state)
      START: state_name = "START";
      CHECK: state_name = "CHECK";
      SHIFT: state_name = "SHIFT";
      ADD  : state_name = "ADD";
      END  : state_name = "END";
      default: state_name = "UNKNOWN";
    endcase
  end
`endif

endmodule