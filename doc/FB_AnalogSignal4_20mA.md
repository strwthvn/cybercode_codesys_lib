# Документация функционального блока FB_AnalogSignal4_20mA

## Обзор

### Назначение

Функциональный блок `FB_AnalogSignal4_20mA` предназначен для обработки аналоговых сигналов токовой петли 4-20 мА. Блок наследуется от `FB_BasicAnalogSignal` и реализует специализированную логику масштабирования токового сигнала в инженерные единицы с расширенной диагностикой состояния токовой петли.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`irRawValue`|`REAL`|-|Токовое значение в мА (наследуется от FB_BasicAnalogSignal)|
|`rScaleMin`|`REAL`|0.0|Минимальное значение масштабируемого диапазона|
|`rScaleMax`|`REAL`|100.0|Максимальное значение масштабируемого диапазона|
|`xEnableRangeProtection`|`BOOL`|TRUE|Включение защиты от выхода за диапазон|

### Внутренние переменные (VAR)

|Переменная|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`_rCurrentMin`|`REAL`|4.0|Минимальный ток токовой петли (мА)|
|`_rCurrentMax`|`REAL`|20.0|Максимальный ток токовой петли (мА)|
|`_xUnderrange`|`BOOL`|FALSE|Сигнал ниже 4 мА|
|`_xOverrange`|`BOOL`|FALSE|Сигнал выше 20 мА|
|`_xWireBreak`|`BOOL`|FALSE|Обрыв линии (ток < 3.5 мА)|
|`_xOverload`|`BOOL`|FALSE|Перегрузка (ток > 21 мА)|
|`_rWireBreakThreshold`|`REAL`|3.5|Порог обрыва линии (мА)|
|`_rOverloadThreshold`|`REAL`|21.0|Порог перегрузки (мА)|

## Принцип работы

### Масштабирование сигнала

1. **Нормализация**: Токовый сигнал 4-20 мА преобразуется в диапазон 0-1
2. **Масштабирование**: Нормализованное значение масштабируется в заданный инженерный диапазон
3. **Защита диапазона**: При включенной защите значение ограничивается в пределах 0-1

### Диагностика токовой петли

1. **Обрыв линии**: Ток менее 3.5 мА
2. **Перегрузка**: Ток более 21 мА  
3. **Выход за рабочий диапазон**: Ток вне диапазона 4-20 мА (но не критично)

## Методы

### GetScaledValue

**Описание:** Возвращает масштабированное значение с учетом критических ошибок.

**Прототип:**

```pascal
METHOD GetScaledValue : REAL
```

**Возвращаемое значение:**
- При критических ошибках (обрыв/перегрузка) → минимальное значение диапазона
- При нормальной работе → масштабированное значение

---

### GetPercentValue

**Описание:** Возвращает значение в процентах относительно масштабированного диапазона.

**Прототип:**

```pascal
METHOD GetPercentValue : REAL
```

**Возвращаемое значение:** Процентное значение (0..100%)

---

### IsWireBreak

**Описание:** Проверяет состояние обрыва линии.

**Прототип:**

```pascal
METHOD IsWireBreak : BOOL
```

**Возвращаемое значение:**
- TRUE = обрыв линии (ток < 3.5 мА)
- FALSE = линия в норме

---

### IsOverload

**Описание:** Проверяет состояние перегрузки токовой петли.

**Прототип:**

```pascal
METHOD IsOverload : BOOL
```

**Возвращаемое значение:**
- TRUE = перегрузка (ток > 21 мА)
- FALSE = нагрузка в норме

---

### IsUnderrange

**Описание:** Проверяет выход за нижний предел рабочего диапазона.

**Прототип:**

```pascal
METHOD IsUnderrange : BOOL
```

**Возвращаемое значение:**
- TRUE = ток ниже 4 мА (но выше порога обрыва)
- FALSE = ток в рабочем диапазоне

---

### IsOverrange

