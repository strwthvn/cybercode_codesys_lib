# Документация функционального блока FB_RangeDiagnostic_LH

## Обзор

### Назначение

Функциональный блок `FB_RangeDiagnostic_LH` предназначен для мониторинга аналогового значения и определения уровня аварий и предупреждений на основе четырех настраиваемых уставок. Блок реализует стандартную промышленную логику контроля с уровнями LL (авария низкого уровня), L (предупреждение низкого уровня), H (предупреждение высокого уровня) и HH (авария высокого уровня) с поддержкой гистерезиса для предотвращения дребезга.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`irValue`|`REAL`|Входное значение для контроля|
|`irSetpointL`|`REAL`|Уставка предупреждения низкого уровня|
|`irSetpointLL`|`REAL`|Уставка аварии низкого уровня|
|`irSetpointH`|`REAL`|Уставка предупреждения высокого уровня|
|`irSetpointHH`|`REAL`|Уставка аварии высокого уровня|
|`ixEnable`|`BOOL`|Разрешение работы блока (по умолчанию TRUE)|
|`irHysteresis`|`REAL`|Гистерезис для предотвращения дребезга (по умолчанию 1.0)|

### Выходные параметры (VAR_OUTPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`quAlarmCode`|`E_AlarmSetpoints`|Код текущего состояния аварии/предупреждения|
|`qxAlarmActive`|`BOOL`|TRUE = активна любая авария или предупреждение|
|`qxWarningActive`|`BOOL`|TRUE = активно предупреждение (L или H)|
|`qxCriticalActive`|`BOOL`|TRUE = активна критическая авария (LL или HH)|

### Внутренние переменные (VAR)

|Переменная|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`_uPreviousAlarmCode`|`E_AlarmSetpoints`|Normal|Предыдущий код аварии для гистерезиса|
|`_xValidSetpoints`|`BOOL`|TRUE|Флаг корректности уставок|
|`_rHysteresisValue`|`REAL`|-|Текущее значение гистерезиса|

### Перечисление E_AlarmSetpoints

```pascal
TYPE E_AlarmSetpoints :
(
    Normal      := 0,   // Нормальное состояние
    L           := 1,   // Предупреждение низкого уровня
    H           := 2,   // Предупреждение высокого уровня
    LL          := 3,   // Авария низкого уровня
    HH          := 4    // Авария высокого уровня
);
END_TYPE
```

## Принцип работы

### Логика определения состояний

1. **Валидация уставок**: Проверка корректности порядка уставок (LL ≤ L < H ≤ HH)
2. **Определение состояния**: Сравнение входного значения с уставками
3. **Применение гистерезиса**: Предотвращение дребезга при возврате к нормальному состоянию
4. **Обновление выходов**: Установка соответствующих флагов активности

### Приоритет состояний

Состояния определяются по следующему приоритету (от высшего к низшему):

1. **HH (Авария высокого уровня)**: `irValue >= irSetpointHH`
2. **LL (Авария низкого уровня)**: `irValue <= irSetpointLL`
3. **H (Предупреждение высокого уровня)**: `irValue >= irSetpointH`
4. **L (Предупреждение низкого уровня)**: `irValue <= irSetpointL`
5. **Normal (Норма)**: значение между L и H

### Гистерезис

Гистерезис применяется только при возврате из аварийного/предупредительного состояния в нормальное:

- **Из LL**: возврат при `irValue > (irSetpointLL + irHysteresis)`
- **Из L**: возврат при `irValue > (irSetpointL + irHysteresis)`
- **Из H**: возврат при `irValue < (irSetpointH - irHysteresis)`
- **Из HH**: возврат при `irValue < (irSetpointHH - irHysteresis)`

## Методы

### Методы получения информации

#### GetAlarmCode

**Описание:** Возвращает текущий код аварии/предупреждения.

**Прототип:**

```pascal
METHOD GetAlarmCode : E_AlarmSetpoints
```

**Возвращаемое значение:** Текущее состояние (Normal, L, H, LL, HH)

