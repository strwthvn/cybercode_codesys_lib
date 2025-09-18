FUNCTION_BLOCK BasicControl
VAR_INPUT
	ref_fbMechanism : REFERENCE TO FB_Mechanism;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_xConditionToStart 	: BOOL; 	// Условия для старта
	_xConditionToStop	: BOOL; 	// Условия для остановки
END_VAR

METHOD SetConditionToStart
VAR_INPUT
	x : BOOL;
END_VAR
    _xConditionToStart := x;
END_METHOD

METHOD SetConditionToStop
VAR_INPUT
	x : BOOL;
END_VAR
    _xConditionToStop := x;
END_METHOD

METHOD Start
VAR_INPUT
	cmd : BOOL;
END_VAR
    IF cmd AND _xConditionToStart THEN
	    ref_fbMechanism.Start();
    END_IF
END_METHOD

METHOD Stop
VAR_INPUT
	cmd : BOOL;
END_VAR
    IF cmd AND _xConditionToStop THEN
        ref_fbMechanism.Stop();
    END_IF
END_METHOD

