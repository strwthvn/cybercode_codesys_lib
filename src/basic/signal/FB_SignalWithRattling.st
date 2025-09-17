FUNCTION_BLOCK FB_SignalWithRattling EXTENDS FB_BasicSignal
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    _ton_RattlingSignal : TON;
    _outSignal : BOOL;
END_VAR

_ton_RattlingSignal(IN:=GetSignal(), PT := T#100ms)

_outSignal := _ton_RattlingSignal.Q;

METHOD GetProcessedSignal : BOOL
    GetProcessedSignal := _outSignal;
END_METHOD

END_FUNCTION_BLOCK