---

#### GetCurrentValue

**Описание:** Возвращает текущее входное значение.

**Прототип:**

```pascal
METHOD GetCurrentValue : REAL
```

**Возвращаемое значение:** Значение параметра `irValue`

---

#### IsNormal

**Описание:** Проверяет нахождение в нормальном состоянии.

**Прототип:**

```pascal
METHOD IsNormal : BOOL
```

**Возвращаемое значение:**
- TRUE = состояние "норма"
- FALSE = активно предупреждение или авария

---

#### IsLowAlarm

**Описание:** Проверяет активность низких аварий (L или LL).

**Прототип:**

```pascal
METHOD IsLowAlarm : BOOL
```

**Возвращаемое значение:**
- TRUE = активна L или LL
- FALSE = нет низких аварий

---

#### IsHighAlarm

**Описание:** Проверяет активность высоких аварий (H или HH).

**Прототип:**

```pascal
METHOD IsHighAlarm : BOOL
```

**Возвращаемое значение:**
- TRUE = активна H или HH
- FALSE = нет высоких аварий

---

#### AreSetpointsValid

**Описание:** Проверяет корректность настройки уставок.

**Прототип:**

```pascal
METHOD AreSetpointsValid : BOOL
```

**Возвращаемое значение:**
- TRUE = уставки корректны (LL ≤ L < H ≤ HH)
- FALSE = некорректная конфигурация уставок

---

#### GetDistanceToNearestSetpoint

**Описание:** Возвращает расстояние до ближайшей уставки.

**Прототип:**

```pascal
METHOD GetDistanceToNearestSetpoint : REAL
```

**Возвращаемое значение:** Минимальное расстояние до любой из четырех уставок

### Методы настройки

#### SetAllSetpoints

**Описание:** Устанавливает все четыре уставки одновременно с проверкой корректности.

**Прототип:**

```pascal
METHOD SetAllSetpoints
VAR_INPUT
    rLL : REAL;     // Авария низкого уровня
    rL : REAL;      // Предупреждение низкого уровня  
    rH : REAL;      // Предупреждение высокого уровня
    rHH : REAL;     // Авария высокого уровня
END_VAR
```

**Функциональность:** Устанавливает уставки только при соблюдении условия rLL ≤ rL < rH ≤ rHH

---

#### SetSymmetricSetpoints

**Описание:** Устанавливает симметричные уставки относительно центрального значения.

**Прототип:**

```pascal
METHOD SetSymmetricSetpoints
VAR_INPUT
    rCenterValue : REAL;    // Центральное (номинальное) значение
    rWarningOffset : REAL;  // Смещение для предупреждений (L, H)
    rAlarmOffset : REAL;    // Смещение для аварий (LL, HH)
END_VAR
```

**Пример использования:**
```pascal
// Для температуры с номиналом 50°C, предупреждения ±5°C, аварии ±10°C
fbTempDiag.SetSymmetricSetpoints(50.0, 5.0, 10.0);
// Результат: LL=40, L=45, H=55, HH=60
```

---

#### SetSetpointsPercent

**Описание:** Устанавливает уставки в процентах от заданного диапазона.

**Прототип:**

```pascal
METHOD SetSetpointsPercent
VAR_INPUT
    rMinValue : REAL;       // Минимальное значение диапазона
    rMaxValue : REAL;       // Максимальное значение диапазона
    rLLPercent : REAL;      // Процент для LL (0..100)
    rLPercent : REAL;       // Процент для L (0..100)
    rHPercent : REAL;       // Процент для H (0..100)  
    rHHPercent : REAL;      // Процент для HH (0..100)
END_VAR
```

**Пример использования:**
```pascal
// Для давления 0-10 бар: LL=5%, L=10%, H=90%, HH=95%
fbPressureDiag.SetSetpointsPercent(0.0, 10.0, 5.0, 10.0, 90.0, 95.0);
// Результат: LL=0.5, L=1.0, H=9.0, HH=9.5 бар
```

### Сервисные методы

#### Reset

