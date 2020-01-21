
module LAB5(D, clock, Q, Qnot);

    input D;

    input clock;

    output reg[2:0] Q, Qnot;

    always @(D, clock)

    begin

        if(clock == 1'b1);

        begin

            Q[0] = D;

            Qnot[0] = ~D;

        end

    end

    always @(posedge clock)

    begin

        Q[1] <= D;

        Qnot[1] <= ~D;

    end

    always @(negedge clock)

    begin

        Q[2] <= D;

        Qnot[2] <= ~D;

    end

endmodule

