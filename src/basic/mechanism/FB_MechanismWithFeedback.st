FUNCTION_BLOCK FB_MechanismWithFeedback EXTENDS FB_Mechanism
VAR_INPUT
	ixFeedback : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_uFeedbackState : E_StateFeedback;
END_VAR
    
    UpdateState();

METHOD GetFeedbackWithoutPower : BOOL
VAR_INPUT
END_VAR
    GetFeedbackWithoutPower := _uFeedbackState = E_StateFeedback.Error_UnexpectedFeedback;
END_METHOD

METHOD GetPowerAndFeedback : BOOL
VAR_INPUT
END_VAR
    GetPowerAndFeedback := _uFeedbackState = E_StateFeedback.Active;
END_METHOD

METHOD GetPowerWithoutFeedback : BOOL
VAR_INPUT
END_VAR
    GetPowerWithoutFeedback := _uFeedbackState = E_StateFeedback.Error_NoFeedback;
END_METHOD

METHOD GetState : E_StateFeedback
VAR_INPUT
END_VAR
    GetState := _uFeedbackState;
END_METHOD

METHOD PROTECTED UpdateState
VAR_INPUT
END_VAR
    IF NOT GetPower() AND NOT ixFeedback THEN _uFeedbackState := E_StateFeedback.Inactive; END_IF; 				// 0
    IF GetPower() AND ixFeedback THEN _uFeedbackState := E_StateFeedback.Active; END_IF; 						// 1
    IF GetPower() AND NOT ixFeedback THEN _uFeedbackState := E_StateFeedback.Error_NoFeedback; END_IF;			// 2
    IF NOT GetPower() AND ixFeedback THEN _uFeedbackState := E_StateFeedback.Error_UnexpectedFeedback; END_IF;	// 3
END_METHOD

END_FUNCTION_BLOCK