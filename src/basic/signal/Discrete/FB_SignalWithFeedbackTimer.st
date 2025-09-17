FUNCTION_BLOCK FB_SignalWithFeedbackTimer EXTENDS FB_SignalWithFeedback
VAR_INPUT
    tFeedbackTimeout : TIME;  // Время ожидания сигнала обратной связи
END_VAR
VAR_OUTPUT
END_VAR
VAR
    _ton_FeedbackTimeout : TON;  // Таймер ожидания обратной связи
    _xFeedbackTimeout : BOOL;    // Флаг превышения времени ожидания
END_VAR

    // Вызов родительской логики
    SUPER^();
    
    // Запуск таймера при начале ожидания обратной связи
    _ton_FeedbackTimeout(
        IN := GetWaitingFeedback(),
        PT := tFeedbackTimeout
    );
    
    // Фиксация ошибки при превышении времени ожидания
    IF _ton_FeedbackTimeout.Q AND NOT _xFeedbackTimeout THEN
        _xFeedbackTimeout := TRUE;
        ResetWaitingFeedback();  // Прекращаем ожидание при таймауте
    END_IF
    
    // Сброс таймера и ошибки при успешном получении обратной связи
    IF GetReceivedFeedback() THEN
        _ton_FeedbackTimeout(IN := FALSE);
        _xFeedbackTimeout := FALSE;
    END_IF

(* Получение статуса ошибки таймаута обратной связи *)
METHOD GetFeedbackTimeout : BOOL
VAR_INPUT
END_VAR
    GetFeedbackTimeout := _xFeedbackTimeout;
END_METHOD

(* Получение текущего времени ожидания *)
METHOD GetElapsedTime : TIME
VAR_INPUT
END_VAR
    GetElapsedTime := _ton_FeedbackTimeout.ET;
END_METHOD

(* Проверка активности таймера *)
METHOD IsTimerRunning : BOOL
VAR_INPUT
END_VAR
    IsTimerRunning := _ton_FeedbackTimeout.IN;
END_METHOD

(* Сброс ошибки таймаута *)
METHOD ResetFeedbackTimeout
VAR_INPUT
END_VAR
    _xFeedbackTimeout := FALSE;
    _ton_FeedbackTimeout(IN := FALSE);
END_METHOD

(* Полный сброс состояния (включая таймер и ошибки) *)
METHOD Reset
VAR_INPUT
END_VAR
    ResetWaitingFeedback();
    ResetReceivedFeedback();
    ResetFeedbackTimeout();
END_METHOD

END_FUNCTION_BLOCK