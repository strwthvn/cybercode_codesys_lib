FUNCTION_BLOCK FB_Command
VAR
    (* Команда*)
    _command : BOOL;
    _rtrig_command : R_TRIG;
    _ftrig_command : F_TRIG;
    (* Опции *)
    (* Дополнительные опции *)
    _CheckFeedback : FB_Error_SignalLongExpectation; // Функциональный блок проверки обратной связи
END_VAR

_CheckFeedback();

(* Установка команды *)
METHOD SetCommand
    VAR_INPUT
        command : BOOL; // Команда
    END_VAR

    _command := command;
    _rtrig_command(CLK := command);
    _ftrig_command(CLK := command); 
END_METHOD

METHOD ResetCommand
    sr_command.RESET := TRUE;
END_METHOD

(* Возвращает текущее состояние команды *)
METHOD GetCommand : BOOL
    GetCommand := _rtrig_command.Q;
END_METHOD

(* Возвращает состояние обратного фронта команды *)
METHOD GetCommandBackFront : BOOL
    GetCommandBackFront := _ftrig_command.Q;
END_METHOD

(* Установка опции проверки обратной связи *)
METHOD SetOptions_CheckFeedback
    VAR_INPUT
        signal_feedback : BOOL; // Сигнал обратной связи
        signal_feedback_timeout : TIME; // Таймаут для сигнала обратной связи
    END_VAR

    _CheckFeedback.SetExecute(execute := _rtrig_command.Q);
    _CheckFeedback.SetFeedback(feedback := signal_feedback);
    _CheckFeedback.SetTimeout(timeout := signal_feedback_timeout);
END_METHOD



(* Установка опции проверки таймаута *)
METHOD SetOptions_CheckTimeout
    VAR_INPUT
        check_timeout : BOOL; // Проверка таймаута
        option_timeout : TIME; // Таймаут для команды
    END_VAR

    _option_check_timeout := check_timeout;
    _option_timeout := option_timeout;
END_METHOD



END_FUNCTION_BLOCK