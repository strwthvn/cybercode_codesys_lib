FUNCTION_BLOCK FB_MechanismWithFeedback EXTENDS FB_Mechanism
VAR_INPUT
	ixFeedback : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR


METHOD GetFeedbackWithoutPower : BOOL
VAR_INPUT
END_VAR
    GetFeedbackWithoutPower := NOT GetPower() AND ixFeedback;
END_METHOD

METHOD GetPowerAndFeedback : BOOL
VAR_INPUT
END_VAR
    GetPowerAndFeedback := GetPower() AND ixFeedback;
END_METHOD

METHOD GetPowerWithoutFeedback : BOOL
VAR_INPUT
END_VAR
    GetPowerWithoutFeedback := GetPower() AND NOT ixFeedback;
END_METHOD


