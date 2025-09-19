FUNCTION_BLOCK FB_NumericChangeDetector
VAR_INPUT
    irValue : REAL;          // Входное числовое значение для мониторинга
END_VAR
VAR_OUTPUT
    qxChangeDetected : BOOL; // Импульс при обнаружении изменения значения
END_VAR
VAR
    _rPreviousValue : REAL := 0.0;    // Предыдущее значение для сравнения
    _xFirstCycle : BOOL := TRUE;      // Флаг первого цикла выполнения
    _rt_Change : R_TRIG;              // Триггер для генерации импульса
    _xValueChanged : BOOL := FALSE;   // Внутренний флаг изменения
END_VAR

// Пропускаем первый цикл для корректной инициализации
IF _xFirstCycle THEN
    _rPreviousValue := irValue;
    _xFirstCycle := FALSE;
    _xValueChanged := FALSE;
ELSE
    // Проверяем изменение значения
    IF _rPreviousValue <> irValue THEN
        _xValueChanged := TRUE;
        _rPreviousValue := irValue;
    ELSE
        _xValueChanged := FALSE;
    END_IF
END_IF

// Генерируем импульс при изменении через R_TRIG
_rt_Change(CLK := _xValueChanged);
qxChangeDetected := _rt_Change.Q;

(* Получение текущего отслеживаемого значения *)
METHOD GetCurrentValue : REAL
VAR_INPUT
END_VAR
    GetCurrentValue := irValue;
END_METHOD

(* Получение предыдущего значения *)
METHOD GetPreviousValue : REAL
VAR_INPUT
END_VAR
    GetPreviousValue := _rPreviousValue;
END_METHOD

(* Получение разности между текущим и предыдущим значением *)
METHOD GetValueDifference : REAL
VAR_INPUT
END_VAR
    GetValueDifference := irValue - _rPreviousValue;
END_METHOD

(* Проверка увеличения значения *)
METHOD IsValueIncreased : BOOL
VAR_INPUT
END_VAR
    IsValueIncreased := _xValueChanged AND (irValue > _rPreviousValue);
END_METHOD

(* Проверка уменьшения значения *)
METHOD IsValueDecreased : BOOL
VAR_INPUT
END_VAR
    IsValueDecreased := _xValueChanged AND (irValue < _rPreviousValue);
END_METHOD

(* Сброс детектора изменений *)
METHOD Reset
VAR_INPUT
END_VAR
    _rPreviousValue := irValue;
    _xFirstCycle := TRUE;
    _xValueChanged := FALSE;
    _rt_Change(CLK := FALSE);
END_METHOD

END_FUNCTION_BLOCK