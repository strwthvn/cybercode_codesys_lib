# Документация функционального блока FB_AbstractMechanism

## Обзор

### Назначение

Функциональный блок `FB_AbstractMechanism` является абстрактным базовым классом для всех механизмов в системе автоматизации. Блок определяет базовую структуру и интерфейс для управления питанием механизмов, обеспечивая единообразный подход к разработке различных типов исполнительных устройств через принципы объектно-ориентированного программирования.

### Область применения

- Базовый класс для создания специализированных механизмов
- Унификация интерфейса управления питанием устройств
- Стандартизация архитектуры системы управления механизмами
- Основа для реализации принципов ООП в промышленной автоматизации
- Создание масштабируемых и поддерживаемых решений

**Важно:** Данный блок является абстрактным и не может использоваться напрямую. Необходимо создавать производные классы, наследующие его функциональность.

## Интерфейс функционального блока

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_xPower`|`BOOL`|Состояние питания механизма (приватная переменная)|

### Примечание по архитектуре

Блок намеренно не содержит входных и выходных параметров (VAR_INPUT/VAR_OUTPUT), так как конкретная реализация интерфейса зависит от типа механизма и определяется в производных классах.

## Принцип работы

### Базовая функциональность

1. **Управление питанием**: Предоставляет методы для включения/выключения питания механизма
2. **Инкапсуляция состояния**: Скрывает внутреннее состояние питания за методами доступа
3. **Расширяемость**: Служит основой для создания специализированных механизмов

### Архитектурные принципы

- **Абстракция**: Определяет общий интерфейс без привязки к конкретной реализации
- **Инкапсуляция**: Внутренняя переменная `_xPower` доступна только через методы
- **Наследование**: Производные классы расширяют базовую функциональность
- **Полиморфизм**: Единый интерфейс для различных типов механизмов

## Методы

### SetPower

**Описание:** Устанавливает состояние питания механизма.

**Прототип:**

```pascal
METHOD SetPower
VAR_INPUT
    x : BOOL;  // Требуемое состояние питания
END_VAR
```

**Параметры:**
- `x` - TRUE для включения питания, FALSE для выключения

**Функциональность:**
- Устанавливает внутреннюю переменную `_xPower` в указанное состояние
- Базовый метод для управления питанием любого механизма

---

### GetPower

**Описание:** Возвращает текущее состояние питания механизма.

**Прототип:**

```pascal
METHOD GetPower : BOOL
```

**Возвращаемое значение:**
- TRUE = питание включено
- FALSE = питание выключено

**Функциональность:**
- Предоставляет доступ только для чтения к состоянию питания
- Обеспечивает инкапсуляцию внутренней переменной

## Создание производных классов

### Простой механизм

```pascal
FUNCTION_BLOCK FB_SimpleMechanism EXTENDS FB_AbstractMechanism
VAR_INPUT
    ixStartCommand : BOOL;        // Команда запуска
    ixStopCommand : BOOL;         // Команда остановки
END_VAR
VAR_OUTPUT
    qxRunning : BOOL;             // Состояние работы
    qxFault : BOOL;               // Ошибка механизма
END_VAR
VAR
    _xRunning : BOOL := FALSE;    // Внутреннее состояние работы
END_VAR

// Основная логика работы
IF ixStartCommand AND GetPower() THEN
    _xRunning := TRUE;
END_IF

IF ixStopCommand OR NOT GetPower() THEN
    _xRunning := FALSE;
END_IF

// Обновление выходов
qxRunning := _xRunning AND GetPower();
qxFault := _xRunning AND NOT GetPower();  // Ошибка если работает без питания

END_FUNCTION_BLOCK
```

### Механизм с защитой

```pascal
FUNCTION_BLOCK FB_ProtectedMechanism EXTENDS FB_AbstractMechanism
VAR_INPUT
    ixEnable : BOOL;              // Разрешение работы
    ixReset : BOOL;               // Сброс ошибок
END_VAR
VAR_OUTPUT
    qxReady : BOOL;               // Готовность к работе
    qxError : BOOL;               // Ошибка
END_VAR
VAR
    _xOverloadProtection : BOOL := FALSE;  // Защита от перегрузки
    _tonStartDelay : TON;                  // Задержка запуска
END_VAR

