# Документация функционального блока FB_Mechanism

## Обзор

### Назначение

Функциональный блок `FB_Mechanism` является базовой реализацией механизма, наследующей от абстрактного класса `FB_AbstractMechanism`. Блок предоставляет простую и надежную реализацию основных методов управления механизмом с минимальной функциональностью, служащую основой для создания более сложных специализированных механизмов.

## Интерфейс функционального блока

### Наследование

```pascal
FB_Mechanism EXTENDS FB_AbstractMechanism
```

### Входные параметры (VAR_INPUT)

Блок не добавляет собственных входных параметров к базовому классу.

### Выходные параметры (VAR_OUTPUT)

Блок не добавляет собственных выходных параметров к базовому классу.

### Внутренние переменные (VAR)

Блок не добавляет собственных внутренних переменных к базовому классу.

### Наследуемая функциональность

От `FB_AbstractMechanism`:
- `_xPower : BOOL` - приватная переменная состояния питания
- `SetPower(x : BOOL)` - метод установки питания
- `GetPower() : BOOL` - метод получения состояния питания

## Принцип работы

### Реализованные методы

Блок реализует базовые методы управления механизмом, предоставляя простой интерфейс запуска и остановки:

1. **Start()** - запускает механизм (устанавливает питание в TRUE)
2. **Stop()** - останавливает механизм (устанавливает питание в FALSE)

### Логика работы

- Метод `Start()` напрямую вызывает `SetPower(TRUE)`
- Метод `Stop()` напрямую вызывает `SetPower(FALSE)`
- Отсутствуют дополнительные проверки или условия
- Минимальная сложность для максимальной надежности

## Методы

### Start

**Описание:** Запускает механизм путем включения питания.

**Прототип:**

```pascal
METHOD Start
```

**Функциональность:**
- Устанавливает питание механизма в состояние TRUE
- Вызывает унаследованный метод `SetPower(TRUE)`
- Не выполняет дополнительных проверок или условий

---

### Stop

**Описание:** Останавливает механизм путем выключения питания.

**Прототип:**

```pascal
METHOD Stop
```

**Функциональность:**
- Устанавливает питание механизма в состояние FALSE
- Вызывает унаследованный метод `SetPower(FALSE)`
- Гарантированно останавливает механизм

---

### Наследуемые методы

От `FB_AbstractMechanism`:

#### SetPower

**Прототип:**

```pascal
METHOD SetPower
VAR_INPUT
    x : BOOL;
END_VAR
```

#### GetPower

**Прототип:**

```pascal
METHOD GetPower : BOOL
```

## Типовые сценарии использования

### Базовое использование

```pascal
PROGRAM PRG_Main
VAR
    fbSimpleMechanism : FB_Mechanism;
    xStartButton : BOOL;          // Кнопка пуска
    xStopButton : BOOL;           // Кнопка стопа
    xMechanismRunning : BOOL;     // Состояние работы
    xMechanismPower : BOOL;       // Состояние питания
END_VAR

// Управление механизмом кнопками
IF xStartButton THEN
    fbSimpleMechanism.Start();
    xStartButton := FALSE;        // Сброс кнопки
END_IF

IF xStopButton THEN
    fbSimpleMechanism.Stop();
    xStopButton := FALSE;         // Сброс кнопки
END_IF

// Получение состояния
xMechanismPower := fbSimpleMechanism.GetPower();
xMechanismRunning := xMechanismPower;  // Для простого механизма это одно и то же

// Индикация состояния
IF xMechanismRunning THEN
    // Включить индикатор "Работа"
    xRunIndicator := TRUE;
ELSE
    // Выключить индикатор "Работа"
    xRunIndicator := FALSE;
END_IF
```

### Использование с внешними условиями