**Описание:** Проверяет выход за верхний предел рабочего диапазона.

**Prototип:**

```pascal
METHOD IsOverrange : BOOL
```

**Возвращаемое значение:**
- TRUE = ток выше 20 мА (но ниже порога перегрузки)
- FALSE = ток в рабочем диапазоне

---

### HasError

**Описание:** Проверяет наличие любых ошибок токовой петли.

**Prototип:**

```pascal
METHOD HasError : BOOL
```

**Возвращаемое значение:**
- TRUE = есть ошибки (обрыв, перегрузка, выход за диапазон)
- FALSE = все в норме

---

### SetScaleRange

**Описание:** Устанавливает диапазон масштабирования.

**Прототип:**

```pascal
METHOD SetScaleRange
VAR_INPUT
    rMin : REAL;    // Минимальное значение
    rMax : REAL;    // Максимальное значение
END_VAR
```

**Функциональность:** Устанавливает новый диапазон только если `rMin < rMax`

---

### GetScaleMin / GetScaleMax

**Описание:** Возвращают границы диапазона масштабирования.

**Прототип:**

```pascal
METHOD GetScaleMin : REAL
METHOD GetScaleMax : REAL
```

---

### Reset

**Описание:** Сбрасывает все ошибки и состояния блока.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Вызывает родительский метод Reset()
- Сбрасывает все локальные флаги ошибок

## Типовые сценарии использования

### Обработка датчика температуры

```pascal
PROGRAM PRG_Main
VAR
    fbTempSensor : FB_AnalogSignal4_20mA;
    rCurrentInput : REAL;         // Ток от АЦП (мА)
    rTemperature : REAL;          // Температура (°C)
    xTempSensorOK : BOOL;         // Состояние датчика
    xTempAlarm : BOOL;            // Авария датчика
END_VAR

// Обработка сигнала датчика температуры 0-100°C
fbTempSensor(
    irRawValue := rCurrentInput,
    rScaleMin := 0.0,            // 0°C при 4 мА
    rScaleMax := 100.0,          // 100°C при 20 мА
    xEnableRangeProtection := TRUE
);

// Получение значений
rTemperature := fbTempSensor.GetScaledValue();
xTempSensorOK := NOT fbTempSensor.HasError();

// Диагностика
IF fbTempSensor.IsWireBreak() THEN
    xTempAlarm := TRUE;
    AddAlarmMessage('Temperature sensor: Wire break detected');
ELSIF fbTempSensor.IsOverload() THEN
    xTempAlarm := TRUE;
    AddAlarmMessage('Temperature sensor: Overload detected');
ELSE
    xTempAlarm := FALSE;
END_IF
```

### Обработка датчика давления

```pascal
VAR
    fbPressureSensor : FB_AnalogSignal4_20mA;
    rPressureCurrent : REAL;      // Ток (мА)
    rPressure : REAL;             // Давление (бар)
    rPressurePercent : REAL;      // Давление (%)
    stPressureDiag : ST_PressureDiagnostics;
END_VAR

TYPE ST_PressureDiagnostics :
STRUCT
    xWireBreak : BOOL;
    xOverload : BOOL;
    xUnderrange : BOOL;
    xOverrange : BOOL;
    xAnyError : BOOL;
END_STRUCT
END_TYPE

// Конфигурация для датчика давления 0-10 бар
fbPressureSensor.SetScaleRange(0.0, 10.0);

fbPressureSensor(
    irRawValue := rPressureCurrent,
    xEnableRangeProtection := TRUE
);

// Получение значений
rPressure := fbPressureSensor.GetScaledValue();
rPressurePercent := fbPressureSensor.GetPercentValue();

// Сбор диагностики
stPressureDiag.xWireBreak := fbPressureSensor.IsWireBreak();
stPressureDiag.xOverload := fbPressureSensor.IsOverload();
stPressureDiag.xUnderrange := fbPressureSensor.IsUnderrange();
stPressureDiag.xOverrange := fbPressureSensor.IsOverrange();
stPressureDiag.xAnyError := fbPressureSensor.HasError();
```