**Описание:** Полный сброс состояния функционального блока.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Устанавливает состояние в Normal
- Сбрасывает все выходные флаги
- Очищает историю предыдущих состояний

---

#### ForceNormal

**Описание:** Принудительная установка состояния "норма".

**Прототип:**

```pascal
METHOD ForceNormal
```

**Функциональность:**
- Принудительно устанавливает состояние Normal
- Обновляет все выходные параметры
- Используется для тестирования или восстановления после обслуживания

## Типовые сценарии использования

### Контроль температуры

```pascal
PROGRAM PRG_Main
VAR
    fbTempDiagnostic : FB_RangeDiagnostic_LH;
    rTemperature : REAL;          // Текущая температура
    xTempAlarm : BOOL;            // Общий флаг аварии
    xTempWarning : BOOL;          // Общий флаг предупреждения
    xTempCritical : BOOL;         // Критическая авария
    eTempState : E_AlarmSetpoints; // Состояние температуры
END_VAR

// Настройка уставок температуры для процесса 20-80°C
fbTempDiagnostic.SetAllSetpoints(
    rLL := 15.0,    // Критически низкая температура
    rL := 20.0,     // Низкая температура  
    rH := 80.0,     // Высокая температура
    rHH := 85.0     // Критически высокая температура
);

fbTempDiagnostic(
    irValue := rTemperature,
    ixEnable := TRUE,
    irHysteresis := 2.0     // Гистерезис 2°C
);

// Получение состояний
xTempAlarm := fbTempDiagnostic.qxAlarmActive;
xTempWarning := fbTempDiagnostic.qxWarningActive;
xTempCritical := fbTempDiagnostic.qxCriticalActive;
eTempState := fbTempDiagnostic.GetAlarmCode();

// Обработка различных состояний
CASE eTempState OF
    E_AlarmSetpoints.Normal:
        // Нормальная работа
        sStatus := 'Temperature OK';
        
    E_AlarmSetpoints.L:
        // Низкая температура - предупреждение
        sStatus := 'Temperature LOW - Check heating';
        
    E_AlarmSetpoints.H:
        // Высокая температура - предупреждение  
        sStatus := 'Temperature HIGH - Check cooling';
        
    E_AlarmSetpoints.LL:
        // Критически низкая - авария
        sStatus := 'ALARM: Temperature CRITICALLY LOW';
        xEmergencyStop := TRUE;
        
    E_AlarmSetpoints.HH:
        // Критически высокая - авария
        sStatus := 'ALARM: Temperature CRITICALLY HIGH';
        xEmergencyStop := TRUE;
END_CASE
```

### Мониторинг давления

