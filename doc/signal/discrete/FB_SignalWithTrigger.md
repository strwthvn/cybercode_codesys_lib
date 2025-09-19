# Документация функционального блока FB_SignalWithTrigger

## Обзор

### Назначение

Функциональный блок `FB_SignalWithTrigger` предназначен для обнаружения фронтов цифрового сигнала. Блок наследуется от `FB_BasicSignal` и добавляет функциональность детектирования переднего (0→1) и заднего (1→0) фронтов входного сигнала.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`ixSignal`|`BOOL`|Входной сигнал для обработки (наследуется от FB_BasicSignal)|

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_rt_xSignal`|`R_TRIG`|Детектор переднего фронта (0→1)|
|`_ft_xSignal`|`F_TRIG`|Детектор заднего фронта (1→0)|

## Принцип работы

1. Блок непрерывно отслеживает состояние входного сигнала
2. При изменении сигнала с FALSE на TRUE генерируется передний фронт
3. При изменении сигнала с TRUE на FALSE генерируется задний фронт
4. Фронты представляют собой однократные импульсы длительностью в один цикл сканирования ПЛК

## Методы

### GetRtrig

**Описание:** Возвращает состояние детектора переднего фронта.

**Прототип:**

```pascal
METHOD GetRtrig : BOOL
```

**Возвращаемое значение:**
- TRUE = обнаружен передний фронт (0→1) в текущем цикле
- FALSE = передний фронт не обнаружен

**Особенности:**
- Импульс длится только один цикл сканирования ПЛК
- Активируется при каждом переходе сигнала из FALSE в TRUE

---

### GetFtrig

**Описание:** Возвращает состояние детектора заднего фронта.

**Прототип:**

```pascal
METHOD GetFtrig : BOOL
```

**Возвращаемое значение:**
- TRUE = обнаружен задний фронт (1→0) в текущем цикле
- FALSE = задний фронт не обнаружен

**Особенности:**
- Импульс длится только один цикл сканирования ПЛК
- Активируется при каждом переходе сигнала из TRUE в FALSE

---

### Наследуемые методы

Блок наследует методы от `FB_BasicSignal`:

- `GetSignal() : BOOL` - получение текущего состояния входного сигнала
- `GetInvertedSignal() : BOOL` - получение инвертированного входного сигнала

## Типовые сценарии использования

### Базовое использование

```pascal
PROGRAM PRG_Main
VAR
    fbTriggerDetector : FB_SignalWithTrigger;
    xInputSignal : BOOL;          // Входной сигнал
    xStartCommand : BOOL;         // Команда старта по фронту
    xStopCommand : BOOL;          // Команда стопа по фронту
END_VAR

// Обработка сигнала с детекцией фронтов
fbTriggerDetector(ixSignal := xInputSignal);

// Команды по фронтам
xStartCommand := fbTriggerDetector.GetRtrig();  // Старт по переднему фронту
xStopCommand := fbTriggerDetector.GetFtrig();   // Стоп по заднему фронту

// Логика управления
IF xStartCommand THEN
    // Выполнение действий при включении
    xMotorRun := TRUE;
END_IF

IF xStopCommand THEN
    // Выполнение действий при выключении
    xMotorRun := FALSE;
END_IF
```

### Счетчик импульсов

```pascal
VAR
    fbPulseCounter : FB_SignalWithTrigger;
    xPulseInput : BOOL;           // Входные импульсы
    nPulseCount : UINT := 0;      // Счетчик импульсов
    xResetCounter : BOOL;         // Сброс счетчика
END_VAR

fbPulseCounter(ixSignal := xPulseInput);

// Подсчет импульсов по переднему фронту
IF fbPulseCounter.GetRtrig() THEN
    nPulseCount := nPulseCount + 1;
END_IF

// Сброс счетчика
IF xResetCounter THEN
    nPulseCount := 0;
    xResetCounter := FALSE;
END_IF
```

### Обработка кнопок

```pascal
VAR
    fbButtonProcessor : FB_SignalWithTrigger;
    xButton : BOOL;               // Состояние кнопки
    xButtonPressed : BOOL;        // Кнопка нажата (импульс)
    xButtonReleased : BOOL;       // Кнопка отпущена (импульс)
    xToggleState : BOOL := FALSE; // Состояние переключателя
END_VAR

fbButtonProcessor(ixSignal := xButton);

// Обработка нажатий кнопки
xButtonPressed := fbButtonProcessor.GetRtrig();
xButtonReleased := fbButtonProcessor.GetFtrig();

// Переключатель по нажатию кнопки
IF xButtonPressed THEN
    xToggleState := NOT xToggleState;
END_IF