```pascal
VAR
    fbConditionalMechanism : FB_Mechanism;
    xOperatorEnable : BOOL;       // Разрешение оператора
    xSafetyOK : BOOL;            // Условия безопасности
    xAutoMode : BOOL;            // Автоматический режим
    xManualStart : BOOL;         // Ручной пуск
    xEmergencyStop : BOOL;       // Аварийный стоп
END_VAR

// Автоматический режим
IF xAutoMode AND xOperatorEnable AND xSafetyOK THEN
    fbConditionalMechanism.Start();
END_IF

// Ручной режим
IF NOT xAutoMode AND xManualStart AND xOperatorEnable AND xSafetyOK THEN
    fbConditionalMechanism.Start();
END_IF

// Остановка по условиям
IF xEmergencyStop OR NOT xSafetyOK OR NOT xOperatorEnable THEN
    fbConditionalMechanism.Stop();
END_IF

// Остановка в ручном режиме
IF NOT xAutoMode AND NOT xManualStart THEN
    fbConditionalMechanism.Stop();
END_IF
```

### Массовое управление механизмами

```pascal
VAR
    afbMechanisms : ARRAY[1..5] OF FB_Mechanism;
    xStartAllButton : BOOL;      // Пуск всех механизмов
    xStopAllButton : BOOL;       // Стоп всех механизмов
    axMechanismStates : ARRAY[1..5] OF BOOL;  // Состояния механизмов
    nRunningCount : INT;         // Количество работающих механизмов
    i : INT;
END_VAR

// Пуск всех механизмов
IF xStartAllButton THEN
    FOR i := 1 TO 5 DO
        afbMechanisms[i].Start();
    END_FOR
    xStartAllButton := FALSE;
END_IF

// Стоп всех механизмов
IF xStopAllButton THEN
    FOR i := 1 TO 5 DO
        afbMechanisms[i].Stop();
    END_FOR
    xStopAllButton := FALSE;
END_IF

// Мониторинг состояний
nRunningCount := 0;
FOR i := 1 TO 5 DO
    axMechanismStates[i] := afbMechanisms[i].GetPower();
    IF axMechanismStates[i] THEN
        nRunningCount := nRunningCount + 1;
    END_IF
END_FOR
```

### Интеграция с системой последовательного управления

```pascal
VAR
    fbMechanism1 : FB_Mechanism;
    fbMechanism2 : FB_Mechanism;
    fbMechanism3 : FB_Mechanism;
    eSequenceStep : E_SequenceStep;
    tonStepDelay : TON;
    xSequenceStart : BOOL;
    xSequenceStop : BOOL;
    xSequenceComplete : BOOL;
END_VAR

TYPE E_SequenceStep : 
(
    Idle,
    StartMech1,
    WaitMech1,
    StartMech2,
    WaitMech2,
    StartMech3,
    Running,
    StopSequence,
    Complete
);
END_TYPE

// Машина состояний для последовательного пуска
CASE eSequenceStep OF
    E_SequenceStep.Idle:
        IF xSequenceStart THEN
            eSequenceStep := E_SequenceStep.StartMech1;
        END_IF
        
    E_SequenceStep.StartMech1:
        fbMechanism1.Start();
        tonStepDelay(IN := TRUE, PT := T#2S);
        eSequenceStep := E_SequenceStep.WaitMech1;
        
    E_SequenceStep.WaitMech1:
        tonStepDelay(IN := TRUE, PT := T#2S);
        IF tonStepDelay.Q THEN
            tonStepDelay(IN := FALSE);
            eSequenceStep := E_SequenceStep.StartMech2;
        END_IF
        
    E_SequenceStep.StartMech2:
        fbMechanism2.Start();
        tonStepDelay(IN := TRUE, PT := T#2S);
        eSequenceStep := E_SequenceStep.WaitMech2;
        
    E_SequenceStep.WaitMech2:
        tonStepDelay(IN := TRUE, PT := T#2S);
        IF tonStepDelay.Q THEN
            tonStepDelay(IN := FALSE);
            eSequenceStep := E_SequenceStep.StartMech3;
        END_IF
        
    E_SequenceStep.StartMech3:
        fbMechanism3.Start();
        eSequenceStep := E_SequenceStep.Running;
        
    E_SequenceStep.Running:
        xSequenceComplete := TRUE;
        IF xSequenceStop THEN
            eSequenceStep := E_SequenceStep.StopSequence;
        END_IF
        
    E_SequenceStep.StopSequence:
        // Остановка в обратном порядке
        fbMechanism3.Stop();
        fbMechanism2.Stop();
        fbMechanism1.Stop();
        eSequenceStep := E_SequenceStep.Complete;
        
    E_SequenceStep.Complete:
        xSequenceComplete := FALSE;
        eSequenceStep := E_SequenceStep.Idle;
END_CASE

// Аварийная остановка всей последовательности
IF xEmergencyStop THEN
    fbMechanism1.Stop();
    fbMechanism2.Stop();
    fbMechanism3.Stop();
    eSequenceStep := E_SequenceStep.Idle;
    tonStepDelay(IN := FALSE);
END_IF
```