```pascal
VAR
    fbPressureDiag : FB_RangeDiagnostic_LH;
    rPressure : REAL;             // Текущее давление (бар)
    stPressureStatus : ST_PressureStatus;
    rDistanceToLimit : REAL;      // Расстояние до ближайшей уставки
END_VAR

TYPE ST_PressureStatus :
STRUCT
    xNormal : BOOL;               // Нормальное давление
    xLowWarning : BOOL;           // Предупреждение низкого давления
    xHighWarning : BOOL;          // Предупреждение высокого давления
    xLowAlarm : BOOL;             // Авария низкого давления
    xHighAlarm : BOOL;            // Авария высокого давления
    sStatusText : STRING;         // Текстовое описание
    eCurrentState : E_AlarmSetpoints;
END_STRUCT
END_TYPE

// Симметричная настройка относительно номинального давления 5 бар
fbPressureDiag.SetSymmetricSetpoints(
    rCenterValue := 5.0,    // Номинальное давление
    rWarningOffset := 1.0,  // Предупреждения при ±1 бар
    rAlarmOffset := 1.5     // Аварии при ±1.5 бар
);
// Результат: LL=3.5, L=4.0, H=6.0, HH=6.5 бар

fbPressureDiag(
    irValue := rPressure,
    ixEnable := TRUE,
    irHysteresis := 0.1     // Гистерезис 0.1 бар
);

// Детальный анализ состояния
stPressureStatus.eCurrentState := fbPressureDiag.GetAlarmCode();
stPressureStatus.xNormal := fbPressureDiag.IsNormal();
stPressureStatus.xLowWarning := (stPressureStatus.eCurrentState = E_AlarmSetpoints.L);
stPressureStatus.xHighWarning := (stPressureStatus.eCurrentState = E_AlarmSetpoints.H);
stPressureStatus.xLowAlarm := (stPressureStatus.eCurrentState = E_AlarmSetpoints.LL);
stPressureStatus.xHighAlarm := (stPressureStatus.eCurrentState = E_AlarmSetpoints.HH);

// Расчет расстояния до критической ситуации
rDistanceToLimit := fbPressureDiag.GetDistanceToNearestSetpoint();

// Формирование статусного сообщения
CASE stPressureStatus.eCurrentState OF
    E_AlarmSetpoints.Normal:
        stPressureStatus.sStatusText := 'Pressure Normal';
        
    E_AlarmSetpoints.L:
        stPressureStatus.sStatusText := 'WARNING: Pressure Low';
        
    E_AlarmSetpoints.H:
        stPressureStatus.sStatusText := 'WARNING: Pressure High';
        
    E_AlarmSetpoints.LL:
        stPressureStatus.sStatusText := 'ALARM: Pressure Critically Low';
        
    E_AlarmSetpoints.HH:
        stPressureStatus.sStatusText := 'ALARM: Pressure Critically High';
END_CASE
```

### Контроль уровня с процентными уставками

```pascal
VAR
    fbLevelDiag : FB_RangeDiagnostic_LH;
    rTankLevel : REAL;            // Уровень в баке (0-100%)
    xLevelOK : BOOL;              // Уровень в норме
    xPumpStart : BOOL;            // Запуск насоса подачи
    xPumpStop : BOOL;             // Остановка насоса
    xAlarmLowLevel : BOOL;        // Авария низкого уровня
    xAlarmHighLevel : BOOL;       // Авария высокого уровня
END_VAR

// Настройка уставок в процентах для бака 0-100%
fbLevelDiag.SetSetpointsPercent(
    rMinValue := 0.0,       // Минимум диапазона
    rMaxValue := 100.0,     // Максимум диапазона
    rLLPercent := 5.0,      // Критически низкий уровень - 5%
    rLPercent := 15.0,      // Низкий уровень - 15%
    rHPercent := 85.0,      // Высокий уровень - 85%
    rHHPercent := 95.0      // Критически высокий уровень - 95%
);

fbLevelDiag(
    irValue := rTankLevel,
    ixEnable := TRUE,
    irHysteresis := 2.0     // Гистерезис 2%
);

// Логика управления насосами
xLevelOK := fbLevelDiag.IsNormal();
xPumpStart := (fbLevelDiag.GetAlarmCode() = E_AlarmSetpoints.L);  // Запуск при низком уровне
xPumpStop := (fbLevelDiag.GetAlarmCode() = E_AlarmSetpoints.H);   // Остановка при высоком уровне
xAlarmLowLevel := (fbLevelDiag.GetAlarmCode() = E_AlarmSetpoints.LL);
xAlarmHighLevel := (fbLevelDiag.GetAlarmCode() = E_AlarmSetpoints.HH);

// Аварийные действия
IF xAlarmLowLevel THEN
    // Критически низкий уровень - аварийное отключение потребителей
    xEmergencyValveClose := TRUE;
    AddAlarmMessage('CRITICAL: Tank level critically low');
END_IF

IF xAlarmHighLevel THEN
    // Критически высокий уровень - аварийный слив
    xEmergencyDrainOpen := TRUE;
    AddAlarmMessage('CRITICAL: Tank level critically high');
END_IF
```

### Многопараметровый мониторинг

