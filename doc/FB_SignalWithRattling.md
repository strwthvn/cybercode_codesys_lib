# Документация функционального блока FB_SignalWithRattling

## Обзор

### Назначение

Функциональный блок `FB_SignalWithRattling` предназначен для фильтрации цифровых сигналов с функцией обнаружения дребезга контактов. Блок наследуется от `FB_BasicSignal` и обеспечивает стабилизацию входного сигнала, а также автоматическое обнаружение чрезмерного количества переключений, которые могут указывать на неисправность датчика или контакта.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`ixSignal`|`BOOL`|Входной сигнал для обработки (наследуется от FB_BasicSignal)|

### Внутренние переменные (VAR)

|Переменная|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`_tStabilityTime`|`TIME`|T#100MS|Время стабилизации сигнала|
|`_nMaxTransitions`|`UINT`|5|Максимальное количество переходов для определения дребезга|
|`_tDetectionWindow`|`TIME`|T#200MS|Окно времени для подсчета переходов|
|`_ton_StabilityFilter`|`TON`|-|Таймер фильтрации для стабильного сигнала|
|`_xOutSignal`|`BOOL`|-|Отфильтрованный выходной сигнал|
|`_rt_SignalChange`|`R_TRIG`|-|Детектор фронта 0→1|
|`_ft_SignalChange`|`F_TRIG`|-|Детектор фронта 1→0|
|`_nTransitionCounter`|`UINT`|-|Счетчик переходов в окне обнаружения|
|`_ton_DetectionWindow`|`TON`|-|Таймер окна обнаружения дребезга|
|`_xRattlingDetected`|`BOOL`|-|Флаг обнаружения дребезга|
|`_xDetectionActive`|`BOOL`|-|Флаг активности окна обнаружения|

## Принцип работы

### Фильтрация сигнала

1. Входной сигнал должен быть стабильным в течение времени `_tStabilityTime` (по умолчанию 100мс)
2. Только после стабилизации сигнал появляется на выходе `GetProcessedSignal()`
3. Это исключает кратковременные помехи и дребезг контактов

### Обнаружение дребезга

1. При каждом изменении входного сигнала запускается окно обнаружения `_tDetectionWindow` (по умолчанию 200мс)
2. В течение этого окна подсчитывается количество переходов сигнала
3. Если количество переходов превышает порог `_nMaxTransitions` (по умолчанию 5), фиксируется дребезг
4. Обнаружение дребезга сигнализирует о возможной неисправности контакта или датчика

## Методы

### GetProcessedSignal

**Описание:** Возвращает отфильтрованный и стабилизированный сигнал.

**Прототип:**

```pascal
METHOD GetProcessedSignal : BOOL
```

**Возвращаемое значение:**
- TRUE = стабильный сигнал активен
- FALSE = стабильный сигнал неактивен

---

### GetRattlingDetected

**Описание:** Возвращает состояние флага обнаружения дребезга.

**Прототип:**

```pascal
METHOD GetRattlingDetected : BOOL
```

**Возвращаемое значение:**
- TRUE = обнаружен дребезг контакта
- FALSE = дребезг не обнаружен

---

### GetTransitionCount

**Описание:** Возвращает текущее количество переходов в окне обнаружения дребезга.

**Прототип:**

```pascal
METHOD GetTransitionCount : UINT
```

**Возвращаемое значение:** Количество зафиксированных переходов в текущем окне обнаружения

---

### IsDetectionActive

**Описание:** Проверяет активность окна обнаружения дребезга.

**Прототип:**

```pascal
METHOD IsDetectionActive : BOOL
```

**Возвращаемое значение:**
- TRUE = окно обнаружения активно (идет подсчет переходов)
- FALSE = окно обнаружения неактивно

---

### GetDetectionWindowTime

**Описание:** Возвращает прошедшее время текущего окна обнаружения.

**Прототип:**

```pascal
METHOD GetDetectionWindowTime : TIME
```

**Возвращаемое значение:** Время, прошедшее с начала текущего окна обнаружения

---

### ResetRattlingError

**Описание:** Сбрасывает флаг ошибки дребезга.

**Прототип:**

```pascal
METHOD ResetRattlingError
```

**Функциональность:**
- Устанавливает `_xRattlingDetected` = FALSE
- Не влияет на процесс фильтрации или текущее окно обнаружения

---

### Reset

**Описание:** Полный сброс состояния функционального блока.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Сбрасывает флаг ошибки дребезга
- Сбрасывает счетчики и флаги обнаружения
- Сбрасывает все таймеры
- Сбрасывает триггеры изменения сигнала
- Сбрасывает выходной сигнал

---

### Наследуемые методы

Блок наследует методы от `FB_BasicSignal`:

- `GetSignal() : BOOL` - получение исходного входного сигнала
- `GetInvertedSignal() : BOOL` - получение инвертированного входного сигнала

## Типовые сценарии использования

### Базовое использование