### Использование с обратной связью

```pascal
VAR
    fbMechanismWithFeedback : FB_Mechanism;
    xRunCommand : BOOL;          // Команда запуска
    xFeedbackSignal : BOOL;      // Сигнал обратной связи от механизма
    tonFeedbackTimeout : TON;    // Таймер ожидания обратной связи
    xMechanismFault : BOOL;      // Ошибка механизма
    eMechanismState : E_MechanismState;
END_VAR

TYPE E_MechanismState : (Stopped, Starting, Running, Stopping, Fault);

// Управление с учетом обратной связи
CASE eMechanismState OF
    E_MechanismState.Stopped:
        IF xRunCommand THEN
            fbMechanismWithFeedback.Start();
            tonFeedbackTimeout(IN := TRUE, PT := T#5S);
            eMechanismState := E_MechanismState.Starting;
        END_IF
        
    E_MechanismState.Starting:
        tonFeedbackTimeout();
        IF xFeedbackSignal THEN
            // Получена обратная связь - механизм запустился
            tonFeedbackTimeout(IN := FALSE);
            eMechanismState := E_MechanismState.Running;
        ELSIF tonFeedbackTimeout.Q THEN
            // Таймаут - ошибка запуска
            fbMechanismWithFeedback.Stop();
            tonFeedbackTimeout(IN := FALSE);
            eMechanismState := E_MechanismState.Fault;
        END_IF
        
    E_MechanismState.Running:
        IF NOT xRunCommand THEN
            fbMechanismWithFeedback.Stop();
            tonFeedbackTimeout(IN := TRUE, PT := T#3S);
            eMechanismState := E_MechanismState.Stopping;
        ELSIF NOT xFeedbackSignal THEN
            // Потеряна обратная связь во время работы
            fbMechanismWithFeedback.Stop();
            eMechanismState := E_MechanismState.Fault;
        END_IF
        
    E_MechanismState.Stopping:
        tonFeedbackTimeout();
        IF NOT xFeedbackSignal THEN
            // Обратная связь пропала - механизм остановился
            tonFeedbackTimeout(IN := FALSE);
            eMechanismState := E_MechanismState.Stopped;
        ELSIF tonFeedbackTimeout.Q THEN
            // Таймаут - возможная ошибка остановки
            tonFeedbackTimeout(IN := FALSE);
            eMechanismState := E_MechanismState.Fault;
        END_IF
        
    E_MechanismState.Fault:
        xMechanismFault := TRUE;
        fbMechanismWithFeedback.Stop();
        // Сброс ошибки по команде или автоматически
        IF xResetFault AND NOT xRunCommand THEN
            xMechanismFault := FALSE;
            eMechanismState := E_MechanismState.Stopped;
        END_IF
END_CASE
```

## Расширение функциональности

### Создание производного класса с дополнительной логикой

```pascal
FUNCTION_BLOCK FB_EnhancedMechanism EXTENDS FB_Mechanism
VAR_INPUT
    ixEnableInput : BOOL;        // Вход разрешения
    ixResetInput : BOOL;         // Вход сброса
END_VAR
VAR_OUTPUT
    qxReadyOutput : BOOL;        // Выход готовности
    qxFaultOutput : BOOL;        // Выход ошибки
END_VAR
VAR
    _xEnabled : BOOL := FALSE;   // Состояние разрешения
    _xFault : BOOL := FALSE;     // Состояние ошибки
    _tonStartDelay : TON;        // Задержка запуска
END_VAR

// Переопределение метода Start с дополнительными проверками
METHOD Start
    IF _xEnabled AND NOT _xFault THEN
        // Запуск с задержкой
        _tonStartDelay(IN := TRUE, PT := T#1S);
        IF _tonStartDelay.Q THEN
            SUPER^.Start();  // Вызов родительского метода
        END_IF
    END_IF
END_METHOD

// Переопределение метода Stop
METHOD Stop
    SUPER^.Stop();  // Вызов родительского метода
    _tonStartDelay(IN := FALSE);  // Сброс таймера
END_METHOD

// Дополнительная логика
_xEnabled := ixEnableInput;

// Сброс ошибки
IF ixResetInput THEN
    _xFault := FALSE;
END_IF

// Обновление выходов
qxReadyOutput := _xEnabled AND NOT _xFault;
qxFaultOutput := _xFault;

END_FUNCTION_BLOCK
```

