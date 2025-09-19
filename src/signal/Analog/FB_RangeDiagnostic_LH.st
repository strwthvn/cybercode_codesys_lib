FUNCTION_BLOCK FB_RangeDiagnostic_LH
VAR_INPUT
    irValue : REAL;                     // Входное значение для контроля
    irSetpointL : REAL;         		// Уставка предупреждения низкого уровня
    irSetpointLL : REAL;        		// Уставка аварии низкого уровня
    irSetpointH : REAL;         		// Уставка предупреждения высокого уровня
    irSetpointHH : REAL;        		// Уставка аварии высокого уровня
    ixEnable : BOOL := TRUE;            // Разрешение работы блока
    irHysteresis : REAL := 1.0;         // Гистерезис для предотвращения дребезга
END_VAR
VAR_OUTPUT
    quAlarmCode : E_AlarmSetpoints;     // Код текущего состояния аварии/предупреждения
    qxAlarmActive : BOOL;               // TRUE = активна любая авария или предупреждение
    qxWarningActive : BOOL;             // TRUE = активно предупреждение (L или H)
    qxCriticalActive : BOOL;            // TRUE = активна критическая авария (LL или HH)
END_VAR
VAR
    _uPreviousAlarmCode : E_AlarmSetpoints := E_AlarmSetpoints.Normal;  // Предыдущий код аварии
    _xValidSetpoints : BOOL := TRUE;                                    // Флаг корректности уставок
    _rHysteresisValue : REAL;                                          // Текущее значение гистерезиса
END_VAR

// =====================================
// ВАЛИДАЦИЯ УСТАВОК
// =====================================
ValidateSetpoints();

// =====================================
// ОСНОВНАЯ ЛОГИКА ОПРЕДЕЛЕНИЯ АВАРИЙ
// =====================================
IF ixEnable AND _xValidSetpoints THEN
    ProcessAlarms();
ELSE
    // При отключении или некорректных уставках - сброс в нормальное состояние
    quAlarmCode := E_AlarmSetpoints.Normal;
END_IF

// =====================================
// ОБНОВЛЕНИЕ ВЫХОДНЫХ СИГНАЛОВ
// =====================================
UpdateOutputs();

(* Валидация корректности уставок *)
METHOD PRIVATE ValidateSetpoints
VAR_INPUT
END_VAR
    // Проверяем логическую корректность уставок: LL < L < H < HH
    _xValidSetpoints := (irSetpointLL <= irSetpointL) AND 
                       (irSetpointL < irSetpointH) AND 
                       (irSetpointH <= irSetpointHH);
    
    // Гистерезис не может быть отрицательным
    IF irHysteresis < 0 THEN
        _rHysteresisValue := 0;
    ELSE
        _rHysteresisValue := irHysteresis;
    END_IF
END_METHOD

(* Основная логика обработки аварий с гистерезисом *)
METHOD PRIVATE ProcessAlarms
VAR_INPUT
END_VAR
    // Сохраняем предыдущее состояние
    _uPreviousAlarmCode := quAlarmCode;
    
    // Определяем новое состояние на основе текущего значения
    IF irValue <= irSetpointLL THEN
        quAlarmCode := E_AlarmSetpoints.LL;
    ELSIF irValue <= irSetpointL THEN
        quAlarmCode := E_AlarmSetpoints.L;
    ELSIF irValue >= irSetpointHH THEN
        quAlarmCode := E_AlarmSetpoints.HH;
    ELSIF irValue >= irSetpointH THEN
        quAlarmCode := E_AlarmSetpoints.H;
    ELSE
        // Проверяем гистерезис для возврата в нормальное состояние
        ApplyHysteresis();
    END_IF
END_METHOD

