# Документация функционального блока FB_NumericChangeDetector

## Обзор

### Назначение

Функциональный блок `FB_NumericChangeDetector` предназначен для обнаружения изменений числовых значений. Блок отслеживает входное значение типа REAL и генерирует импульсный сигнал при каждом изменении значения, а также предоставляет информацию о характере изменения (увеличение/уменьшение) и величине изменения.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`irValue`|`REAL`|Входное числовое значение для мониторинга|

### Выходные параметры (VAR_OUTPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`qxChangeDetected`|`BOOL`|Импульс при обнаружении изменения значения|

### Внутренние переменные (VAR)

|Переменная|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`_rPreviousValue`|`REAL`|0.0|Предыдущее значение для сравнения|
|`_xFirstCycle`|`BOOL`|TRUE|Флаг первого цикла выполнения|
|`_rt_Change`|`R_TRIG`|-|Триггер для генерации импульса|
|`_xValueChanged`|`BOOL`|FALSE|Внутренний флаг изменения|

## Принцип работы

1. **Инициализация**: В первом цикле выполнения блок сохраняет входное значение как предыдущее без генерации импульса
2. **Сравнение**: В каждом последующем цикле текущее значение сравнивается с предыдущим
3. **Обнаружение изменения**: При обнаружении различия устанавливается внутренний флаг изменения
4. **Генерация импульса**: Через R_TRIG формируется импульс длительностью в один цикл на выходе `qxChangeDetected`
5. **Обновление**: Текущее значение сохраняется как предыдущее для следующего цикла

## Методы

### GetCurrentValue

**Описание:** Возвращает текущее отслеживаемое значение.

**Прототип:**

```pascal
METHOD GetCurrentValue : REAL
```

**Возвращаемое значение:** Текущее входное значение `irValue`

---

### GetPreviousValue

**Описание:** Возвращает предыдущее значение, сохраненное в предыдущем цикле.

**Прототип:**

```pascal
METHOD GetPreviousValue : REAL
```

**Возвращаемое значение:** Значение из предыдущего цикла сканирования

---

### GetValueDifference

**Описание:** Вычисляет разность между текущим и предыдущим значением.

**Прототип:**

```pascal
METHOD GetValueDifference : REAL
```

**Возвращаемое значение:** 
- Положительное значение = увеличение
- Отрицательное значение = уменьшение  
- Ноль = нет изменения

---

### IsValueIncreased

**Описание:** Проверяет, произошло ли увеличение значения в текущем цикле.

**Прототип:**

```pascal
METHOD IsValueIncreased : BOOL
```

**Возвращаемое значение:**
- TRUE = значение увеличилось
- FALSE = значение не изменилось или уменьшилось

---

### IsValueDecreased

**Описание:** Проверяет, произошло ли уменьшение значения в текущем цикле.

**Prototип:**

```pascal
METHOD IsValueDecreased : BOOL
```

**Возвращаемое значение:**
- TRUE = значение уменьшилось
- FALSE = значение не изменилось или увеличилось

---

### Reset

**Описание:** Сбрасывает детектор изменений в начальное состояние.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Устанавливает предыдущее значение равным текущему
- Активирует флаг первого цикла
- Сбрасывает внутренние флаги и триггеры
- Сбрасывает выходной импульс

## Типовые сценарии использования

### Базовое обнаружение изменений

```pascal
PROGRAM PRG_Main
VAR
    fbChangeDetector : FB_NumericChangeDetector;
    rTemperature : REAL;          // Температура от датчика
    xTempChanged : BOOL;          // Флаг изменения температуры
    rTempDelta : REAL;            // Величина изменения
END_VAR

// Мониторинг изменений температуры
fbChangeDetector(irValue := rTemperature);

xTempChanged := fbChangeDetector.qxChangeDetected;

IF xTempChanged THEN
    rTempDelta := fbChangeDetector.GetValueDifference();
    
    // Логирование изменения
    LogTemperatureChange(rTemperature, rTempDelta);
END_IF
```

### Мониторинг уставок

```pascal
VAR
    fbSetpointMonitor : FB_NumericChangeDetector;
    rSetpoint : REAL;             // Уставка от HMI
    xSetpointChanged : BOOL;      // Изменение уставки
    rOldSetpoint : REAL;          // Предыдущая уставка
    rNewSetpoint : REAL;          // Новая уставка
END_VAR

fbSetpointMonitor(irValue := rSetpoint);

xSetpointChanged := fbSetpointMonitor.qxChangeDetected;

IF xSetpointChanged THEN
    rOldSetpoint := fbSetpointMonitor.GetPreviousValue();
    rNewSetpoint := fbSetpointMonitor.GetCurrentValue();
    
    // Архивирование изменения уставки
    ArchiveSetpointChange(rOldSetpoint, rNewSetpoint, TIME());
    
    // Уведомление оператора
    AddAlarmMessage('Setpoint changed from ' + 
                   REAL_TO_STRING(rOldSetpoint) + ' to ' + 
                   REAL_TO_STRING(rNewSetpoint));
END_IF
```

### Обнаружение скачков значений

```pascal
VAR
    fbJumpDetector : FB_NumericChangeDetector;
    rPressure : REAL;             // Давление
    rJumpThreshold : REAL := 5.0; // Порог скачка
    xJumpDetected : BOOL;         // Обнаружен скачок
    xSignalStable : BOOL;         // Сигнал стабилен
END_VAR

fbJumpDetector(irValue := rPressure);

IF fbJumpDetector.qxChangeDetected THEN
    // Проверка на скачок значения
    IF ABS(fbJumpDetector.GetValueDifference()) > rJumpThreshold THEN
        xJumpDetected := TRUE;
        xSignalStable := FALSE;
        
        // Диагностика возможной неисправности датчика
        AddDiagnosticMessage('Pressure sensor: sudden value jump detected');
    ELSE
        xSignalStable := TRUE;
        xJumpDetected := FALSE;
    END_IF
END_IF
```