```pascal
PROGRAM PRG_Main
VAR
    fbRattlingFilter : FB_SignalWithRattling;
    xRawSensor : BOOL;            // Сырой сигнал от датчика
    xFilteredSensor : BOOL;       // Отфильтрованный сигнал
    xSensorFault : BOOL;          // Неисправность датчика
END_VAR

// Обработка сигнала с обнаружением дребезга
fbRattlingFilter(ixSignal := xRawSensor);

// Получение результатов
xFilteredSensor := fbRattlingFilter.GetProcessedSignal();
xSensorFault := fbRattlingFilter.GetRattlingDetected();

// Обработка неисправности датчика
IF xSensorFault THEN
    // Сигнализация о неисправности датчика
    xAlarmSensorRattling := TRUE;
    
    // Сброс ошибки после обслуживания
    fbRattlingFilter.ResetRattlingError();
END_IF
```

### Диагностика концевых выключателей

```pascal
VAR
    fbLimitSwitch : FB_SignalWithRattling;
    xLimitSwitchRaw : BOOL;       // Сырой сигнал концевика
    xPositionConfirmed : BOOL;    // Подтвержденная позиция
    nTransitions : UINT;          // Количество переходов
    sStatus : STRING;             // Статус концевика
END_VAR

fbLimitSwitch(ixSignal := xLimitSwitchRaw);

// Анализ состояния концевого выключателя
xPositionConfirmed := fbLimitSwitch.GetProcessedSignal();
nTransitions := fbLimitSwitch.GetTransitionCount();

CASE TRUE OF
    fbLimitSwitch.GetRattlingDetected():
        sStatus := 'FAULT: Contact rattling detected';
        
    fbLimitSwitch.IsDetectionActive():
        sStatus := CONCAT('Monitoring transitions: ', UINT_TO_STRING(nTransitions));
        
    xPositionConfirmed:
        sStatus := 'Position confirmed - switch closed';
        
    ELSE
        sStatus := 'Position confirmed - switch open';
END_CASE
```

### Мониторинг качества контактов

```pascal
VAR
    fbContactMonitor : FB_SignalWithRattling;
    tMonitoringTime : TIME;       // Время мониторинга
    nTotalTransitions : UINT;     // Общее количество переходов
    xContactWear : BOOL;          // Износ контакта
END_VAR

fbContactMonitor(ixSignal := xContactInput);

// Отслеживание качества контакта
IF fbContactMonitor.IsDetectionActive() THEN
    tMonitoringTime := fbContactMonitor.GetDetectionWindowTime();
    nTotalTransitions := fbContactMonitor.GetTransitionCount();
    
    // Предупреждение о повышенном количестве переходов
    IF nTotalTransitions >= 3 AND nTotalTransitions < 5 THEN
        xContactWear := TRUE;  // Возможный износ контакта
    END_IF
END_IF

// Обработка обнаруженного дребезга
IF fbContactMonitor.GetRattlingDetected() THEN
    // Критическое состояние контакта
    xContactFailure := TRUE;
    xContactWear := FALSE;  // Сброс предупреждения
    
    // Логирование события
    LogEvent('Contact rattling detected - replacement required');
    
    fbContactMonitor.ResetRattlingError();
END_IF
```

### Конфигурируемые параметры обнаружения

```pascal
// Настройка параметров для различных типов датчиков
METHOD ConfigureForSensorType
VAR_INPUT
    eSensorType : E_SensorType;
END_VAR

CASE eSensorType OF
    E_SensorType.MechanicalSwitch:
        // Механические переключатели - более строгие параметры
        _tStabilityTime := T#200MS;
        _nMaxTransitions := 3;
        _tDetectionWindow := T#500MS;
        
    E_SensorType.ProximitySensor:
        // Бесконтактные датчики - стандартные параметры
        _tStabilityTime := T#50MS;
        _nMaxTransitions := 7;
        _tDetectionWindow := T#200MS;
        
    E_SensorType.ReedSwitch:
        // Герконы - быстрая стабилизация
        _tStabilityTime := T#30MS;
        _nMaxTransitions := 4;
        _tDetectionWindow := T#150MS;
        
    E_SensorType.PressureSwitch:
        // Реле давления - медленная стабилизация
        _tStabilityTime := T#500MS;
        _nMaxTransitions := 2;
        _tDetectionWindow := T#1S;
END_CASE
```

## Диагностические возможности

### Состояния блока

|Состояние|Условие|Описание|
|---|---|---|
|Стабильный сигнал|`GetProcessedSignal()`|Отфильтрованный выходной сигнал|
|Активный мониторинг|`IsDetectionActive()`|Идет подсчет переходов|
|Обнаружен дребезг|`GetRattlingDetected()`|Превышен порог переходов|
|Нестабильный период|Различие между `GetSignal()` и `GetProcessedSignal()`|Сигнал не стабилизировался|

### Метрики качества сигнала

- **Количество переходов** - `GetTransitionCount()`
- **Время обнаружения** - `GetDetectionWindowTime()`
- **Стабильность** - соответствие между входным и выходным сигналом

## Примечания

- Отфильтрованный сигнал может отставать от входного на время стабилизации
- Обнаружение дребезга активируется только при изменениях входного сигнала
- Флаг дребезга сохраняется до явного сброса
- Блок эффективен для частот дребезга от 5 до 100 Гц
- Рекомендуется периодически контролировать состояние `GetRattlingDetected()` для профилактического обслуживания