### Мониторинг качества сигнала

```pascal
VAR
    fbSignalMonitor : FB_AnalogSignal4_20mA;
    rSignalCurrent : REAL;        // Текущий ток
    rSignalQuality : REAL;        // Качество сигнала (%)
    stSignalStatus : ST_SignalStatus;
END_VAR

TYPE ST_SignalStatus :
STRUCT
    sStatus : STRING;             // Текстовое описание состояния
    eHealthLevel : E_HealthLevel; // Уровень состояния
    rCurrentValue : REAL;         // Текущий ток
    rProcessValue : REAL;         // Обработанное значение
END_STRUCT
END_TYPE

TYPE E_HealthLevel : (Good, Warning, Bad, Critical);

fbSignalMonitor(
    irRawValue := rSignalCurrent,
    rScaleMin := 0.0,
    rScaleMax := 100.0
);

// Определение качества сигнала
CASE TRUE OF
    fbSignalMonitor.IsWireBreak():
        stSignalStatus.sStatus := 'CRITICAL: Wire break';
        stSignalStatus.eHealthLevel := E_HealthLevel.Critical;
        rSignalQuality := 0.0;
        
    fbSignalMonitor.IsOverload():
        stSignalStatus.sStatus := 'CRITICAL: Overload';
        stSignalStatus.eHealthLevel := E_HealthLevel.Critical;
        rSignalQuality := 0.0;
        
    fbSignalMonitor.IsUnderrange():
        stSignalStatus.sStatus := 'WARNING: Below 4mA';
        stSignalStatus.eHealthLevel := E_HealthLevel.Warning;
        rSignalQuality := 50.0;
        
    fbSignalMonitor.IsOverrange():
        stSignalStatus.sStatus := 'WARNING: Above 20mA';
        stSignalStatus.eHealthLevel := E_HealthLevel.Warning;
        rSignalQuality := 75.0;
        
    ELSE
        stSignalStatus.sStatus := 'GOOD: Normal operation';
        stSignalStatus.eHealthLevel := E_HealthLevel.Good;
        rSignalQuality := 100.0;
END_CASE

stSignalStatus.rCurrentValue := fbSignalMonitor.GetRawValue();
stSignalStatus.rProcessValue := fbSignalMonitor.GetScaledValue();
```

### Калибровка и настройка

```pascal
VAR
    fbCalibratedSensor : FB_AnalogSignal4_20mA;
    xCalibrationMode : BOOL;      // Режим калибровки
    rCalibrationCurrent : REAL;   // Калибровочный ток
    rExpectedValue : REAL;        // Ожидаемое значение
END_VAR

// Процедура калибровки датчика
IF xCalibrationMode THEN
    fbCalibratedSensor(
        irRawValue := rCalibrationCurrent,
        xEnableRangeProtection := FALSE  // Отключить защиту при калибровке
    );
    
    // Калибровка нижней точки (4 мА)
    IF ABS(rCalibrationCurrent - 4.0) < 0.1 THEN
        // Проверка нижней границы
        LogCalibrationPoint('4mA', rExpectedValue, 
                           fbCalibratedSensor.GetProcessedValue());
    END_IF
    
    // Калибровка верхней точки (20 мА)
    IF ABS(rCalibrationCurrent - 20.0) < 0.1 THEN
        // Проверка верхней границы
        LogCalibrationPoint('20mA', rExpectedValue, 
                           fbCalibratedSensor.GetProcessedValue());
    END_IF
END_IF
```

### Архивирование и трендинг

