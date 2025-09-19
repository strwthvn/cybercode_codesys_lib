FUNCTION_BLOCK FB_SignalWithTrigger EXTENDS FB_BasicSignal
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_rt_xSignal : R_TRIG;
	_ft_xSignal : F_TRIG;
END_VAR

    _rt_xSignal(CLK:=GetSignal());
    _ft_xSignal(CLK:= GetSignal());

METHOD GetFtrig : BOOL
VAR_INPUT
END_VAR
    GetFtrig := _ft_xSignal.Q;
END_METHOD

METHOD GetRtrig : BOOL
VAR_INPUT
END_VAR
    GetRtrig := _rt_xSignal.Q;
END_METHOD

END_FUNCTION_BLOCK