// Задержка включения питания
_tonStartDelay(IN := ixEnable, PT := T#2S);

// Управление питанием с защитой
IF _tonStartDelay.Q AND NOT _xOverloadProtection THEN
    SetPower(TRUE);
ELSE
    SetPower(FALSE);
END_IF

// Сброс защиты
IF ixReset THEN
    _xOverloadProtection := FALSE;
END_IF

// Обновление выходов
qxReady := GetPower() AND ixEnable;
qxError := _xOverloadProtection;

END_FUNCTION_BLOCK
```

### Механизм с диагностикой

```pascal
FUNCTION_BLOCK FB_DiagnosticMechanism EXTENDS FB_AbstractMechanism
VAR_INPUT
    ixMaintenanceMode : BOOL;     // Режим обслуживания
END_VAR
VAR_OUTPUT
    qnOperatingHours : UDINT;     // Наработка в часах
    qxMaintenanceRequired : BOOL; // Требуется обслуживание
END_VAR
VAR
    _tonOperatingTime : TON;      // Таймер наработки
    _nTotalOperatingTime : UDINT := 0;  // Общее время работы (мс)
    _nMaintenanceInterval : UDINT := 8760; // Интервал ТО (часы)
END_VAR

// Учет времени работы при включенном питании
_tonOperatingTime(IN := GetPower(), PT := T#1H);

IF _tonOperatingTime.Q THEN
    _tonOperatingTime(IN := FALSE);
    _nTotalOperatingTime := _nTotalOperatingTime + 1;
END_IF

// Расчет наработки в часах
qnOperatingHours := _nTotalOperatingTime;

// Определение необходимости обслуживания
qxMaintenanceRequired := (qnOperatingHours >= _nMaintenanceInterval) 
                        AND NOT ixMaintenanceMode;

// Сброс счетчика при обслуживании
IF ixMaintenanceMode AND qxMaintenanceRequired THEN
    _nTotalOperatingTime := 0;
END_IF

END_FUNCTION_BLOCK
```

## Типовые сценарии использования

### Базовое наследование

```pascal
PROGRAM PRG_Main
VAR
    fbMyMechanism : FB_SimpleMechanism;
    xStart : BOOL;                // Кнопка пуска
    xStop : BOOL;                 // Кнопка стопа
    xPowerEnable : BOOL;          // Разрешение питания
    xMechanismRunning : BOOL;     // Состояние работы
END_VAR

// Управление питанием напрямую через базовый класс
fbMyMechanism.SetPower(xPowerEnable);

// Использование производного функционала
fbMyMechanism(
    ixStartCommand := xStart,
    ixStopCommand := xStop
);

// Получение состояния
xMechanismRunning := fbMyMechanism.qxRunning;

// Проверка питания через базовый метод
IF NOT fbMyMechanism.GetPower() THEN
    // Питание отключено - механизм недоступен
    AddWarningMessage('Mechanism power is OFF');
END_IF
```

### Полиморфное использование

```pascal
VAR
    afbMechanisms : ARRAY[1..3] OF POINTER TO FB_AbstractMechanism;
    fbMotor : FB_SimpleMechanism;
    fbPump : FB_ProtectedMechanism;
    fbFan : FB_DiagnosticMechanism;
    i : INT;
    xGlobalPowerEnable : BOOL;    // Общее разрешение питания
END_VAR

// Инициализация массива указателей
afbMechanisms[1] := ADR(fbMotor);
afbMechanisms[2] := ADR(fbPump);
afbMechanisms[3] := ADR(fbFan);

// Полиморфное управление всеми механизмами
FOR i := 1 TO 3 DO
    IF afbMechanisms[i] <> 0 THEN
        // Использование общего интерфейса базового класса
        afbMechanisms[i]^.SetPower(xGlobalPowerEnable);
        
        // Логирование состояния питания
        IF afbMechanisms[i]^.GetPower() THEN
            LogMessage(CONCAT('Mechanism ', INT_TO_STRING(i), ' powered ON'));
        ELSE
            LogMessage(CONCAT('Mechanism ', INT_TO_STRING(i), ' powered OFF'));
        END_IF
    END_IF
END_FOR
```

### Расширенное наследование с интерфейсами

```pascal
// Использование с интерфейсом управления
FUNCTION_BLOCK FB_ControllableMechanism EXTENDS FB_AbstractMechanism IMPLEMENTS I_Control
VAR_INPUT
    ixEmergencyStop : BOOL;       // Аварийный стоп
END_VAR
VAR
    _xStarted : BOOL := FALSE;    // Состояние запуска
END_VAR

// Реализация методов интерфейса I_Control
METHOD Start
    IF GetPower() AND NOT ixEmergencyStop THEN
        _xStarted := TRUE;
    END_IF
END_METHOD

METHOD Stop
    _xStarted := FALSE;
END_METHOD

// Переопределение базового метода
METHOD SetPower
VAR_INPUT
    x : BOOL;
END_VAR
    // Вызов родительского метода
    SUPER^.SetPower(x);
    
    // Дополнительная логика
    IF NOT x THEN
        _xStarted := FALSE;  // Автоматическая остановка при отключении питания
    END_IF
END_METHOD

END_FUNCTION_BLOCK
```

## Архитектурные паттерны

### Паттерн "Фабрика механизмов"

```pascal
FUNCTION_BLOCK FB_MechanismFactory
VAR_INPUT
    eMechanismType : E_MechanismType;
END_VAR
VAR_OUTPUT
    pMechanism : POINTER TO FB_AbstractMechanism;
END_VAR
VAR
    fbSimpleMech : FB_SimpleMechanism;
    fbProtectedMech : FB_ProtectedMechanism;
    fbDiagnosticMech : FB_DiagnosticMechanism;
END_VAR

TYPE E_MechanismType : (Simple, Protected, Diagnostic);

// Создание механизма нужного типа
CASE eMechanismType OF
    E_MechanismType.Simple:
        pMechanism := ADR(fbSimpleMech);
    E_MechanismType.Protected:
        pMechanism := ADR(fbProtectedMech);
    E_MechanismType.Diagnostic:
        pMechanism := ADR(fbDiagnosticMech);
    ELSE
        pMechanism := 0;
END_CASE

END_FUNCTION_BLOCK
```

### Паттерн "Менеджер механизмов"

```pascal
FUNCTION_BLOCK FB_MechanismManager
VAR_INPUT
    ixGlobalEnable : BOOL;        // Общее разрешение
    ixEmergencyStop : BOOL;       // Аварийный стоп
END_VAR
VAR_OUTPUT
    qnActiveMechanisms : INT;     // Количество активных механизмов
    qnTotalMechanisms : INT;      // Общее количество механизмов
END_VAR
VAR
    aMechanisms : ARRAY[1..10] OF POINTER TO FB_AbstractMechanism;
    _nMechanismCount : INT := 0;
END_VAR

// Регистрация механизма в менеджере
METHOD RegisterMechanism
VAR_INPUT
    pMechanism : POINTER TO FB_AbstractMechanism;
END_VAR
    IF _nMechanismCount < 10 AND pMechanism <> 0 THEN
        _nMechanismCount := _nMechanismCount + 1;
        aMechanisms[_nMechanismCount] := pMechanism;
    END_IF
END_METHOD

// Управление всеми зарегистрированными механизмами
METHOD UpdateAll
VAR
    i : INT;
    nActive : INT := 0;
END_VAR
    FOR i := 1 TO _nMechanismCount DO
        IF aMechanisms[i] <> 0 THEN
            // Управление питанием
            aMechanisms[i]^.SetPower(ixGlobalEnable AND NOT ixEmergencyStop);
            
            // Подсчет активных механизмов
            IF aMechanisms[i]^.GetPower() THEN
                nActive := nActive + 1;
            END_IF
        END_IF
    END_FOR
    
    qnActiveMechanisms := nActive;
    qnTotalMechanisms := _nMechanismCount;
END_METHOD

END_FUNCTION_BLOCK
```

## Рекомендации по проектированию

### Принципы наследования

1. **Расширение, а не изменение**: Производные классы должны добавлять функциональность, не нарушая работу базового класса
2. **Соблюдение контракта**: Переопределенные методы должны сохранять семантику базовых методов
3. **Принцип подстановки Лисков**: Объекты производных классов должны быть взаимозаменяемы с базовыми

### Правила именования

```pascal
// Рекомендуемая структура имен для производных классов
FB_BasicMotor          // Простой мотор
FB_ServoMotor          // Сервомотор (расширение базового)
FB_StepperMotor        // Шаговый мотор (расширение базового)

FB_BasicPump           // Простой насос
FB_VariableSpeedPump   // Насос с переменной скоростью
FB_DosierPump          // Дозировочный насос

FB_BasicValve          // Простой клапан
FB_ProportionalValve   // Пропорциональный клапан
FB_SafetyValve         // Предохранительный клапан
```

## Примечания

- Блок является фундаментом для всей иерархии механизмов в системе
- Обеспечивает единообразный интерфейс управления питанием для всех производных классов
- Приватная переменная `_xPower` доступна только через методы, обеспечивая инкапсуляцию
- Рекомендуется использовать совместно с интерфейсами (например, `I_Control`) для дополнительной стандартизации
- При создании производных классов следует переопределять методы только при необходимости расширения функциональности
- Блок поддерживает полиморфное использование через указатели на базовый тип
- Для сложных систем рекомендуется использовать паттерны "Фабрика" и "Менеджер" для управления множественными механизмами
- Обязательно документируйте специфическое поведение в производных классах
- Используйте принципы SOLID при проектировании иерархии механизмов
- Тестируйте совместимость производных классов с базовым интерфейсом
