# Документация функционального блока FB_SignalWithFeedbackTimer

## Обзор

### Назначение

Функциональный блок `FB_SignalWithFeedbackTimer` предназначен для контроля соответствия между командным сигналом и сигналом обратной связи с ограничением времени ожидания. Блок наследуется от `FB_SignalWithFeedback` и добавляет функциональность таймаута для обнаружения отсутствия обратной связи в заданное время.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`ixSignal`|`BOOL`|Командный сигнал (наследуется от FB_BasicSignal)|
|`ixFeedback`|`BOOL`|Сигнал обратной связи (наследуется от FB_SignalWithFeedback)|
|`tFeedbackTimeout`|`TIME`|Время ожидания сигнала обратной связи|

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_ton_FeedbackTimeout`|`TON`|Таймер ожидания обратной связи|
|`_xFeedbackTimeout`|`BOOL`|Флаг превышения времени ожидания|

## Принцип работы

1. При появлении переднего фронта командного сигнала запускается таймер ожидания обратной связи
2. Если обратная связь поступает до истечения времени таймаута - фиксируется успешное выполнение
3. Если таймер истекает без получения обратной связи - фиксируется ошибка таймаута
4. При успешном получении обратной связи таймер и ошибка сбрасываются

## Методы

### GetFeedbackTimeout

**Описание:** Возвращает состояние ошибки таймаута обратной связи.

**Прототип:**

```pascal
METHOD GetFeedbackTimeout : BOOL
```

**Возвращаемое значение:**
- TRUE = превышено время ожидания обратной связи
- FALSE = таймаут не зафиксирован

---

### GetElapsedTime

**Описание:** Возвращает текущее время, прошедшее с начала ожидания обратной связи.

**Прототип:**

```pascal
METHOD GetElapsedTime : TIME
```

**Возвращаемое значение:** Прошедшее время с момента запуска таймера

---

### IsTimerRunning

**Описание:** Проверяет активность таймера ожидания обратной связи.

**Прототип:**

```pascal
METHOD IsTimerRunning : BOOL
```

**Возвращаемое значение:**
- TRUE = таймер активен (идет отсчет времени ожидания)
- FALSE = таймер неактивен

---

### ResetFeedbackTimeout

**Описание:** Сбрасывает ошибку таймаута и останавливает таймер.

**Прототип:**

```pascal
METHOD ResetFeedbackTimeout
```

**Функциональность:**
- Устанавливает `_xFeedbackTimeout` = FALSE
- Останавливает таймер ожидания
- Не влияет на другие флаги состояния

---

### Reset

**Описание:** Полный сброс состояния функционального блока.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Сбрасывает флаг ожидания обратной связи
- Сбрасывает флаг получения обратной связи
- Сбрасывает ошибку таймаута и останавливает таймер
- Полностью очищает состояние блока

---

### Наследуемые методы

Блок наследует все методы от `FB_SignalWithFeedback`:

- `GetReceivedFeedback() : BOOL` - получение статуса успешного получения обратной связи
- `GetWaitingFeedback() : BOOL` - получение статуса ожидания обратной связи
- `ResetReceivedFeedback()` - сброс флага получения обратной связи
- `ResetWaitingFeedback()` - сброс флага ожидания обратной связи

И методы от `FB_BasicSignal`:

- `GetSignal() : BOOL` - получение текущего состояния командного сигнала
- `GetInvertedSignal() : BOOL` - получение инвертированного командного сигнала

## Типовые сценарии использования

### Базовое использование

```pascal
PROGRAM PRG_Main
VAR
    fbSignalTimer : FB_SignalWithFeedbackTimer;
    xCommand : BOOL;              // Командный сигнал
    xDeviceFeedback : BOOL;       // Обратная связь от устройства
END_VAR

// Подключение сигналов с таймаутом 5 секунд
fbSignalTimer(
    ixSignal := xCommand,
    ixFeedback := xDeviceFeedback,
    tFeedbackTimeout := T#5S
);

