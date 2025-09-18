FUNCTION_BLOCK FB_FrequencyControl
VAR_INPUT
	_rFrequency : REFERENCE TO REAL;
	irMaxFrequency : REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_rSetFrequency : REAL;
END_VAR

METHOD Calculate
VAR_INPUT
	rStep : REAL;					// Шаг обновления частоты
	xPulse : BOOL;					// Импульс сигнал для вычисления в условиях цикла
	xConditionToProceed : BOOL;		// Условия для продолжения вычичсления
END_VAR

	IF xPulse AND xConditionToProceed AND NOT (irMaxFrequency < _rSetFrequency) THEN
		IF _rSetFrequency + rStep < _rFrequency THEN
			_rFrequency := _rFrequency - rStep;
		ELSIF _rSetFrequency - rStep > _rFrequency THEN
			_rFrequency := _rFrequency + rStep;
		ELSE
			_rFrequency := _rSetFrequency;
		END_IF;
	END_IF;
END_METHOD

METHOD PROTECTED rSetFrequency
VAR_INPUT
	rValue : REAL;
	rFreq : REAL;
END_VAR

	IF rValue> irMaxFrequency THEN
		rFreq := irMaxFrequency;
	ELSIF rValue < 0 THEN
		rFreq := 0;
	ELSE
		rFreq := rValue;
	END_IF;
END_METHOD

(*Ручное задание выходной частоты*)
METHOD SetFrequencyOut
VAR_INPUT
	IN : REAL;
END_VAR

	rSetFrequency(rValue:= IN, rFreq :=_rSetFrequency);
	rSetFrequency(rValue:= IN, rFreq :=_rFrequency);
END_METHOD

(* Задание уставки частоты для плавного перехода *)
METHOD SetFrequencyTask
VAR_INPUT
	IN : REAL;
END_VAR

	rSetFrequency(rValue:= IN, rFreq :=_rSetFrequency);
END_METHOD

END_FUNCTION_BLOCK