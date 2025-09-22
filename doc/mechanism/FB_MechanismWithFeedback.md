# Документация функционального блока FB_MechanismWithFeedback

## Обзор

### Назначение

Функциональный блок `FB_MechanismWithFeedback` является расширенной реализацией механизма с функциональностью обратной связи, наследующей от `FB_Mechanism`. Блок обеспечивает мониторинг соответствия между командой управления (питанием) и фактическим состоянием механизма через сигнал обратной связи, предоставляя диагностику различных состояний работы и ошибок.

## Интерфейс функционального блока

### Наследование

```pascal
FB_MechanismWithFeedback EXTENDS FB_Mechanism
```

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`ixFeedback`|`BOOL`|Сигнал обратной связи от механизма|

### Выходные параметры (VAR_OUTPUT)

Блок не добавляет собственных выходных параметров к базовому классу.

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_uFeedbackState`|`E_StateFeedback`|Текущее состояние обратной связи|

### Перечисление E_StateFeedback

```pascal
TYPE E_StateFeedback :
(
    Inactive                   := 0,   // Обратная связь неактивна (норма при остановке)
    Active                     := 1,   // Обратная связь активна (норма при работе)
    Error_NoFeedback           := 2,   // Нет обратной связи при наличии питания
    Error_UnexpectedFeedback   := 3    // Обратная связь есть при отсутствии питания
);
END_TYPE
```

### Наследуемая функциональность

От `FB_Mechanism`:
- `Start()` - метод запуска механизма
- `Stop()` - метод остановки механизма

От `FB_AbstractMechanism`:
- `SetPower(x : BOOL)` - метод установки питания
- `GetPower() : BOOL` - метод получения состояния питания

## Принцип работы

### Логика анализа обратной связи

Блок непрерывно анализирует соответствие между состоянием питания и сигналом обратной связи:

| Питание | Обратная связь | Состояние | Описание |
|---------|----------------|-----------|----------|
| FALSE   | FALSE          | Inactive  | Норма: механизм выключен |
| TRUE    | TRUE           | Active    | Норма: механизм работает |
| TRUE    | FALSE          | Error_NoFeedback | Ошибка: команда подана, но нет подтверждения |
| FALSE   | TRUE           | Error_UnexpectedFeedback | Ошибка: команда не подана, но есть активность |

### Обновление состояния

Метод `UpdateState()` вызывается автоматически в каждом цикле и обновляет внутреннее состояние `_uFeedbackState` на основе текущих значений питания и обратной связи.

## Методы

### GetFeedbackWithoutPower

**Описание:** Проверяет наличие неожиданной обратной связи при отсутствии питания.

**Прототип:**

```pascal
METHOD GetFeedbackWithoutPower : BOOL
```

**Возвращаемое значение:**
- TRUE = обратная связь активна при выключенном питании (ошибка)
- FALSE = нет неожиданной обратной связи

**Применение:** Диагностика заедания контактов, неисправности датчиков положения

---

### GetPowerAndFeedback

**Описание:** Проверяет нормальное соответствие питания и обратной связи.

**Прототип:**

```pascal
METHOD GetPowerAndFeedback : BOOL
```

**Возвращаемое значение:**
- TRUE = питание включено И обратная связь активна (нормальная работа)
- FALSE = нет нормального соответствия

**Применение:** Подтверждение успешного выполнения команды

---

### GetPowerWithoutFeedback

**Описание:** Проверяет отсутствие обратной связи при наличии питания.

**Прототип:**

```pascal
METHOD GetPowerWithoutFeedback : BOOL
```

**Возвращаемое значение:**
- TRUE = питание включено, но нет обратной связи (ошибка)
- FALSE = нет проблем с отсутствием обратной связи

**Применение:** Диагностика неисправности механизма, обрыва цепи обратной связи

---

### GetState

**Описание:** Возвращает текущее состояние анализа обратной связи.

**Прототип:**

```pascal
METHOD GetState : E_StateFeedback
```

**Возвращаемое значение:** Одно из четырех состояний E_StateFeedback

**Применение:** Комплексная диагностика состояния механизма

---

### UpdateState (Protected)

**Описание:** Внутренний метод обновления состояния обратной связи.

**Прототип:**

```pascal
METHOD PROTECTED UpdateState
```

**Функциональность:**
- Анализирует текущие значения питания и обратной связи
- Обновляет внутреннее состояние `_uFeedbackState`
- Вызывается автоматически в каждом цикле

### Наследуемые методы

Все методы от `FB_Mechanism` и `FB_AbstractMechanism` доступны без изменений.

## Типовые сценарии использования

### Пример 1: Контроль привода клапана

```pascal
PROGRAM PRG_ValveControl
VAR
    fbValveActuator : FB_MechanismWithFeedback;
    xOpenCommand : BOOL;            // Команда открытия клапана
    xCloseCommand : BOOL;           // Команда закрытия клапана
    xValveOpenFeedback : BOOL;      // Концевик "клапан открыт"
    
    // Диагностика состояния
    xValveNormal : BOOL;            // Клапан в нормальном состоянии
    xValveError : BOOL;             // Общая ошибка клапана
    sValveStatus : STRING;          // Текстовый статус клапана
