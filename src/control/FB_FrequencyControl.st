FUNCTION_BLOCK FB_FrequencyControl
VAR_INPUT
    irMaxFrequency : REAL := 100.0;      // Максимальная частота
    irStep : REAL := 1.0;                // Шаг изменения частоты по умолчанию
END_VAR
VAR_OUTPUT
    qrCurrentFrequency : REAL;           // Текущая выходная частота
    qxTargetReached : BOOL;              // Флаг достижения целевой частоты
END_VAR
VAR
    _rSetFrequency : REAL;               // Целевая частота (уставка)
    _rCurrentFrequency : REAL;           // Текущая частота (внутренняя)
    _xInitialized : BOOL := FALSE;       // Флаг инициализации
END_VAR

// Основной метод обработки
METHOD Calculate
VAR_INPUT
    rStep : REAL;                        // Шаг обновления частоты
    xPulse : BOOL;                       // Импульс сигнал для вычисления в условиях цикла
    xConditionToProceed : BOOL;          // Условия для продолжения вычисления
END_VAR
VAR
    rStepToUse : REAL;                   // Используемый шаг
END_VAR
    // Используем переданный шаг или шаг по умолчанию
    IF rStep > 0 THEN
        rStepToUse := rStep;
    ELSE
        rStepToUse := irStep;
    END_IF
    
    // Инициализация при первом вызове
    IF NOT _xInitialized THEN
        _rCurrentFrequency := 0;
        _xInitialized := TRUE;
    END_IF
    
    // Обработка изменения частоты
    IF xPulse AND xConditionToProceed THEN
        // Проверяем, не превышает ли уставка максимальную частоту
        IF _rSetFrequency > irMaxFrequency THEN
            _rSetFrequency := irMaxFrequency;
        END_IF
        
        // Плавное изменение частоты к уставке
        IF _rCurrentFrequency < _rSetFrequency - rStepToUse THEN
            // Увеличиваем частоту
            _rCurrentFrequency := _rCurrentFrequency + rStepToUse;
            qxTargetReached := FALSE;
        ELSIF _rCurrentFrequency > _rSetFrequency + rStepToUse THEN
            // Уменьшаем частоту
            _rCurrentFrequency := _rCurrentFrequency - rStepToUse;
            qxTargetReached := FALSE;
        ELSE
            // Достигли целевой частоты
            _rCurrentFrequency := _rSetFrequency;
            qxTargetReached := TRUE;
        END_IF
    END_IF
    
    // Обновляем выходное значение
    qrCurrentFrequency := _rCurrentFrequency;
END_METHOD

(* Внутренний метод ограничения частоты *)
METHOD PROTECTED LimitFrequency : REAL
VAR_INPUT
    rValue : REAL;
END_VAR
    IF rValue > irMaxFrequency THEN
        LimitFrequency := irMaxFrequency;
    ELSIF rValue < 0 THEN
        LimitFrequency := 0;
    ELSE
        LimitFrequency := rValue;
    END_IF
END_METHOD

(* Ручное задание выходной частоты (мгновенное изменение) *)
METHOD SetFrequencyDirect
VAR_INPUT
    rFrequency : REAL;
END_VAR
    _rCurrentFrequency := LimitFrequency(rFrequency);
    _rSetFrequency := _rCurrentFrequency;
    qrCurrentFrequency := _rCurrentFrequency;
    qxTargetReached := TRUE;
END_METHOD

(* Задание уставки частоты для плавного перехода *)
METHOD SetFrequencyTarget
VAR_INPUT
    rFrequency : REAL;
END_VAR
    _rSetFrequency := LimitFrequency(rFrequency);
    qxTargetReached := FALSE;
END_METHOD

(* Получение текущей частоты *)
METHOD GetCurrentFrequency : REAL
VAR_INPUT
END_VAR
    GetCurrentFrequency := _rCurrentFrequency;
END_METHOD

(* Получение целевой частоты *)
METHOD GetTargetFrequency : REAL
VAR_INPUT
END_VAR
    GetTargetFrequency := _rSetFrequency;
END_METHOD

(* Сброс частоты в ноль *)
METHOD Reset
VAR_INPUT
END_VAR
    _rCurrentFrequency := 0;
    _rSetFrequency := 0;
    qrCurrentFrequency := 0;
    qxTargetReached := TRUE;
END_METHOD

(* Остановка на текущей частоте *)
METHOD Hold
VAR_INPUT
END_VAR
    _rSetFrequency := _rCurrentFrequency;
    qxTargetReached := TRUE;
END_METHOD

END_FUNCTION_BLOCK