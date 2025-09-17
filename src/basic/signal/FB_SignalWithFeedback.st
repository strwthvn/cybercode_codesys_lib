FUNCTION_BLOCK FB_SignalWithFeedback EXTENDS FB_BasicSignal
VAR_INPUT
    ixFeedback : BOOL;  	// Сигнал обратной связи
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_inputSignalTrigger : FB_SignalWithTrigger; // Фиксация сигнала поступления команды
	_xWaitingFeedback : BOOL;	// Флаг ожидания сигнала обратной связи
    _xFeedbackReceived : BOOL;  // Флаг успешного получения обратной связи
END_VAR

    _inputSignalTrigger(ixSignal:= GetSignal());

    // Задание флага ожидания сигнала обртаной связи при получении сигнала команды
    IF _inputSignalTrigger.GetRtrig() AND NOT _xWaitingFeedback THEN
        _xWaitingFeedback := TRUE;
    END_IF

    // Задание флага получения обратной связи и ресет флага ожидания
    IF _xWaitingFeedback AND ixFeedback THEN
        _xFeedbackReceived := TRUE;
        ResetWaitingFeedback();
    END_IF

