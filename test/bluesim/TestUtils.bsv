function Action immAssert(Bool condition, String assertName, Fmt assertFmtMsg);
    action
        let pos = printPosition(getStringPosition(assertName));
        // let pos = printPosition(getEvalPosition(condition));
        if (!condition) begin
            $display(
              "ImmAssert failed in %m @time=%0t: %s-- %s: ",
              $time, pos, assertName, assertFmtMsg
            );
            $finish(1);
        end
    endaction
endfunction

function Action immFail(String assertName, Fmt assertFmtMsg);
    action
        let pos = printPosition(getStringPosition(assertName));
        // let pos = printPosition(getEvalPosition(condition));
        $display(
            "ImmAssert failed in %m @time=%0t: %s-- %s: ",
            $time, pos, assertName, assertFmtMsg
        );
        $finish(1);
    endaction
endfunction