### Контроль стабильности процесса

```pascal
VAR
    fbStabilityMonitor : FB_NumericChangeDetector;
    rProcessValue : REAL;         // Значение процесса
    tonStabilityTimer : TON;      // Таймер стабильности
    tStabilityTime : TIME := T#30S; // Время для стабильности
    xProcessStable : BOOL;        // Процесс стабилен
    nChangeCount : UINT := 0;     // Количество изменений
END_VAR

fbStabilityMonitor(irValue := rProcessValue);

// Сброс таймера при каждом изменении
IF fbStabilityMonitor.qxChangeDetected THEN
    tonStabilityTimer(IN := FALSE);
    tonStabilityTimer(IN := TRUE, PT := tStabilityTime);
    nChangeCount := nChangeCount + 1;
END_IF

// Определение стабильности
tonStabilityTimer();
xProcessStable := tonStabilityTimer.Q;

// Сброс счетчика изменений при достижении стабильности
IF xProcessStable THEN
    nChangeCount := 0;
END_IF
```

### Триггер для архивирования

```pascal
VAR
    fbArchiveTrigger : FB_NumericChangeDetector;
    rAnalogValue : REAL;          // Аналоговое значение
    xArchiveNow : BOOL;           // Триггер архивирования
    tLastArchive : TIME;          // Время последнего архивирования
    tMinArchiveInterval : TIME := T#1M; // Минимальный интервал
END_VAR

fbArchiveTrigger(irValue := rAnalogValue);

// Архивирование при изменении с ограничением частоты
IF fbArchiveTrigger.qxChangeDetected THEN
    IF (TIME() - tLastArchive) >= tMinArchiveInterval THEN
        xArchiveNow := TRUE;
        tLastArchive := TIME();
        
        // Добавление записи в архив
        ArchiveValue(rAnalogValue, TIME());
    END_IF
END_IF
```

### Анализ трендов

```pascal
VAR
    fbTrendAnalyzer : FB_NumericChangeDetector;
    rMeasurement : REAL;          // Измеренное значение
    nIncreaseCount : UINT := 0;   // Счетчик увеличений
    nDecreaseCount : UINT := 0;   // Счетчик уменьшений
    eTrendDirection : E_TrendDirection; // Направление тренда
END_VAR

fbTrendAnalyzer(irValue := rMeasurement);

IF fbTrendAnalyzer.qxChangeDetected THEN
    IF fbTrendAnalyzer.IsValueIncreased() THEN
        nIncreaseCount := nIncreaseCount + 1;
        nDecreaseCount := 0; // Сброс счетчика противоположного направления
    ELSIF fbTrendAnalyzer.IsValueDecreased() THEN
        nDecreaseCount := nDecreaseCount + 1;
        nIncreaseCount := 0; // Сброс счетчика противоположного направления
    END_IF
    
    // Определение тренда
    IF nIncreaseCount >= 3 THEN
        eTrendDirection := E_TrendDirection.Rising;
    ELSIF nDecreaseCount >= 3 THEN
        eTrendDirection := E_TrendDirection.Falling;
    ELSE
        eTrendDirection := E_TrendDirection.Stable;
    END_IF
END_IF
```

## Диагностические возможности

### Состояния блока

|Состояние|Метод/Выход|Описание|
|---|---|---|
|Изменение обнаружено|`qxChangeDetected`|Импульс при любом изменении|
|Текущее значение|`GetCurrentValue()`|Актуальное входное значение|
|Предыдущее значение|`GetPreviousValue()`|Значение из предыдущего цикла|
|Величина изменения|`GetValueDifference()`|Разность между значениями|
|Увеличение|`IsValueIncreased()`|Значение возросло|
|Уменьшение|`IsValueDecreased()`|Значение уменьшилось|

### Статистика изменений

```pascal
// Ведение статистики изменений
VAR
    nTotalChanges : UINT := 0;    // Общее количество изменений
    rMaxIncrease : REAL := 0.0;   // Максимальное увеличение
    rMaxDecrease : REAL := 0.0;   // Максимальное уменьшение
    rAverageChange : REAL;        // Среднее изменение
    rTotalChange : REAL := 0.0;   // Сумма всех изменений
END_VAR

IF fbChangeDetector.qxChangeDetected THEN
    VAR
        rChange : REAL;
    END_VAR
    
    rChange := fbChangeDetector.GetValueDifference();
    nTotalChanges := nTotalChanges + 1;
    rTotalChange := rTotalChange + ABS(rChange);
    
    // Отслеживание экстремумов
    IF rChange > rMaxIncrease THEN
        rMaxIncrease := rChange;
    END_IF
    
    IF rChange < rMaxDecrease THEN
        rMaxDecrease := rChange;
    END_IF
    
    // Расчет среднего изменения
    IF nTotalChanges > 0 THEN
        rAverageChange := rTotalChange / nTotalChanges;
    END_IF
END_IF
```

## Примечания

- Блок обнаруживает любые изменения значения, включая очень малые
- Импульс `qxChangeDetected` длится только один цикл сканирования
- Для работы с зашумленными сигналами рекомендуется предварительная фильтрация
- Блок не накапливает историю изменений - доступны только текущее и предыдущее значения
- При работе с значениями с плавающей точкой учитывайте особенности их представления
- Рекомендуется периодически анализировать статистику изменений для оптимизации параметров системы
- Блок эффективен для создания событийно-ориентированных систем архивирования и логирования