(* Применение гистерезиса для предотвращения дребезга *)
METHOD PRIVATE ApplyHysteresis
VAR_INPUT
END_VAR
    // Применяем гистерезис только при возврате к нормальному состоянию
    CASE _uPreviousAlarmCode OF
        E_AlarmSetpoints.LL:
            // Возврат из LL возможен только при превышении LL + гистерезис
            IF irValue > (irSetpointLL + _rHysteresisValue) THEN
                quAlarmCode := E_AlarmSetpoints.Normal;
            ELSE
                quAlarmCode := E_AlarmSetpoints.LL;
            END_IF
            
        E_AlarmSetpoints.L:
            // Возврат из L возможен только при превышении L + гистерезис
            IF irValue > (irSetpointL + _rHysteresisValue) THEN
                quAlarmCode := E_AlarmSetpoints.Normal;
            ELSE
                quAlarmCode := E_AlarmSetpoints.L;
            END_IF
            
        E_AlarmSetpoints.H:
            // Возврат из H возможен только при снижении ниже H - гистерезис
            IF irValue < (irSetpointH - _rHysteresisValue) THEN
                quAlarmCode := E_AlarmSetpoints.Normal;
            ELSE
                quAlarmCode := E_AlarmSetpoints.H;
            END_IF
            
        E_AlarmSetpoints.HH:
            // Возврат из HH возможен только при снижении ниже HH - гистерезис
            IF irValue < (irSetpointHH - _rHysteresisValue) THEN
                quAlarmCode := E_AlarmSetpoints.Normal;
            ELSE
                quAlarmCode := E_AlarmSetpoints.HH;
            END_IF
            
        E_AlarmSetpoints.Normal:
            // Остаемся в нормальном состоянии
            quAlarmCode := E_AlarmSetpoints.Normal;
    END_CASE
END_METHOD

(* Обновление выходных сигналов *)
METHOD PRIVATE UpdateOutputs
VAR_INPUT
END_VAR
    // Флаг активности любой аварии или предупреждения
    qxAlarmActive := (quAlarmCode <> E_AlarmSetpoints.Normal);
    
    // Флаг активности предупреждений (L, H)
    qxWarningActive := (quAlarmCode = E_AlarmSetpoints.L) OR 
                      (quAlarmCode = E_AlarmSetpoints.H);
    
    // Флаг активности критических аварий (LL, HH)
    qxCriticalActive := (quAlarmCode = E_AlarmSetpoints.LL) OR 
                       (quAlarmCode = E_AlarmSetpoints.HH);
END_METHOD

(* ========================================
   МЕТОДЫ ПОЛУЧЕНИЯ ИНФОРМАЦИИ
   ======================================== *)

(* Получение текущего кода аварии *)
METHOD GetAlarmCode : E_AlarmSetpoints
VAR_INPUT
END_VAR
    GetAlarmCode := quAlarmCode;
END_METHOD

(* Получение входного значения *)
METHOD GetCurrentValue : REAL
VAR_INPUT
END_VAR
    GetCurrentValue := irValue;
END_METHOD

(* Проверка состояния "в норме" *)
METHOD IsNormal : BOOL
VAR_INPUT
END_VAR
    IsNormal := (quAlarmCode = E_AlarmSetpoints.Normal);
END_METHOD

(* Проверка активности низких аварий (L или LL) *)
METHOD IsLowAlarm : BOOL
VAR_INPUT
END_VAR
    IsLowAlarm := (quAlarmCode = E_AlarmSetpoints.L) OR 
                  (quAlarmCode = E_AlarmSetpoints.LL);
END_METHOD

(* Проверка активности высоких аварий (H или HH) *)
METHOD IsHighAlarm : BOOL
VAR_INPUT
END_VAR
    IsHighAlarm := (quAlarmCode = E_AlarmSetpoints.H) OR 
                   (quAlarmCode = E_AlarmSetpoints.HH);
END_METHOD

(* Проверка корректности уставок *)
METHOD AreSetpointsValid : BOOL
VAR_INPUT
END_VAR
    AreSetpointsValid := _xValidSetpoints;
END_METHOD

(* Получение расстояния до ближайшей уставки *)
METHOD GetDistanceToNearestSetpoint : REAL
VAR_INPUT
END_VAR
VAR
    rDistanceToL : REAL;
    rDistanceToLL : REAL;
    rDistanceToH : REAL;
    rDistanceToHH : REAL;
    rMinDistance : REAL;
