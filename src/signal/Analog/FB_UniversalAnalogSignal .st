FUNCTION_BLOCK FB_UniversalAnalogSignal EXTENDS FB_BasicAnalogSignal
VAR_INPUT
    // Диапазон входного аналогового сигнала
    rInputMin : REAL := 0.0;        // Минимальное значение входного сигнала
    rInputMax : REAL := 10.0;       // Максимальное значение входного сигнала
    
    // Диапазон масштабирования (выходные инженерные единицы)
    rScaleMin : REAL := 0.0;        // Минимальное значение масштабированного диапазона
    rScaleMax : REAL := 100.0;      // Максимальное значение масштабированного диапазона
    
    // Настройки
    xEnableRangeProtection : BOOL := TRUE;  // Включение защиты от выхода за диапазон
    xEnableDiagnostics : BOOL := TRUE;      // Включение диагностики сигнала
END_VAR
VAR_OUTPUT
END_VAR
VAR
    // Диагностика сигнала
    _xSignalUnderrange : BOOL := FALSE;     // Сигнал ниже минимума входного диапазона
    _xSignalOverrange : BOOL := FALSE;      // Сигнал выше максимума входного диапазона
    
    // Пороги для расширенной диагностики (в % от диапазона)
    _rUnderrangeThreshold : REAL := 5.0;    // Порог для определения критически низкого сигнала
    _rOverrangeThreshold : REAL := 5.0;     // Порог для определения критически высокого сигнала
    
    // Расширенная диагностика
    _xCriticalLow : BOOL := FALSE;          // Критически низкий сигнал
    _xCriticalHigh : BOOL := FALSE;         // Критически высокий сигнал
    
    // Вычисленные значения
    _rNormalizedValue : REAL := 0.0;        // Нормализованное значение (0..1)
    _rPercentValue : REAL := 0.0;           // Процентное значение (0..100%)
END_VAR

// =====================================
// ОБРАБОТКА ВХОДНОГО СИГНАЛА
// =====================================
ProcessRawValue();

// =====================================
// ДИАГНОСТИКА
// =====================================
IF xEnableDiagnostics THEN
    DiagnoseSignal();
END_IF

// =====================================
// ВЫЧИСЛЕНИЕ ДОПОЛНИТЕЛЬНЫХ ЗНАЧЕНИЙ
// =====================================
CalculateAdditionalValues();

(* Обработка исходного сигнала и масштабирование *)
METHOD ProcessRawValue
VAR_INPUT
END_VAR
VAR
    rInputRange : REAL;
    rScaleRange : REAL;
    rRawSignal : REAL;
END_VAR
    rRawSignal := GetRawValue();
    
    // Вычисление диапазонов
    rInputRange := rInputMax - rInputMin;
    rScaleRange := rScaleMax - rScaleMin;
    
    // Проверка корректности диапазонов
    IF (rInputRange = 0) OR (rScaleRange = 0) THEN
        SetProcessedValue(rScaleMin);
        RETURN;
    END_IF
    
    // Нормализация входного сигнала (приведение к диапазону 0..1)
    _rNormalizedValue := (rRawSignal - rInputMin) / rInputRange;
    
    // Применение ограничений если включена защита
    IF xEnableRangeProtection THEN
        _rNormalizedValue := LimitTo01(_rNormalizedValue);
    END_IF
    
    // Масштабирование к выходному диапазону
    SetProcessedValue(rScaleMin + _rNormalizedValue * rScaleRange);
END_METHOD

(* Диагностика входного сигнала *)
METHOD PRIVATE DiagnoseSignal
VAR_INPUT
END_VAR
VAR
    rRawSignal : REAL;
    rInputRange : REAL;
    rCriticalLowLimit : REAL;
    rCriticalHighLimit : REAL;
END_VAR
    rRawSignal := GetRawValue();
    rInputRange := rInputMax - rInputMin;
    
    // Базовая диагностика диапазона
    _xSignalUnderrange := rRawSignal < rInputMin;
    _xSignalOverrange := rRawSignal > rInputMax;
    
    // Расширенная диагностика (критические пределы)
    IF rInputRange <> 0 THEN
        // Вычисление критических порогов
        rCriticalLowLimit := rInputMin - (rInputRange * _rUnderrangeThreshold / 100.0);
        rCriticalHighLimit := rInputMax + (rInputRange * _rOverrangeThreshold / 100.0);
        
        _xCriticalLow := rRawSignal < rCriticalLowLimit;
        _xCriticalHigh := rRawSignal > rCriticalHighLimit;
    END_IF