```pascal
VAR
    afbProcessDiag : ARRAY[1..4] OF FB_RangeDiagnostic_LH;
    arProcessValues : ARRAY[1..4] OF REAL;
    asParameterNames : ARRAY[1..4] OF STRING := 
        ['Temperature', 'Pressure', 'Flow', 'Level'];
    astDiagResults : ARRAY[1..4] OF ST_DiagnosticResult;
    nAlarmCount : INT := 0;
    nWarningCount : INT := 0;
    i : INT;
END_VAR

TYPE ST_DiagnosticResult :
STRUCT
    sParameterName : STRING;
    rCurrentValue : REAL;
    eState : E_AlarmSetpoints;
    xAlarmActive : BOOL;
    xWarningActive : BOOL;
    xCriticalActive : BOOL;
    rDistanceToLimit : REAL;
    sStatusMessage : STRING;
END_STRUCT
END_TYPE

// Конфигурация уставок для разных параметров
afbProcessDiag[1].SetAllSetpoints(15.0, 20.0, 80.0, 85.0);    // Температура
afbProcessDiag[2].SetAllSetpoints(3.5, 4.0, 6.0, 6.5);       // Давление
afbProcessDiag[3].SetAllSetpoints(10.0, 15.0, 85.0, 90.0);   // Расход
afbProcessDiag[4].SetSetpointsPercent(0.0, 100.0, 5.0, 15.0, 85.0, 95.0); // Уровень

// Обработка всех параметров
nAlarmCount := 0;
nWarningCount := 0;

FOR i := 1 TO 4 DO
    afbProcessDiag[i](
        irValue := arProcessValues[i],
        ixEnable := TRUE,
        irHysteresis := 1.0
    );
    
    // Сбор результатов диагностики
    astDiagResults[i].sParameterName := asParameterNames[i];
    astDiagResults[i].rCurrentValue := arProcessValues[i];
    astDiagResults[i].eState := afbProcessDiag[i].GetAlarmCode();
    astDiagResults[i].xAlarmActive := afbProcessDiag[i].qxAlarmActive;
    astDiagResults[i].xWarningActive := afbProcessDiag[i].qxWarningActive;
    astDiagResults[i].xCriticalActive := afbProcessDiag[i].qxCriticalActive;
    astDiagResults[i].rDistanceToLimit := afbProcessDiag[i].GetDistanceToNearestSetpoint();
    
    // Подсчет общих аварий и предупреждений
    IF astDiagResults[i].xAlarmActive THEN
        nAlarmCount := nAlarmCount + 1;
    END_IF
    
    IF astDiagResults[i].xWarningActive THEN
        nWarningCount := nWarningCount + 1;
    END_IF
    
    // Формирование статусного сообщения
    CASE astDiagResults[i].eState OF
        E_AlarmSetpoints.Normal:
            astDiagResults[i].sStatusMessage := 'OK';
        E_AlarmSetpoints.L:
            astDiagResults[i].sStatusMessage := 'LOW WARNING';
        E_AlarmSetpoints.H:
            astDiagResults[i].sStatusMessage := 'HIGH WARNING';
        E_AlarmSetpoints.LL:
            astDiagResults[i].sStatusMessage := 'LOW ALARM';
        E_AlarmSetpoints.HH:
            astDiagResults[i].sStatusMessage := 'HIGH ALARM';
    END_CASE
END_FOR
```

## Примечания

- Блок реализует стандартную промышленную логику мониторинга с четырьмя уровнями
- Гистерезис применяется только при возврате в нормальное состояние для предотвращения дребезга
- Автоматическая валидация корректности порядка уставок (LL ≤ L < H ≤ HH)
- Поддержка различных методов настройки уставок (абсолютные, симметричные, процентные)
- Встроенная диагностика расстояния до ближайшей критической уставки
- Возможность принудительного сброса состояния для тестирования и обслуживания
- Рекомендуется использовать совместно с системами архивирования и HMI для полноценного мониторинга
- При критических авариях (LL, HH) следует предусматривать автоматические защитные действия
- Размер гистерезиса должен быть меньше интервалов между соседними уставками
- Блок оптимизирован для работы в реальном времени с минимальной вычислительной нагрузкой