END_VAR
    rDistanceToL := ABS(irValue - irSetpointL);
    rDistanceToLL := ABS(irValue - irSetpointLL);
    rDistanceToH := ABS(irValue - irSetpointH);
    rDistanceToHH := ABS(irValue - irSetpointHH);
    
    rMinDistance := rDistanceToL;
    IF rDistanceToLL < rMinDistance THEN rMinDistance := rDistanceToLL; END_IF
    IF rDistanceToH < rMinDistance THEN rMinDistance := rDistanceToH; END_IF
    IF rDistanceToHH < rMinDistance THEN rMinDistance := rDistanceToHH; END_IF
    
    GetDistanceToNearestSetpoint := rMinDistance;
END_METHOD

(* ========================================
   МЕТОДЫ НАСТРОЙКИ
   ======================================== *)

(* Установка всех уставок одновременно *)
METHOD SetAllSetpoints
VAR_INPUT
    rLL : REAL;     // Авария низкого уровня
    rL : REAL;      // Предупреждение низкого уровня  
    rH : REAL;      // Предупреждение высокого уровня
    rHH : REAL;     // Авария высокого уровня
END_VAR
    // Проверяем корректность перед установкой
    IF (rLL <= rL) AND (rL < rH) AND (rH <= rHH) THEN
        irSetpointLL := rLL;
        irSetpointL := rL;
        irSetpointH := rH;
        irSetpointHH := rHH;
    END_IF
END_METHOD

(* Установка симметричных уставок относительно центрального значения *)
METHOD SetSymmetricSetpoints
VAR_INPUT
    rCenterValue : REAL;    // Центральное (номинальное) значение
    rWarningOffset : REAL;  // Смещение для предупреждений (L, H)
    rAlarmOffset : REAL;    // Смещение для аварий (LL, HH)
END_VAR
    IF (rWarningOffset >= 0) AND (rAlarmOffset >= rWarningOffset) THEN
        irSetpointL := rCenterValue - rWarningOffset;
        irSetpointLL := rCenterValue - rAlarmOffset;
        irSetpointH := rCenterValue + rWarningOffset;
        irSetpointHH := rCenterValue + rAlarmOffset;
    END_IF
END_METHOD

(* Установка уставок в процентах от диапазона *)
METHOD SetSetpointsPercent
VAR_INPUT
    rMinValue : REAL;       // Минимальное значение диапазона
    rMaxValue : REAL;       // Максимальное значение диапазона
    rLLPercent : REAL;      // Процент для LL (0..100)
    rLPercent : REAL;       // Процент для L (0..100)
    rHPercent : REAL;       // Процент для H (0..100)  
    rHHPercent : REAL;      // Процент для HH (0..100)
END_VAR
VAR
    rRange : REAL;
END_VAR
    IF (rMinValue < rMaxValue) AND 
       (rLLPercent <= rLPercent) AND (rLPercent < rHPercent) AND (rHPercent <= rHHPercent) AND
       (rLLPercent >= 0) AND (rHHPercent <= 100) THEN
        
        rRange := rMaxValue - rMinValue;
        irSetpointLL := rMinValue + (rRange * rLLPercent / 100.0);
        irSetpointL := rMinValue + (rRange * rLPercent / 100.0);
        irSetpointH := rMinValue + (rRange * rHPercent / 100.0);
        irSetpointHH := rMinValue + (rRange * rHHPercent / 100.0);
    END_IF
END_METHOD

(* ========================================
   СЕРВИСНЫЕ МЕТОДЫ
   ======================================== *)

(* Полный сброс состояния *)
METHOD Reset
VAR_INPUT
END_VAR
    quAlarmCode := E_AlarmSetpoints.Normal;
    _uPreviousAlarmCode := E_AlarmSetpoints.Normal;
    qxAlarmActive := FALSE;
    qxWarningActive := FALSE;
    qxCriticalActive := FALSE;
END_METHOD

(* Принудительная установка состояния "норма" *)
METHOD ForceNormal
VAR_INPUT
END_VAR
    quAlarmCode := E_AlarmSetpoints.Normal;
    _uPreviousAlarmCode := E_AlarmSetpoints.Normal;
    UpdateOutputs();
END_METHOD


END_FUNCTION_BLOCK