END_METHOD

(* Вычисление дополнительных значений *)
METHOD PRIVATE CalculateAdditionalValues
VAR_INPUT
END_VAR
    // Процентное значение относительно масштабированного диапазона
    IF (rScaleMax - rScaleMin) <> 0 THEN
        _rPercentValue := ((GetProcessedValue() - rScaleMin) / (rScaleMax - rScaleMin)) * 100.0;
    ELSE
        _rPercentValue := 0.0;
    END_IF
END_METHOD

(* ========================================
   МЕТОДЫ ПОЛУЧЕНИЯ ЗНАЧЕНИЙ
   ======================================== *)

(* Получение масштабированного значения *)
METHOD GetScaledValue : REAL
VAR_INPUT
END_VAR
    // При критических ошибках возвращаем безопасное значение
    IF _xCriticalLow OR _xCriticalHigh THEN
        GetScaledValue := rScaleMin;
    ELSE
        GetScaledValue := GetProcessedValue();
    END_IF
END_METHOD

(* Получение нормализованного значения (0..1) *)
METHOD GetNormalizedValue : REAL
VAR_INPUT
END_VAR
    GetNormalizedValue := _rNormalizedValue;
END_METHOD

(* Получение процентного значения *)
METHOD GetPercentValue : REAL
VAR_INPUT
END_VAR
    GetPercentValue := _rPercentValue;
END_METHOD

(* Получение процента относительно входного диапазона *)
METHOD GetInputRangePercent : REAL
VAR_INPUT
END_VAR
    IF (rInputMax - rInputMin) <> 0 THEN
        GetInputRangePercent := ((GetRawValue() - rInputMin) / (rInputMax - rInputMin)) * 100.0;
    ELSE
        GetInputRangePercent := 0.0;
    END_IF
END_METHOD

(* ========================================
   МЕТОДЫ ДИАГНОСТИКИ
   ======================================== *)

(* Проверка выхода за нижний предел *)
METHOD IsUnderrange : BOOL
VAR_INPUT
END_VAR
    IsUnderrange := _xSignalUnderrange;
END_METHOD

(* Проверка выхода за верхний предел *)
METHOD IsOverrange : BOOL
VAR_INPUT
END_VAR
    IsOverrange := _xSignalOverrange;
END_METHOD

(* Проверка критически низкого сигнала *)
METHOD IsCriticalLow : BOOL
VAR_INPUT
END_VAR
    IsCriticalLow := _xCriticalLow;
END_METHOD

(* Проверка критически высокого сигнала *)
METHOD IsCriticalHigh : BOOL
VAR_INPUT
END_VAR
    IsCriticalHigh := _xCriticalHigh;
END_METHOD

(* Проверка на любую ошибку *)
METHOD HasError : BOOL
VAR_INPUT
END_VAR
    HasError := _xSignalUnderrange OR _xSignalOverrange OR _xCriticalLow OR _xCriticalHigh;
END_METHOD

(* Проверка на критическую ошибку *)
METHOD HasCriticalError : BOOL
VAR_INPUT
END_VAR
    HasCriticalError := _xCriticalLow OR _xCriticalHigh;
END_METHOD

(* Проверка нахождения в допустимом диапазоне *)
METHOD IsInValidRange : BOOL
VAR_INPUT
END_VAR
    IsInValidRange := NOT (_xSignalUnderrange OR _xSignalOverrange);
END_METHOD

(* ========================================
   МЕТОДЫ НАСТРОЙКИ
   ======================================== *)

(* Установка входного диапазона *)
METHOD SetInputRange
VAR_INPUT
    rMin : REAL;
    rMax : REAL;
END_VAR
    IF rMin < rMax THEN
        rInputMin := rMin;
        rInputMax := rMax;
    END_IF
END_METHOD

(* Установка диапазона масштабирования *)
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

(* Установка порогов критической диагностики *)
METHOD SetDiagnosticThresholds
VAR_INPUT
    rUnderrangePercent : REAL;  // Процент от диапазона для критически низкого
    rOverrangePercent : REAL;   // Процент от диапазона для критически высокого