// Действия при отпускании кнопки
IF xButtonReleased THEN
    // Завершение операции
END_IF
```

### Синхронизация процессов

```pascal
VAR
    fbSyncTrigger : FB_SignalWithTrigger;
    xSyncSignal : BOOL;           // Сигнал синхронизации
    xStartCycle : BOOL;           // Начало цикла
    xEndCycle : BOOL;             // Конец цикла
    eProcessState : E_ProcessState; // Состояние процесса
END_VAR

fbSyncTrigger(ixSignal := xSyncSignal);

xStartCycle := fbSyncTrigger.GetRtrig();
xEndCycle := fbSyncTrigger.GetFtrig();

// Конечный автомат с синхронизацией
CASE eProcessState OF
    E_ProcessState.Idle:
        IF xStartCycle THEN
            eProcessState := E_ProcessState.Running;
            // Инициализация процесса
        END_IF
        
    E_ProcessState.Running:
        // Выполнение процесса
        IF xEndCycle THEN
            eProcessState := E_ProcessState.Finishing;
        END_IF
        
    E_ProcessState.Finishing:
        // Завершение процесса
        eProcessState := E_ProcessState.Idle;
END_CASE
```

### Измерение времени между событиями

```pascal
VAR
    fbEventTrigger : FB_SignalWithTrigger;
    xEventSignal : BOOL;          // Сигнал события
    tonEventTimer : TON;          // Таймер между событиями
    tEventInterval : TIME;        // Интервал между событиями
    xMeasuring : BOOL := FALSE;   // Флаг измерения
END_VAR

fbEventTrigger(ixSignal := xEventSignal);

// Измерение интервала между передними фронтами
IF fbEventTrigger.GetRtrig() THEN
    IF xMeasuring THEN
        // Второе событие - фиксируем интервал
        tEventInterval := tonEventTimer.ET;
        tonEventTimer(IN := FALSE); // Сброс таймера
        xMeasuring := FALSE;
    ELSE
        // Первое событие - начинаем измерение
        tonEventTimer(IN := TRUE, PT := T#0S);
        xMeasuring := TRUE;
    END_IF
END_IF

// Работа таймера
tonEventTimer();
```

### Формирование команд управления

```pascal
VAR
    fbCommandTrigger : FB_SignalWithTrigger;
    xOperatorSwitch : BOOL;       // Переключатель оператора
    xStartCommand : BOOL;         // Импульсная команда пуска
    xStopCommand : BOOL;          // Импульсная команда останова
    xSystemRunning : BOOL;        // Состояние системы
END_VAR

fbCommandTrigger(ixSignal := xOperatorSwitch);

// Формирование импульсных команд
xStartCommand := fbCommandTrigger.GetRtrig() AND NOT xSystemRunning;
xStopCommand := fbCommandTrigger.GetFtrig() AND xSystemRunning;

// Управление системой
IF xStartCommand THEN
    xSystemRunning := TRUE;
    // Последовательность пуска
END_IF

IF xStopCommand THEN
    xSystemRunning := FALSE;
    // Последовательность останова
END_IF
```

## Диагностические возможности

### Состояния блока

|Состояние|Метод|Описание|
|---|---|---|
|Текущий сигнал|`GetSignal()`|Актуальное состояние входа|
|Передний фронт|`GetRtrig()`|Момент включения сигнала|
|Задний фронт|`GetFtrig()`|Момент выключения сигнала|
|Инвертированный сигнал|`GetInvertedSignal()`|Инверсия входного сигнала|

### Мониторинг активности

```pascal
// Подсчет активности сигнала
VAR
    nRisingEdges : UINT := 0;     // Количество передних фронтов
    nFallingEdges : UINT := 0;    // Количество задних фронтов
    tLastActivity : TIME;         // Время последней активности
END_VAR

IF fbTriggerDetector.GetRtrig() THEN
    nRisingEdges := nRisingEdges + 1;
    tLastActivity := TIME();
END_IF

IF fbTriggerDetector.GetFtrig() THEN
    nFallingEdges := nFallingEdges + 1;
    tLastActivity := TIME();
END_IF
```

## Примечания

- Фронты генерируются только при реальном изменении состояния сигнала
- Продолжительность импульса фронта равна одному циклу сканирования ПЛК
- Блок не имеет внутренней памяти предыдущих фронтов - импульсы не накапливаются
- Для надежного обнаружения фронтов входной сигнал должен быть стабильным не менее одного цикла
- Рекомендуется использовать этот блок для формирования команд, требующих однократного выполнения
- При работе с быстрыми сигналами следует учитывать время цикла ПЛК и при необходимости использовать аппаратные прерывания
