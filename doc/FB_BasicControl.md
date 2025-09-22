# Документация функционального блока FB_BasicControl

## Обзор

### Назначение

Функциональный блок `FB_BasicControl` предназначен для базового управления механизмами с использованием условий запуска и остановки. Блок обеспечивает безопасное управление механизмами через проверку предустановленных условий и предоставляет простой интерфейс для контроля исполнительных устройств.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`ControlInterface`|`I_Control`|Интерфейс управления механизмом (любой ФБ механизма, использующий этот интерфейс)|

### Выходные параметры (VAR_OUTPUT)

Блок не имеет выходных параметров.

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_xConditionToStart`|`BOOL`|Условия для разрешения запуска механизма|
|`_xConditionToStop`|`BOOL`|Условия для разрешения остановки механизма|

## Принцип работы

### Логика управления

Блок работает как промежуточный слой между командами управления и механизмом, обеспечивая выполнение команд только при соблюдении заданных условий:

- **Запуск механизма**: выполняется только если `_xConditionToStart = TRUE`
- **Остановка механизма**: выполняется только если `_xConditionToStop = TRUE`

### Паттерн использования

1. Установка условий через методы `SetConditionToStart()` и `SetConditionToStop()`
2. Передача команд управления через методы `Start()` и `Stop()`
3. Блок автоматически проверяет условия перед выполнением команд

## Методы

### SetConditionToStart

**Описание:** Устанавливает условие для разрешения запуска механизма.

**Прототип:**

```pascal
METHOD SetConditionToStart
VAR_INPUT
    x : BOOL;
END_VAR
```

**Параметры:**
- `x` - TRUE = разрешить запуск, FALSE = запретить запуск

**Применение:** Установка предварительных условий безопасности, готовности системы

---

### SetConditionToStop

**Описание:** Устанавливает условие для разрешения остановки механизма.

**Прототип:**

```pascal
METHOD SetConditionToStop
VAR_INPUT
    x : BOOL;
END_VAR
```

**Параметры:**
- `x` - TRUE = разрешить остановку, FALSE = запретить остановку

**Применение:** Контроль безопасной остановки, предотвращение экстренных остановок

---

### Start

**Описание:** Выполняет запуск механизма при соблюдении условий.

**Прототип:**

```pascal
METHOD Start
VAR_INPUT
    cmd : BOOL;
END_VAR
```

**Параметры:**
- `cmd` - команда запуска (TRUE = запустить)

**Функциональность:**
- Запуск выполняется только если `cmd = TRUE` И `_xConditionToStart = TRUE`
- При несоблюдении условий команда игнорируется

---

### Stop

**Описание:** Выполняет остановку механизма при соблюдении условий.

**Прототип:**

```pascal
METHOD Stop
VAR_INPUT
    cmd : BOOL;
END_VAR
```

**Параметры:**
- `cmd` - команда остановки (TRUE = остановить)

**Функциональность:**
- Остановка выполняется только если `cmd = TRUE` И `_xConditionToStop = TRUE`
- При несоблюдении условий команда игнорируется

## Типовые сценарии использования

### Пример 1: Управление вентилятором с проверкой температуры

```pascal
PROGRAM PRG_FanControl
VAR
    fbFan : FB_Mechanism;                    // Механизм вентилятора
    fbFanControl : FB_BasicControl;          // Контроллер вентилятора
    
    // Входные сигналы
    xStartFanCommand : BOOL;                 // Команда запуска вентилятора
    xStopFanCommand : BOOL;                  // Команда остановки вентилятора
    rTemperature : REAL;                     // Текущая температура
    xOverheatProtection : BOOL;              // Защита от перегрева
    xMaintenanceMode : BOOL;                 // Режим обслуживания
    
    // Параметры управления
    rMaxTemperature : REAL := 80.0;          // Максимальная рабочая температура
    rMinTemperature : REAL := 20.0;          // Минимальная температура для запуска
    
    // Состояния
    xTemperatureOK : BOOL;                   // Температура в норме
    xSafeToStart : BOOL;                     // Безопасно запускать
    xSafeToStop : BOOL;                      // Безопасно останавливать
END_VAR

// Подключение механизма к контроллеру
fbFanControl(ref_fbMechanism := fbFan);

// Проверка температурных условий
xTemperatureOK := (rTemperature >= rMinTemperature) AND 
                  (rTemperature <= rMaxTemperature);

// Условия для безопасного запуска
xSafeToStart := xTemperatureOK AND 
                NOT xOverheatProtection AND 
                NOT xMaintenanceMode;

// Условия для безопасной остановки
xSafeToStop := NOT xMaintenanceMode;  // Можно останавливать всегда, кроме обслуживания

