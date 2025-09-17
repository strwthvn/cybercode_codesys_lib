FUNCTION_BLOCK FB_AnalogSignal4_20mA EXTENDS FB_BasicAnalogSignal
VAR_INPUT
    rScaleMin : REAL := 0.0;        // Минимальное значение масштабируемого диапазона
    rScaleMax : REAL := 100.0;      // Максимальное значение масштабируемого диапазона
    xEnableRangeProtection : BOOL := TRUE;  // Включение защиты от выхода за диапазон
END_VAR
VAR_OUTPUT
END_VAR
VAR
    // Константы для токовой петли 4..20 мА
    _rCurrentMin : REAL := 4.0;     // Минимальный ток (мА)
    _rCurrentMax : REAL := 20.0;    // Максимальный ток (мА)
    
    // Состояние сигнала
    _xUnderrange : BOOL := FALSE;   // Сигнал ниже 4 мА
    _xOverrange : BOOL := FALSE;    // Сигнал выше 20 мА
    _xWireBreak : BOOL := FALSE;    // Обрыв линии (ток < 3.5 мА)
    _xOverload : BOOL := FALSE;     // Перегрузка (ток > 21 мА)
    
    // Пороговые значения для диагностики
    _rWireBreakThreshold : REAL := 3.5;    // Порог обрыва линии
    _rOverloadThreshold : REAL := 21.0;    // Порог перегрузки
END_VAR

// =====================================
// INPUT PROCESSING
// =====================================
ProcessRawValue();

// =====================================
// MAIN LOGIC  
// =====================================
DiagnoseCurrent();

(* Обработка исходного токового сигнала *)
METHOD ProcessRawValue
VAR_INPUT
END_VAR
VAR
    rNormalizedCurrent : REAL;
END_VAR
    // Нормализация тока в диапазон 0..1
    IF (_rCurrentMax - _rCurrentMin) <> 0 THEN
        rNormalizedCurrent := (GetRawValue() - _rCurrentMin) / (_rCurrentMax - _rCurrentMin);
    ELSE
        rNormalizedCurrent := 0.0;
    END_IF
    
    // Масштабирование к заданному диапазону
    IF xEnableRangeProtection THEN
        // С ограничением диапазона
        rNormalizedCurrent := ClampToRange01(rNormalizedCurrent);
    END_IF
    
    SetProcessedValue(rScaleMin + rNormalizedCurrent * (rScaleMax - rScaleMin));
END_METHOD

(* Диагностика токового сигнала *)
METHOD PRIVATE DiagnoseCurrent
VAR_INPUT
END_VAR
VAR
    rCurrentValue : REAL;
END_VAR
    rCurrentValue := GetRawValue();
    
    // Проверка на обрыв линии
    _xWireBreak := rCurrentValue < _rWireBreakThreshold;
    
    // Проверка на перегрузку
    _xOverload := rCurrentValue > _rOverloadThreshold;
    
    // Проверка на выход за рабочий диапазон 4..20 мА
    _xUnderrange := (rCurrentValue < _rCurrentMin) AND NOT _xWireBreak;
    _xOverrange := (rCurrentValue > _rCurrentMax) AND NOT _xOverload;
END_METHOD

(* Получение масштабированного значения с учетом ошибок *)
METHOD GetScaledValue : REAL
VAR_INPUT
END_VAR
    IF _xWireBreak OR _xOverload THEN
        // При критических ошибках возвращаем минимальное значение
        GetScaledValue := rScaleMin;
    ELSE
        GetScaledValue := GetProcessedValue();
    END_IF
END_METHOD

(* Получение процентного значения (0..100%) *)
METHOD GetPercentValue : REAL
VAR_INPUT
END_VAR
VAR
    rNormalized : REAL;
END_VAR
    IF (rScaleMax - rScaleMin) <> 0 THEN
        rNormalized := (GetProcessedValue() - rScaleMin) / (rScaleMax - rScaleMin);
        GetPercentValue := rNormalized * 100.0;
    ELSE
        GetPercentValue := 0.0;
    END_IF
END_METHOD

(* Проверка на обрыв линии *)
METHOD IsWireBreak : BOOL
VAR_INPUT
END_VAR
    IsWireBreak := _xWireBreak;
END_METHOD

(* Проверка на перегрузку *)
METHOD IsOverload : BOOL
VAR_INPUT
END_VAR
    IsOverload := _xOverload;
END_METHOD

(* Проверка на нижний предел диапазона *)
METHOD IsUnderrange : BOOL
VAR_INPUT
END_VAR
    IsUnderrange := _xUnderrange;
END_METHOD

(* Проверка на верхний предел диапазона *)
METHOD IsOverrange : BOOL
VAR_INPUT
END_VAR
    IsOverrange := _xOverrange;
END_METHOD

(* Проверка на любую ошибку *)
METHOD HasError : BOOL
VAR_INPUT
END_VAR
    HasError := _xWireBreak OR _xOverload OR _xUnderrange OR _xOverrange;
END_METHOD

(* Установка масштабируемого диапазона *)
METHOD SetScaleRange
VAR_INPUT
    rMin : REAL;
    rMax : REAL;
END_VAR
    IF rMin < rMax THEN
        rScaleMin := rMin;
        rScaleMax := rMax;
    END_IF
END_METHOD

(* Получение минимального масштабируемого значения *)
METHOD GetScaleMin : REAL
VAR_INPUT
END_VAR
    GetScaleMin := rScaleMin;
END_METHOD

(* Получение максимального масштабируемого значения *)
METHOD GetScaleMax : REAL
VAR_INPUT
END_VAR
    GetScaleMax := rScaleMax;
END_METHOD

(* Сброс всех ошибок и состояний *)
METHOD Reset
VAR_INPUT
END_VAR
    // Вызов родительского сброса
    SUPER^.Reset();
    
    // Сброс локальных флагов
    _xUnderrange := FALSE;
    _xOverrange := FALSE;
    _xWireBreak := FALSE;
    _xOverload := FALSE;
END_METHOD

(* ========================================
   ЗАЩИЩЕННЫЕ МЕТОДЫ
   ======================================== *)

(* Ограничение значения в диапазоне 0..1 *)
METHOD PROTECTED ClampToRange01 : REAL
VAR_INPUT
    rValue : REAL;
END_VAR
    IF rValue < 0.0 THEN
        ClampToRange01 := 0.0;
    ELSIF rValue > 1.0 THEN
        ClampToRange01 := 1.0;
    ELSE
        ClampToRange01 := rValue;
    END_IF
END_METHOD

END_FUNCTION_BLOCK