```pascal
VAR
    fbTrendingSensor : FB_AnalogSignal4_20mA;
    fbChangeDetector : FB_NumericChangeDetector;
    stArchiveRecord : ST_ArchiveRecord;
    xArchiveTrigger : BOOL;
END_VAR

TYPE ST_ArchiveRecord :
STRUCT
    dtTimestamp : DT;
    rCurrentValue : REAL;
    rScaledValue : REAL;
    rPercentValue : REAL;
    xQualityGood : BOOL;
    sQualityFlags : STRING;
END_STRUCT
END_TYPE

// Обработка сигнала
fbTrendingSensor(
    irRawValue := rAnalogInput,
    rScaleMin := 0.0,
    rScaleMax := 200.0
);

// Обнаружение изменений для триггера архивирования
fbChangeDetector(irValue := fbTrendingSensor.GetScaledValue());

xArchiveTrigger := fbChangeDetector.qxChangeDetected;

// Архивирование при изменении значения
IF xArchiveTrigger THEN
    stArchiveRecord.dtTimestamp := NOW();
    stArchiveRecord.rCurrentValue := fbTrendingSensor.GetRawValue();
    stArchiveRecord.rScaledValue := fbTrendingSensor.GetScaledValue();
    stArchiveRecord.rPercentValue := fbTrendingSensor.GetPercentValue();
    stArchiveRecord.xQualityGood := NOT fbTrendingSensor.HasError();
    
    // Формирование строки флагов качества
    stArchiveRecord.sQualityFlags := '';
    IF fbTrendingSensor.IsWireBreak() THEN 
        stArchiveRecord.sQualityFlags := CONCAT(stArchiveRecord.sQualityFlags, 'WB ');
    END_IF
    IF fbTrendingSensor.IsOverload() THEN 
        stArchiveRecord.sQualityFlags := CONCAT(stArchiveRecord.sQualityFlags, 'OL ');
    END_IF
    IF fbTrendingSensor.IsUnderrange() THEN 
        stArchiveRecord.sQualityFlags := CONCAT(stArchiveRecord.sQualityFlags, 'UR ');
    END_IF
    IF fbTrendingSensor.IsOverrange() THEN 
        stArchiveRecord.sQualityFlags := CONCAT(stArchiveRecord.sQualityFlags, 'OR ');
    END_IF
    
    // Запись в архив
    WriteToArchive(stArchiveRecord);
END_IF
```

## Диагностические возможности

### Уровни диагностики

|Уровень|Условие|Описание|Действие|
|---|---|---|---|
|**Критический**|`IsWireBreak()` OR `IsOverload()`|Неисправность токовой петли|Немедленная остановка процесса|
|**Предупреждение**|`IsUnderrange()` OR `IsOverrange()`|Сигнал вне номинала|Контроль качества|
|**Норма**|NOT `HasError()`|Сигнал в пределах 4-20 мА|Нормальная работа|

### Статистика качества сигнала

```pascal
VAR
    fbQualityAnalyzer : FB_AnalogSignal4_20mA;
    stQualityStats : ST_QualityStatistics;
    tonQualityTimer : TON;
    nSampleCount : UINT := 0;
END_VAR

TYPE ST_QualityStatistics :
STRUCT
    nTotalSamples : UINT;         // Общее количество измерений
    nGoodSamples : UINT;          // Хороших измерений
    nWireBreakCount : UINT;       // Количество обрывов
    nOverloadCount : UINT;        // Количество перегрузок
    rQualityPercent : REAL;       // Процент качественных измерений
    tAnalysisPeriod : TIME;       // Период анализа
END_STRUCT
END_TYPE

// Таймер для периодического анализа
tonQualityTimer(IN := TRUE, PT := T#10S);

IF tonQualityTimer.Q THEN
    tonQualityTimer(IN := FALSE);
    nSampleCount := nSampleCount + 1;
    stQualityStats.nTotalSamples := stQualityStats.nTotalSamples + 1;
    
    // Анализ качества текущего измерения
    IF NOT fbQualityAnalyzer.HasError() THEN
        stQualityStats.nGoodSamples := stQualityStats.nGoodSamples + 1;
    END_IF
    
    IF fbQualityAnalyzer.IsWireBreak() THEN
        stQualityStats.nWireBreakCount := stQualityStats.nWireBreakCount + 1;
    END_IF
    
    IF fbQualityAnalyzer.IsOverload() THEN
        stQualityStats.nOverloadCount := stQualityStats.nOverloadCount + 1;
    END_IF
    
    // Расчет процента качества
    IF stQualityStats.nTotalSamples > 0 THEN
        stQualityStats.rQualityPercent := 
            (UINT_TO_REAL(stQualityStats.nGoodSamples) / 
             UINT_TO_REAL(stQualityStats.nTotalSamples)) * 100.0;
    END_IF
END_IF
```