// Установка условий в контроллер
fbFanControl.SetConditionToStart(xSafeToStart);
fbFanControl.SetConditionToStop(xSafeToStop);

// Выполнение команд управления
fbFanControl.Start(xStartFanCommand);
fbFanControl.Stop(xStopFanCommand);

// Автоматическая остановка при перегреве
IF xOverheatProtection THEN
    fbFanControl.Stop(TRUE);
    AddAlarmMessage('Fan stopped due to overheat protection');
END_IF

// Информационные сообщения
IF xStartFanCommand AND NOT xSafeToStart THEN
    AddInfoMessage('Fan start blocked: unsafe conditions');
END_IF

IF xStopFanCommand AND NOT xSafeToStop THEN
    AddInfoMessage('Fan stop blocked: maintenance mode active');
END_IF
```

### Пример 2: Управление конвейером с блокировками

```pascal
PROGRAM PRG_ConveyorControl
VAR
    fbConveyor : FB_Mechanism;               // Механизм конвейера
    fbConveyorControl : FB_BasicControl;     // Контроллер конвейера
    
    // Команды управления
    xStartConveyorCommand : BOOL;            // Команда запуска конвейера
    xStopConveyorCommand : BOOL;             // Команда остановки конвейера
    
    // Сигналы безопасности
    xEmergencyStop : BOOL;                   // Аварийная остановка
    xSafetyGateOpen : BOOL;                  // Защитные ворота открыты
    xLightCurtainBroken : BOOL;              // Световая завеса нарушена
    
    // Технологические условия
    xProductPresent : BOOL;                  // Есть продукт на конвейере
    xDownstreamReady : BOOL;                 // Следующий участок готов принять продукт
    xUpstreamActive : BOOL;                  // Предыдущий участок активен
    
    // Техническое состояние
    xMotorHealthy : BOOL;                    // Мотор исправен
    xBeltTensionOK : BOOL;                   // Натяжение ленты в норме
    xSystemReady : BOOL;                     // Система готова к работе
    
    // Обобщенные условия
    xSafetyOK : BOOL;                        // Безопасность соблюдена
    xTechnicalOK : BOOL;                     // Техническое состояние в норме
    xProcessOK : BOOL;                       // Процесс готов
    xCanStart : BOOL;                        // Можно запускать
    xCanStop : BOOL;                         // Можно останавливать
END_VAR

// Подключение механизма к контроллеру
fbConveyorControl(ref_fbMechanism := fbConveyor);

// Проверка условий безопасности
xSafetyOK := NOT xEmergencyStop AND 
             NOT xSafetyGateOpen AND 
             NOT xLightCurtainBroken;

// Проверка технического состояния
xTechnicalOK := xMotorHealthy AND 
                xBeltTensionOK AND 
                xSystemReady;

// Проверка процессных условий
xProcessOK := xDownstreamReady OR NOT xProductPresent;  // Можно работать если есть место или нет продукта

// Общие условия для запуска
xCanStart := xSafetyOK AND xTechnicalOK AND xProcessOK;

// Условия для остановки (всегда можно остановить при соблюдении безопасности)
xCanStop := NOT xEmergencyStop;  // Нельзя управляемо останавливать при аварийном стопе

// Установка условий в контроллер
fbConveyorControl.SetConditionToStart(xCanStart);
fbConveyorControl.SetConditionToStop(xCanStop);

// Выполнение команд управления
fbConveyorControl.Start(xStartConveyorCommand);
fbConveyorControl.Stop(xStopConveyorCommand);

// Принудительная остановка при аварийных ситуациях
IF xEmergencyStop OR xSafetyGateOpen OR xLightCurtainBroken THEN
    fbConveyor.Stop();  // Прямая остановка механизма, минуя контроллер
    AddAlarmMessage('Conveyor emergency stop activated');
END_IF

// Диагностические сообщения
IF xStartConveyorCommand AND NOT xCanStart THEN
    IF NOT xSafetyOK THEN
        AddAlarmMessage('Conveyor start blocked: safety conditions not met');
    ELSIF NOT xTechnicalOK THEN
        AddWarningMessage('Conveyor start blocked: technical problems detected');
    ELSIF NOT xProcessOK THEN
        AddInfoMessage('Conveyor start blocked: downstream not ready');
    END_IF
END_IF
```

## Примечания

- Блок обеспечивает дополнительный уровень безопасности при управлении механизмами
- Использует паттерн "Command" для разделения команд и их выполнения
- Идеально подходит для создания иерархических систем управления
- Упрощает отладку и диагностику проблем управления
- Позволяет создавать переиспользуемые модули управления
- Рекомендуется для критичных применений где безопасность важнее производительности
- Совместим со всеми типами механизмов благодаря использованию ссылок