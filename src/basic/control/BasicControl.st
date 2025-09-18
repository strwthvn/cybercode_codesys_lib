FUNCTION_BLOCK BasicControl
VAR_INPUT
	ref_fbMechanism : REFERENCE TO FB_Mechanism;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_xConditionToStart 	: BOOL; 	// Условия для старта
	_xConditionToStop	: BOOL; 	// Условия для остановки
	_xConditionToAutoStop	: BOOL; // Условия для автоматической остановки 
	_xStateAutoStopped	: BOOL; 	// Был автоматически остановлен
END_VAR

AutoStop();

METHOD PROTECTED AutoStop
VAR_INPUT
END_VAR
    IF _xConditionToAutoStop THEN
        ref_fbMechanism.Stop();
        _xStateAutoStopped := TRUE;
    END_IF
END_METHOD

METHOD GetStateAutoStopped : BOOL
VAR_INPUT
END_VAR
    GetStateAutoStopped := _xStateAutoStopped;
END_METHOD

METHOD Reset
VAR_INPUT
END_VAR
    _xStateAutoStopped := FALSE;
END_METHOD

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