// Проверка состояний
IF fbSignalTimer.GetFeedbackTimeout() THEN
    // Превышено время ожидания - возможна неисправность
    // Обработка ошибки таймаута
    fbSignalTimer.ResetFeedbackTimeout();
END_IF

IF fbSignalTimer.GetReceivedFeedback() THEN
    // Команда выполнена успешно в заданное время
    fbSignalTimer.ResetReceivedFeedback();
END_IF
```

### Расширенная диагностика

```pascal
// Диагностика с контролем времени выполнения
CASE TRUE OF
    fbSignalTimer.GetSignal() AND fbSignalTimer.GetReceivedFeedback():
        // Команда выполнена успешно
        sStatus := 'Command executed successfully';
        
    fbSignalTimer.GetSignal() AND fbSignalTimer.IsTimerRunning():
        // Ожидаем выполнения команды
        sStatus := CONCAT('Waiting for feedback, elapsed: ', 
                         TIME_TO_STRING(fbSignalTimer.GetElapsedTime()));
        
    fbSignalTimer.GetFeedbackTimeout():
        // Превышено время ожидания
        sStatus := 'Feedback timeout - check device';
        xDeviceError := TRUE;
        
    NOT fbSignalTimer.GetSignal():
        // Команда не активна
        sStatus := 'No command active';
END_CASE
```

### Управление клапаном с контролем времени

```pascal
VAR
    fbValveControl : FB_SignalWithFeedbackTimer;
    xOpenCommand : BOOL;          // Команда открытия клапана
    xValveOpenFeedback : BOOL;    // Концевик "клапан открыт"
    xValveError : BOOL;           // Ошибка клапана
END_VAR

// Управление клапаном с таймаутом 10 секунд
fbValveControl(
    ixSignal := xOpenCommand,
    ixFeedback := xValveOpenFeedback,
    tFeedbackTimeout := T#10S
);

// Логика обработки состояний клапана
xValveError := fbValveControl.GetFeedbackTimeout();

IF xValveError THEN
    // Клапан не открылся в заданное время
    xOpenCommand := FALSE;  // Снимаем команду
    fbValveControl.Reset(); // Сбрасываем состояние
END_IF
```

### Мониторинг производительности

```pascal
// Отслеживание времени отклика устройства
IF fbSignalTimer.GetReceivedFeedback() THEN
    tResponseTime := fbSignalTimer.GetElapsedTime();
    
    // Анализ времени отклика
    IF tResponseTime > T#3S THEN
        xSlowResponse := TRUE;  // Медленный отклик
    ELSIF tResponseTime < T#500MS THEN
        xFastResponse := TRUE;  // Быстрый отклик
    END_IF
    
    fbSignalTimer.ResetReceivedFeedback();
END_IF
```

## Диагностические возможности

### Состояния блока

|Состояние|Условие|Описание|
|---|---|---|
|Норма|`GetReceivedFeedback() = TRUE`|Команда выполнена успешно|
|Ожидание|`IsTimerRunning() = TRUE`|Идет отсчет времени ожидания|
|Таймаут|`GetFeedbackTimeout() = TRUE`|Превышено время ожидания|
|Неактивен|Все флаги FALSE|Команда не подана|

### Временные характеристики

- **Время отклика** - `GetElapsedTime()` при успешном выполнении
- **Превышение таймаута** - `GetFeedbackTimeout() = TRUE`
- **Активность таймера** - `IsTimerRunning()`

## Примечания

- Таймер запускается только при установке флага ожидания обратной связи
- При получении обратной связи таймер автоматически сбрасывается
- Ошибка таймаута сохраняется до явного сброса методом `ResetFeedbackTimeout()` или `Reset()`
- Блок прекращает ожидание обратной связи при срабатывании таймаута
- Рекомендуется регулярно контролировать состояние `GetFeedbackTimeout()` для своевременного обнаружения неисправностей