END_VAR

// Подключение обратной связи
fbValveActuator(ixFeedback := xValveOpenFeedback);

// Управление клапаном
IF xOpenCommand AND NOT xCloseCommand THEN
    fbValveActuator.Start();        // Подать питание на открытие
ELSIF xCloseCommand AND NOT xOpenCommand THEN
    fbValveActuator.Stop();         // Снять питание (закрытие)
END_IF

// Диагностика состояния клапана
CASE fbValveActuator.GetState() OF
    E_StateFeedback.Inactive:
        xValveNormal := NOT xOpenCommand;
        sValveStatus := 'Valve closed';
        
    E_StateFeedback.Active:
        xValveNormal := xOpenCommand;
        sValveStatus := 'Valve open';
        
    E_StateFeedback.Error_NoFeedback:
        xValveError := TRUE;
        sValveStatus := 'ERROR: Valve not responding';
        
    E_StateFeedback.Error_UnexpectedFeedback:
        xValveError := TRUE;
        sValveStatus := 'ERROR: Valve stuck open';
END_CASE

// Аварийные действия при ошибках
IF xValveError THEN
    xProcessStop := TRUE;
    AddAlarmMessage('Valve feedback error: ' + sValveStatus);
END_IF
```

### Пример 2: Контроль электродвигателя с токовым реле

```pascal
PROGRAM PRG_MotorControl
VAR
    fbMotorControl : FB_MechanismWithFeedback;
    xMotorStartCommand : BOOL;      // Команда пуска мотора
    xMotorStopCommand : BOOL;       // Команда стопа мотора
    xMotorCurrentRelay : BOOL;      // Реле тока (обратная связь)
    
    // Таймер для контроля времени запуска
    tonStartTimeout : TON;
    
    // Состояние мотора
    xMotorRunning : BOOL;           // Мотор работает нормально
    xMotorStartFailed : BOOL;       // Не удалось запустить мотор
    xMotorOverload : BOOL;          // Перегрузка мотора
    sMotorStatus : STRING;          // Статус мотора
END_VAR

// Подключение обратной связи
fbMotorControl(ixFeedback := xMotorCurrentRelay);

// Управление мотором
IF xMotorStartCommand AND NOT xMotorStopCommand THEN
    fbMotorControl.Start();
    tonStartTimeout(IN := TRUE, PT := T#5S);  // Таймаут запуска 5 секунд
ELSE
    fbMotorControl.Stop();
    tonStartTimeout(IN := FALSE);
END_IF

// Контроль таймаута запуска
tonStartTimeout();
IF tonStartTimeout.Q AND fbMotorControl.GetPowerWithoutFeedback() THEN
    xMotorStartFailed := TRUE;
    fbMotorControl.Stop();
    tonStartTimeout(IN := FALSE);
END_IF

// Диагностика состояния мотора
CASE fbMotorControl.GetState() OF
    E_StateFeedback.Inactive:
        IF NOT xMotorStartCommand THEN
            sMotorStatus := 'Motor stopped';
            xMotorRunning := FALSE;
        END_IF
        
    E_StateFeedback.Active:
        IF xMotorStartCommand THEN
            sMotorStatus := 'Motor running';
            xMotorRunning := TRUE;
            xMotorStartFailed := FALSE;  // Сброс ошибки при успешном запуске
        END_IF
        
    E_StateFeedback.Error_NoFeedback:
        sMotorStatus := 'ERROR: Motor not starting';
        xMotorStartFailed := TRUE;
        
    E_StateFeedback.Error_UnexpectedFeedback:
        sMotorStatus := 'ERROR: Motor running without command';
        xMotorOverload := TRUE;
END_CASE

// Аварийные действия
IF xMotorStartFailed OR xMotorOverload THEN
    xMotorStartCommand := FALSE;  // Сброс команды запуска
    AddAlarmMessage('Motor error: ' + sMotorStatus);
END_IF
```

## Сравнение с другими блоками

### FB_MechanismWithFeedback vs FB_Mechanism

|Характеристика|FB_Mechanism|FB_MechanismWithFeedback|
|---|---|---|
|**Обратная связь**|Отсутствует|Встроенная|
|**Диагностика ошибок**|Отсутствует|4 состояния|
|**Сложность**|Минимальная|Средняя|
|**Надежность**|Базовая|Высокая|
|**Применение**|Простые устройства|Критичные системы|

## Примечания

- Блок предоставляет четыре четко определенных состояния обратной связи
- Методы диагностики позволяют быстро определить тип проблемы
- Автоматическое обновление состояния в каждом цикле обеспечивает актуальность данных
- Рекомендуется использовать с внешними таймерами для контроля времени отклика
- Подходит для критичных применений где безопасность имеет первостепенное значение
- Обеспечивает раннее обнаружение неисправностей и предотвращение аварий
- Полностью совместим с интерфейсом I_Control благодаря наследованию