## Технические характеристики

### Диапазоны токовой петли

|Состояние|Диапазон тока|Описание|
|---|---|---|
|Обрыв линии|< 3.5 мА|Критическая ошибка|
|Нижний выход|3.5 - 4.0 мА|Предупреждение|
|Рабочий диапазон|4.0 - 20.0 мА|Нормальная работа|
|Верхний выход|20.0 - 21.0 мА|Предупреждение|
|Перегрузка|> 21.0 мА|Критическая ошибка|

### Точность масштабирования

- **Разрешение**: Определяется разрядностью АЦП
- **Линейность**: Линейное масштабирование в диапазоне 4-20 мА
- **Погрешность**: Зависит от точности измерения тока

## Рекомендации по применению

### Подключение датчиков

```pascal
// Конфигурация для различных типов датчиков
METHOD ConfigureForSensorType
VAR_INPUT
    eSensorType : E_4_20mA_SensorType;
    rProcessMin : REAL;
    rProcessMax : REAL;
END_VAR

CASE eSensorType OF
    E_4_20mA_SensorType.Temperature:
        SetScaleRange(rProcessMin, rProcessMax);
        // Температурные датчики обычно точные
        
    E_4_20mA_SensorType.Pressure:
        SetScaleRange(rProcessMin, rProcessMax);
        // Датчики давления могут иметь выбросы
        
    E_4_20mA_SensorType.Flow:
        SetScaleRange(rProcessMin, rProcessMax);
        // Расходомеры могут быть нестабильными
        
    E_4_20mA_SensorType.Level:
        SetScaleRange(rProcessMin, rProcessMax);
        // Уровнемеры требуют калибровки нуля
END_CASE
```

### Обработка ошибок

```pascal
// Стратегия обработки ошибок токовой петли
METHOD HandleLoopErrors
VAR_INPUT
    xUseLastGoodValue : BOOL;     // Использовать последнее хорошее значение
    rSafeValue : REAL;            // Безопасное значение при ошибке
END_VAR
VAR
    rOutputValue : REAL;
END_VAR

CASE TRUE OF
    IsWireBreak() OR IsOverload():
        // Критические ошибки
        IF xUseLastGoodValue THEN
            rOutputValue := _rLastGoodValue;
        ELSE
            rOutputValue := rSafeValue;
        END_IF
        
    IsUnderrange() OR IsOverrange():
        // Предупреждения - используем ограниченное значение
        rOutputValue := GetScaledValue();
        
    ELSE
        // Нормальная работа
        rOutputValue := GetScaledValue();
        _rLastGoodValue := rOutputValue;  // Сохраняем хорошее значение
END_CASE
```

## Примечания

- Блок оптимизирован для стандартных токовых петель 4-20 мА
- Автоматическая диагностика обрыва и перегрузки повышает надежность системы
- При критических ошибках метод `GetScaledValue()` возвращает минимальное значение диапазона
- Защита диапазона предотвращает выход нормализованного значения за пределы 0-1
- Рекомендуется регулярно контролировать состояние токовой петли через диагностические методы
- Для высокоточных применений рассмотрите дополнительную калибровку и компенсацию температурного дрейфа
- Пороги обнаружения ошибок (3.5 мА и 21 мА) соответствуют промышленным стандартам