### Интеграция с интерфейсами

```pascal
// FB_Mechanism уже совместим с интерфейсом I_Control
// благодаря реализации методов Start() и Stop()

VAR
    fbMechanism : FB_Mechanism;
    ifcControllable : I_Control;
END_VAR

// Полиморфное использование через интерфейс
ifcControllable := fbMechanism;

// Управление через интерфейс
ifcControllable.Start();
ifcControllable.Stop();
```

## Диагностические возможности

### Простая диагностика

```pascal
VAR
    fbDiagMechanism : FB_Mechanism;
    stMechanismStatus : ST_MechanismStatus;
    tonRunTime : TON;
END_VAR

TYPE ST_MechanismStatus :
STRUCT
    xIsRunning : BOOL;           // Работает ли механизм
    tRunTime : TIME;             // Время работы в текущем цикле
    dtLastStart : DT;            // Время последнего запуска
    dtLastStop : DT;             // Время последней остановки
    nStartCount : UDINT;         // Количество запусков
END_STRUCT
END_TYPE

// Мониторинг состояния
stMechanismStatus.xIsRunning := fbDiagMechanism.GetPower();

// Учет времени работы
tonRunTime(IN := stMechanismStatus.xIsRunning, PT := T#0S);
stMechanismStatus.tRunTime := tonRunTime.ET;

// Фиксация событий запуска/остановки
VAR
    rtStart : R_TRIG;
    rtStop : R_TRIG;
END_VAR

rtStart(CLK := stMechanismStatus.xIsRunning);
rtStop(CLK := NOT stMechanismStatus.xIsRunning);

IF rtStart.Q THEN
    stMechanismStatus.dtLastStart := NOW();
    stMechanismStatus.nStartCount := stMechanismStatus.nStartCount + 1;
END_IF

IF rtStop.Q THEN
    stMechanismStatus.dtLastStop := NOW();
END_IF
```

## Сравнение с другими блоками

### FB_Mechanism vs FB_AbstractMechanism

|Характеристика|FB_AbstractMechanism|FB_Mechanism|
|---|---|---|
|**Тип**|Абстрактный класс|Конкретная реализация|
|**Использование**|Только как базовый класс|Готов к использованию|
|**Методы Start/Stop**|Отсутствуют|Реализованы|
|**Сложность**|Минимальная|Минимальная|
|**Расширяемость**|Требует наследование|Может использоваться как есть|

### FB_Mechanism vs FB_MechanismWithFeedback

|Характеристика|FB_Mechanism|FB_MechanismWithFeedback|
|---|---|---|
|**Обратная связь**|Отсутствует|Встроенная|
|**Диагностика**|Базовая|Расширенная|
|**Сложность логики**|Простая|Средняя|

### Рекомендации по расширению

```pascal
// Хороший подход - наследование с добавлением функциональности
FUNCTION_BLOCK FB_MySpecialMechanism EXTENDS FB_Mechanism
    // Добавить входы/выходы
    // Переопределить методы при необходимости
    // Добавить дополнительную логику
END_FUNCTION_BLOCK

// Плохой подход - модификация исходного кода FB_Mechanism
// Это нарушает принципы ООП и усложняет поддержку
```

## Примечания

- Блок предоставляет минимальную, но полную реализацию механизма
- Методы `Start()` и `Stop()` делают блок совместимым с интерфейсом `I_Control`
- Отсутствие дополнительной логики обеспечивает максимальную производительность
- Может служить основой для создания более сложных механизмов
- Рекомендуется для некритичных применений где важна простота
- При необходимости дополнительной функциональности используйте наследование
- Полностью совместим с полиморфным использованием через базовый класс
- Подходит для массового использования в простых системах автоматизации
- Обеспечивает единообразный интерфейс управления во всей системе
