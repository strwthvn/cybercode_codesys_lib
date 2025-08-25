FUNCTION_BLOCK FB_Error_SignalLongExpectation
VAR
    _execute : BOOL; // Флаг выполнения
    _feedback : BOOL; // Флаг обратной связи
    _timeout : TIME; // Таймаут ожидания

    _error : BOOL; // Флаг ошибки
    _error_message : STRING; // Сообщение об ошибке

    _sr_waiting_feedback : SR;
    _ton_waiting_feedback : TON; // Таймер ожидания обратной связи
    _rtrig_execute : R_TRIG; // Растущий фронт команды выполнения
    _ftrig_feedback : F_TRIG; // Фронт обратной связи
END_VAR

// Фронт команды execute
_rtrig_execute(CLK := _execute);

// SR-триггер для управления состоянием ожидания обратной связи
_sr_waiting_feedback(
    SET1 := _rtrig_execute.Q AND NOT _error, // Начинаем ожидание при получении команды (если нет ошибки)
    RESET := _feedback OR _error // Прекращаем ожидание при получении обратной связи или ошибки
);

// Таймер ожидания обратной связи
_ton_waiting_feedback(
    IN := _sr_waiting_feedback.Q1,
    PT := _timeout
);

// Формирование ошибки по истечении таймаута
IF _ton_waiting_feedback.Q AND NOT _error THEN
    _error := TRUE;
END_IF

// Обратный фронт обратной связи для дополнительной обработки
_ftrig_feedback(CLK := _feedback);

(* Установка флага выполнения *)
METHOD SetExecute
    VAR_INPUT
        execute : BOOL; // Флаг выполнения
    END_VAR

    _execute := execute;
END_METHOD

(* Установка флага обратной связи *)
METHOD SetFeedback
    VAR_INPUT
        feedback : BOOL; // Флаг обратной связи
    END_VAR

    _feedback := feedback;
END_METHOD

(* Установка таймаута ожидания *)
METHOD SetTimeout
    VAR_INPUT
        timeout : TIME; // Таймаут ожидания
    END_VAR

    _timeout := timeout;
END_METHOD

(* Установка сообщения об ошибке *)
METHOD SetErrorMessage
    VAR_INPUT
        error_message : STRING; // Сообщение об ошибке
    END_VAR

    _error_message := error_message;
END_METHOD

(* Получение сообщения об ошибке *)
METHOD GetErrorMessage : STRING
    GetErrorMessage := _error_message;
END_METHOD

(* Получение сигнала ошибки *)
METHOD GetError : BOOL
    GetError := _error;
END_METHOD

(* Сброс ошибки *)
METHOD Reset
    _error := FALSE;
    _sr_waiting_feedback.RESET := TRUE; 
    _ton_waiting_feedback(IN := FALSE);
END_METHOD


(* Получение состояния ожидания *)
METHOD IsWaiting : BOOL
    IsWaiting := _sr_waiting_feedback.Q1;
END_METHOD

(* Получение оставшегося времени ожидания *)
METHOD GetRemainingTime : TIME
    IF _ton_waiting_feedback.ET < _timeout THEN
        GetRemainingTime := _timeout - _ton_waiting_feedback.ET;
    ELSE
        GetRemainingTime := T#0s;
    END_IF
END_METHOD

(* Получение прошедшего времени ожидания *)
METHOD GetElapsedTime : TIME
    GetElapsedTime := _ton_waiting_feedback.ET;
END_METHOD

(* Комплексная инициализация блока *)
METHOD Initialize
    VAR_INPUT
        timeout : TIME; // Таймаут ожидания
        error_message : STRING; // Сообщение об ошибке
    END_VAR

    _timeout := timeout;
    _error_message := error_message;
    Reset(); // Сбрасываем все состояния
END_METHOD

(* Проверка готовности к новой команде *)
METHOD IsReady : BOOL
    IsReady := NOT _sr_waiting_feedback.Q1 AND NOT _error;
END_METHOD

(* Получение статуса выполнения в текстовом виде *)
METHOD GetStatus : STRING
    IF _error THEN
        GetStatus := 'ERROR';
    ELSIF _sr_waiting_feedback.Q1 THEN
        GetStatus := 'WAITING';
    ELSE
        GetStatus := 'READY';
    END_IF
END_METHOD

END_FUNCTION_BLOCK