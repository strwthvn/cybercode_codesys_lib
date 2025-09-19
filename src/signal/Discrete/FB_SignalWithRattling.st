FUNCTION_BLOCK FB_SignalWithRattling EXTENDS FB_BasicSignal
VAR_INPUT

END_VAR
VAR_OUTPUT
END_VAR
VAR
    _tStabilityTime : TIME := T#100MS;           // Время стабилизации сигнала
    _nMaxTransitions : UINT := 5;                // Максимальное количество переходов для определения дребезга
    _tDetectionWindow : TIME := T#200MS;         // Окно времени для подсчета переходов

    _ton_StabilityFilter : TON;                 // Таймер фильтрации для стабильного сигнала
    _xOutSignal : BOOL;                         // Отфильтрованный выходной сигнал
    
    // Переменные для обнаружения дребезга
    _rt_SignalChange : R_TRIG;                  // Детектор фронта 0->1
    _ft_SignalChange : F_TRIG;                  // Детектор фронта 1->0
    _nTransitionCounter : UINT;                 // Счетчик переходов
    _ton_DetectionWindow : TON;                 // Таймер окна обнаружения
    _xRattlingDetected : BOOL;                  // Флаг обнаружения дребезга
    _xPreviousSignal : BOOL;                    // Предыдущее состояние сигнала
    _xDetectionActive : BOOL;                   // Флаг активности обнаружения
END_VAR

// =====================================
// ФИЛЬТРАЦИЯ СИГНАЛА
// =====================================
// Пропускаем сигнал только если он стабилен заданное время
_ton_StabilityFilter(IN := GetSignal(), PT := tStabilityTime);
_xOutSignal := _ton_StabilityFilter.Q;

// =====================================
// ОБНАРУЖЕНИЕ ДРЕБЕЗГА
// =====================================
// Обнаружение изменений сигнала
_rt_SignalChange(CLK := GetSignal());
_ft_SignalChange(CLK := GetSignal());

// Если произошло изменение сигнала
IF _rt_SignalChange.Q OR _ft_SignalChange.Q THEN
    // Если окно обнаружения не активно, запускаем его
    IF NOT _xDetectionActive THEN
        _xDetectionActive := TRUE;
        _nTransitionCounter := 1;  // Первый переход
    ELSE
        // Увеличиваем счетчик переходов
        _nTransitionCounter := _nTransitionCounter + 1;
    END_IF
END_IF

// Таймер окна обнаружения
_ton_DetectionWindow(
    IN := _xDetectionActive,
    PT := tDetectionWindow
);

// Проверка на дребезг в конце окна обнаружения
IF _ton_DetectionWindow.Q THEN
    // Если количество переходов превышает порог - фиксируем дребезг
    IF _nTransitionCounter >= nMaxTransitions THEN
        _xRattlingDetected := TRUE;
    END_IF
    
    // Сброс окна обнаружения
    _xDetectionActive := FALSE;
    _nTransitionCounter := 0;
    _ton_DetectionWindow(IN := FALSE);
END_IF

// Сохраняем текущее состояние для следующего цикла
_xPreviousSignal := GetSignal();

METHOD GetProcessedSignal : BOOL
VAR_INPUT
END_VAR
    GetProcessedSignal := _xOutSignal;
END_METHOD

(* Получение статуса обнаружения дребезга *)
METHOD GetRattlingDetected : BOOL
VAR_INPUT
END_VAR
    GetRattlingDetected := _xRattlingDetected;
END_METHOD

(* Получение текущего количества переходов в окне обнаружения *)
METHOD GetTransitionCount : UINT
VAR_INPUT
END_VAR
    GetTransitionCount := _nTransitionCounter;
END_METHOD

(* Проверка активности окна обнаружения дребезга *)
METHOD IsDetectionActive : BOOL
VAR_INPUT
END_VAR
    IsDetectionActive := _xDetectionActive;
END_METHOD

(* Получение оставшегося времени окна обнаружения *)
METHOD GetDetectionWindowTime : TIME
VAR_INPUT
END_VAR
    GetDetectionWindowTime := _ton_DetectionWindow.ET;
END_METHOD

(* Сброс ошибки дребезга *)
METHOD ResetRattlingError
VAR_INPUT
END_VAR
    _xRattlingDetected := FALSE;
END_METHOD

(* Полный сброс состояния функционального блока *)
METHOD Reset
VAR_INPUT
END_VAR
    // Сброс ошибки дребезга
    _xRattlingDetected := FALSE;
    
    // Сброс счетчиков и флагов
    _nTransitionCounter := 0;
    _xDetectionActive := FALSE;
    
    // Сброс таймеров
    _ton_StabilityFilter(IN := FALSE);
    _ton_DetectionWindow(IN := FALSE);
    
    // Сброс триггеров
    _rt_SignalChange(CLK := FALSE);
    _ft_SignalChange(CLK := FALSE);
    
    // Сброс выходного сигнала
    _xOutSignal := FALSE;
END_METHOD

END_FUNCTION_BLOCK