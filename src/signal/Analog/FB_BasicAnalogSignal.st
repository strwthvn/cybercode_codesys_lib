FUNCTION_BLOCK ABSTRACT FB_BasicAnalogSignal
VAR_INPUT
    irRawValue : REAL;          // Исходное значение аналогового сигнала
END_VAR
VAR_OUTPUT
END_VAR
VAR
    _rProcessedValue : REAL;    // Обработанное значение сигнала
    _rMinValue : REAL := 0.0;   // Минимальное допустимое значение
    _rMaxValue : REAL := 100.0; // Максимальное допустимое значение
    _xOutOfRange : BOOL := FALSE; // Флаг выхода за пределы диапазона
END_VAR

// =====================================
// INPUT PROCESSING
// =====================================
ProcessRawValue();

// =====================================
// MAIN LOGIC
// =====================================
ValidateRange();

(* Получение исходного значения *)
METHOD GetRawValue : REAL
VAR_INPUT
END_VAR
    GetRawValue := irRawValue;
END_METHOD

(* Получение обработанного значения *)
METHOD GetProcessedValue : REAL
VAR_INPUT
END_VAR
    GetProcessedValue := _rProcessedValue;
END_METHOD

(* Получение статуса выхода за пределы диапазона *)
METHOD IsOutOfRange : BOOL
VAR_INPUT
END_VAR
    IsOutOfRange := _xOutOfRange;
END_METHOD

(* Получение минимального значения диапазона *)
METHOD GetMinValue : REAL
VAR_INPUT
END_VAR
    GetMinValue := _rMinValue;
END_METHOD

(* Получение максимального значения диапазона *)
METHOD GetMaxValue : REAL
VAR_INPUT
END_VAR
    GetMaxValue := _rMaxValue;
END_METHOD

(* Установка диапазона допустимых значений *)
METHOD SetRange
VAR_INPUT
    rMinValue : REAL;
    rMaxValue : REAL;
END_VAR
    IF rMinValue < rMaxValue THEN
        _rMinValue := rMinValue;
        _rMaxValue := rMaxValue;
    END_IF
END_METHOD

(* Проверка принадлежности значения к диапазону *)
METHOD IsInRange : BOOL
VAR_INPUT
    rValue : REAL;
END_VAR
    IsInRange := (rValue >= _rMinValue) AND (rValue <= _rMaxValue);
END_METHOD

(* Ограничение значения в пределах диапазона *)
METHOD ClampToRange : REAL
VAR_INPUT
    rValue : REAL;
END_VAR
    IF rValue < _rMinValue THEN
        ClampToRange := _rMinValue;
    ELSIF rValue > _rMaxValue THEN
        ClampToRange := _rMaxValue;
    ELSE
        ClampToRange := rValue;
    END_IF
END_METHOD

(* Сброс состояния функционального блока *)
METHOD Reset
VAR_INPUT
END_VAR
    _rProcessedValue := 0.0;
    _xOutOfRange := FALSE;
END_METHOD

(* ========================================
   АБСТРАКТНЫЕ МЕТОДЫ (должны быть переопределены в наследниках)
   ======================================== *)

(* Обработка исходного значения (абстрактный метод) *)
METHOD ABSTRACT ProcessRawValue
VAR_INPUT
END_VAR
END_METHOD

(* ========================================
   ЗАЩИЩЕННЫЕ МЕТОДЫ (для использования в наследниках)
   ======================================== *)

(* Проверка диапазона значений *)
METHOD PROTECTED ValidateRange
VAR_INPUT
END_VAR
    _xOutOfRange := NOT IsInRange(_rProcessedValue);
END_METHOD

(* Установка обработанного значения *)
METHOD PROTECTED SetProcessedValue
VAR_INPUT
    rValue : REAL;
END_VAR
    _rProcessedValue := rValue;
END_METHOD

END_FUNCTION_BLOCK