END_VAR
    IF (rUnderrangePercent >= 0) AND (rUnderrangePercent <= 100) THEN
        _rUnderrangeThreshold := rUnderrangePercent;
    END_IF
    
    IF (rOverrangePercent >= 0) AND (rOverrangePercent <= 100) THEN
        _rOverrangeThreshold := rOverrangePercent;
    END_IF
END_METHOD

(* Конфигурация для стандартных типов сигналов *)
METHOD ConfigureAs4_20mA
VAR_INPUT
    rProcessMin : REAL := 0.0;   // Минимальное значение процесса
    rProcessMax : REAL := 100.0; // Максимальное значение процесса
END_VAR
    SetInputRange(4.0, 20.0);
    SetScaleRange(rProcessMin, rProcessMax);
    SetDiagnosticThresholds(12.5, 5.0);  // 3.5мА и 21мА соответственно
END_METHOD

METHOD ConfigureAs0_10V
VAR_INPUT
    rProcessMin : REAL := 0.0;
    rProcessMax : REAL := 100.0;
END_VAR
    SetInputRange(0.0, 10.0);
    SetScaleRange(rProcessMin, rProcessMax);
    SetDiagnosticThresholds(5.0, 5.0);
END_METHOD

METHOD ConfigureAs0_20mA
VAR_INPUT
    rProcessMin : REAL := 0.0;
    rProcessMax : REAL := 100.0;
END_VAR
    SetInputRange(0.0, 20.0);
    SetScaleRange(rProcessMin, rProcessMax);
    SetDiagnosticThresholds(5.0, 5.0);
END_METHOD

METHOD ConfigureAsPt100
VAR_INPUT
    rTempMin : REAL := -50.0;   // Минимальная температура
    rTempMax : REAL := 200.0;   // Максимальная температура
END_VAR
    // Примерные значения сопротивления для Pt100
    SetInputRange(80.31, 175.86);  // Сопротивление при -50°C и 200°C
    SetScaleRange(rTempMin, rTempMax);
    SetDiagnosticThresholds(2.0, 2.0);
END_METHOD

(* ========================================
   МЕТОДЫ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О КОНФИГУРАЦИИ
   ======================================== *)

(* Получение минимума входного диапазона *)
METHOD GetInputMin : REAL
VAR_INPUT
END_VAR
    GetInputMin := rInputMin;
END_METHOD

(* Получение максимума входного диапазона *)
METHOD GetInputMax : REAL
VAR_INPUT
END_VAR
    GetInputMax := rInputMax;
END_METHOD

(* Получение минимума масштабированного диапазона *)
METHOD GetScaleMin : REAL
VAR_INPUT
END_VAR
    GetScaleMin := rScaleMin;
END_METHOD

(* Получение максимума масштабированного диапазона *)
METHOD GetScaleMax : REAL
VAR_INPUT
END_VAR
    GetScaleMax := rScaleMax;
END_METHOD

(* Получение размаха входного диапазона *)
METHOD GetInputSpan : REAL
VAR_INPUT
END_VAR
    GetInputSpan := rInputMax - rInputMin;
END_METHOD

(* Получение размаха масштабированного диапазона *)
METHOD GetScaleSpan : REAL
VAR_INPUT
END_VAR
    GetScaleSpan := rScaleMax - rScaleMin;
END_METHOD

(* ========================================
   ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
   ======================================== *)

(* Полный сброс состояния *)
METHOD Reset
VAR_INPUT
END_VAR
    // Вызов родительского метода
    SUPER^.Reset();
    
    // Сброс локальных флагов диагностики
    _xSignalUnderrange := FALSE;
    _xSignalOverrange := FALSE;
    _xCriticalLow := FALSE;
    _xCriticalHigh := FALSE;
    
    // Сброс вычисленных значений
    _rNormalizedValue := 0.0;
    _rPercentValue := 0.0;
END_METHOD

(* Ограничение значения в диапазоне 0..1 *)
METHOD PRIVATE LimitTo01 : REAL
VAR_INPUT
    rValue : REAL;
END_VAR
    IF rValue < 0.0 THEN
        LimitTo01 := 0.0;
    ELSIF rValue > 1.0 THEN
        LimitTo01 := 1.0;
    ELSE
        LimitTo01 := rValue;
    END_IF
END_METHOD

END_FUNCTION_BLOCK