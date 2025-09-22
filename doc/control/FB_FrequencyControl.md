# Документация функционального блока FB_FrequencyControl

## Обзор

### Назначение

Функциональный блок `FB_FrequencyControl` предназначен для управления частотой выходного сигнала с возможностью плавного изменения (рампы) от текущего значения к заданной уставке. Блок обеспечивает контролируемое изменение частоты с настраиваемым шагом и ограничением максимального значения.

### Область применения

- Управление частотными преобразователями
- Плавный пуск/останов электродвигателей
- Регулирование скорости вращения механизмов
- Системы с требованием плавного изменения частоты
- Контроль производительности вентиляторов и насосов

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`irMaxFrequency`|`REAL`|100.0|Максимально допустимая частота [Гц]. Ограничивает верхний предел выходной частоты|
|`irStep`|`REAL`|1.0|Шаг изменения частоты по умолчанию [Гц/цикл]. Используется если в методе `Calculate` не задан явный шаг|

### Выходные параметры (VAR_OUTPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`qrCurrentFrequency`|`REAL`|Текущее значение выходной частоты [Гц]|
|`qxTargetReached`|`BOOL`|TRUE = целевая частота достигнута, FALSE = идет процесс изменения|

### Внутренние переменные (VAR)

|Переменная|Тип данных|Описание|
|---|---|---|
|`_rSetFrequency`|`REAL`|Целевая частота (уставка) [Гц]|
|`_rCurrentFrequency`|`REAL`|Текущая частота (внутренняя) [Гц]|
|`_xInitialized`|`BOOL`|Флаг инициализации блока|

## Принцип работы

### Логика плавного изменения частоты

Блок реализует алгоритм плавного перехода от текущей частоты к заданной уставке:

1. **Задание уставки** - через метод `SetFrequencyTarget()`
2. **Пошаговое изменение** - через метод `Calculate()` с импульсным сигналом
3. **Автоматическое ограничение** - частота не превышает `irMaxFrequency`
4. **Контроль достижения** - флаг `qxTargetReached` сигнализирует о завершении

### Управление скоростью изменения

- **Шаг изменения** определяется параметром `rStep` в методе `Calculate()`
- **Частота вызовов** определяется частотой импульсов `xPulse`
- **Скорость рампы** = шаг × частота импульсов

## Методы

### Calculate

**Описание:** Основной метод обработки, выполняющий плавное изменение частоты к заданной уставке.

**Прототип:**

```pascal
METHOD Calculate
VAR_INPUT
    rStep : REAL;                // Шаг изменения частоты [Гц/импульс]
    xPulse : BOOL;               // Импульсный сигнал для выполнения шага
    xConditionToProceed : BOOL;  // Разрешение на выполнение
END_VAR
```

### SetFrequencyTarget

**Описание:** Задает целевую частоту для плавного перехода.

**Прототип:**

```pascal
METHOD SetFrequencyTarget
VAR_INPUT
    rFrequency : REAL;  // Целевая частота [Гц]
END_VAR
```

### SetFrequencyDirect

**Описание:** Мгновенно устанавливает выходную частоту без плавного перехода.

**Прототип:**

```pascal
METHOD SetFrequencyDirect
VAR_INPUT
    rFrequency : REAL;  // Частота [Гц]
END_VAR
```

### GetCurrentFrequency

**Описание:** Возвращает текущее значение частоты.

**Прототип:**

```pascal
METHOD GetCurrentFrequency : REAL
```

### GetTargetFrequency

**Описание:** Возвращает значение целевой частоты (уставки).

**Прототип:**

```pascal
METHOD GetTargetFrequency : REAL
```

### Reset

**Описание:** Полный сброс функционального блока в начальное состояние.

**Прототип:**

```pascal
METHOD Reset
```

### Hold

**Описание:** Останавливает изменение частоты на текущем значении.

**Прототип:**

```pascal
METHOD Hold
```

## Типовые сценарии использования

### Пример 1: Управление вентилятором с плавным пуском

```pascal
PROGRAM PRG_FanFrequencyControl
VAR
    fbFreqControl : FB_FrequencyControl;     // Контроллер частоты
    
    // Команды управления
    xStartFan : BOOL;                        // Команда запуска вентилятора
    xStopFan : BOOL;                         // Команда остановки вентилятора
    rDesiredSpeed : REAL := 75.0;            // Желаемая скорость [Гц]
    
    // Таймеры для управления рампой
    tonCyclePulse : TON;                     // Генератор импульсов для расчета
    tpPulse : TP;                            // Формирователь коротких импульсов
    
    // Параметры управления
    rMaxFanFrequency : REAL := 50.0;         // Максимальная частота вентилятора
    rFrequencyStep : REAL := 0.5;            // Шаг изменения частоты
    tCycleTime : TIME := T#100MS;            // Период обновления частоты
    
    // Состояние системы
    xFanRunning : BOOL;                      // Вентилятор работает
    xSpeedStable : BOOL;                     // Скорость стабилизировалась
    rCurrentFrequency : REAL;                // Текущая частота для ЧП
    
    // Блокировки
    xSystemReady : BOOL := TRUE;             // Система готова к работе
    xTemperatureOK : BOOL := TRUE;           // Температура в норме
END_VAR

// Настройка параметров блока
fbFreqControl(
    irMaxFrequency := rMaxFanFrequency,
    irStep := rFrequencyStep
);

// Генерация импульсов для обновления частоты
tonCyclePulse(IN := TRUE, PT := tCycleTime);
tpPulse(IN := tonCyclePulse.Q, PT := T#10MS);

IF tonCyclePulse.Q THEN
    tonCyclePulse(IN := FALSE);
END_IF

// Логика управления вентилятором
IF xStartFan AND NOT xStopFan THEN
    // Запуск вентилятора - задаем целевую частоту
    fbFreqControl.SetFrequencyTarget(rDesiredSpeed);
    xFanRunning := TRUE;
ELSIF xStopFan OR NOT xStartFan THEN
    // Остановка вентилятора - плавно снижаем до нуля
    fbFreqControl.SetFrequencyTarget(0.0);
    IF fbFreqControl.GetCurrentFrequency() <= 0.1 THEN
        xFanRunning := FALSE;
    END_IF
END_IF

// Расчет текущей частоты
fbFreqControl.Calculate(
    rStep := rFrequencyStep,
    xPulse := tpPulse.Q,
    xConditionToProceed := xSystemReady AND xTemperatureOK
);

// Получение результатов
rCurrentFrequency := fbFreqControl.qrCurrentFrequency;
xSpeedStable := fbFreqControl.qxTargetReached;

// Аварийная остановка
IF NOT xTemperatureOK THEN
    fbFreqControl.SetFrequencyDirect(0.0);  // Немедленная остановка
    xFanRunning := FALSE;
    AddAlarmMessage('Fan emergency stop - temperature fault');
END_IF

// Информационные сообщения
IF xStartFan AND xSpeedStable AND xFanRunning THEN
    AddInfoMessage(CONCAT('Fan running at ', REAL_TO_STRING(rCurrentFrequency), ' Hz'));
END_IF
```

### Пример 2: Управление конвейером с изменяемой скоростью

```pascal
PROGRAM PRG_ConveyorSpeedControl
VAR
    fbConveyorFreq : FB_FrequencyControl;    // Контроллер частоты конвейера
    
    // Команды управления
    xConveyorEnable : BOOL;                  // Разрешение работы конвейера
    eSpeedMode : E_ConveyorSpeed;            // Режим скорости
    rManualSpeed : REAL;                     // Ручная уставка скорости
    
    // Автоматическое управление скоростью
    nProductCount : INT;                     // Количество продуктов на конвейере
    xDownstreamBlocked : BOOL;               // Следующий участок заблокирован
    xUpstreamFull : BOOL;                    // Предыдущий участок полон
    
    // Параметры скорости
    rSlowSpeed : REAL := 15.0;               // Медленная скорость [Гц]
    rNormalSpeed : REAL := 30.0;             // Нормальная скорость [Гц]
    rFastSpeed : REAL := 45.0;               // Быстрая скорость [Гц]
    rMaxConveyorFreq : REAL := 50.0;         // Максимальная частота
    
    // Таймер для обновления
    tonSpeedUpdate : TON;
    tpUpdatePulse : TP;
    
    // Расчетные параметры
    rTargetSpeed : REAL;                     // Целевая скорость
    rCurrentSpeed : REAL;                    // Текущая скорость
    xSpeedAdjusting : BOOL;                  // Идет изменение скорости
    
    // Условия работы
    xSafeToRun : BOOL;                       // Безопасно работать
    xProductionActive : BOOL;                // Производство активно
END_VAR

TYPE E_ConveyorSpeed : (
    STOP := 0,
    SLOW := 1,
    NORMAL := 2,
    FAST := 3,
    MANUAL := 4,
    AUTO := 5
);
END_TYPE

// Настройка блока управления частотой
fbConveyorFreq(
    irMaxFrequency := rMaxConveyorFreq,
    irStep := 1.0  // Шаг 1 Гц за импульс
);

// Генерация импульсов обновления (каждые 200 мс)
tonSpeedUpdate(IN := TRUE, PT := T#200MS);
tpUpdatePulse(IN := tonSpeedUpdate.Q, PT := T#20MS);

IF tonSpeedUpdate.Q THEN
    tonSpeedUpdate(IN := FALSE);
END_IF

// Определение целевой скорости в зависимости от режима
CASE eSpeedMode OF
    E_ConveyorSpeed.STOP:
        rTargetSpeed := 0.0;
        
    E_ConveyorSpeed.SLOW:
        rTargetSpeed := rSlowSpeed;
        
    E_ConveyorSpeed.NORMAL:
        rTargetSpeed := rNormalSpeed;
        
    E_ConveyorSpeed.FAST:
        rTargetSpeed := rFastSpeed;
        
    E_ConveyorSpeed.MANUAL:
        rTargetSpeed := rManualSpeed;
        
    E_ConveyorSpeed.AUTO:
        // Автоматический режим - скорость зависит от загрузки
        IF xDownstreamBlocked THEN
            rTargetSpeed := rSlowSpeed;  // Медленно если впереди затор
        ELSIF nProductCount > 10 THEN
            rTargetSpeed := rFastSpeed;  // Быстро если много продуктов
        ELSIF nProductCount > 5 THEN
            rTargetSpeed := rNormalSpeed;  // Нормально при средней загрузке
        ELSE
            rTargetSpeed := rSlowSpeed;  // Медленно при малой загрузке
        END_IF
END_CASE

// Проверка условий безопасности
xSafeToRun := xConveyorEnable AND 
              NOT xUpstreamFull AND 
              xProductionActive;

// Установка целевой скорости
IF xSafeToRun THEN
    fbConveyorFreq.SetFrequencyTarget(rTargetSpeed);
ELSE
    fbConveyorFreq.SetFrequencyTarget(0.0);  // Остановка при небезопасных условиях
END_IF

// Расчет текущей частоты
fbConveyorFreq.Calculate(
    rStep := 1.0,
    xPulse := tpUpdatePulse.Q,
    xConditionToProceed := TRUE  // Всегда разрешено изменение
);

// Получение результатов
rCurrentSpeed := fbConveyorFreq.qrCurrentFrequency;
xSpeedAdjusting := NOT fbConveyorFreq.qxTargetReached;

// Экстренная остановка
IF NOT xConveyorEnable THEN
    fbConveyorFreq.Reset();  // Сброс в ноль
    AddWarningMessage('Conveyor emergency stop activated');
END_IF

// Удержание текущей скорости при блокировках
IF xUpstreamFull AND rCurrentSpeed > 0 THEN
    fbConveyorFreq.Hold();  // Заморозить текущую скорость
    AddInfoMessage('Conveyor speed held - upstream full');
END_IF

// Диагностические сообщения
IF xSpeedAdjusting THEN
    AddInfoMessage(CONCAT('Conveyor speed changing to ', REAL_TO_STRING(rTargetSpeed), ' Hz'));
END_IF

// Информация о текущем режиме
CASE eSpeedMode OF
    E_ConveyorSpeed.AUTO:
        AddInfoMessage(CONCAT('AUTO mode: Speed ', REAL_TO_STRING(rCurrentSpeed), ' Hz, Products: ', INT_TO_STRING(nProductCount)));
END_CASE
```

## Преимущества использования

### Плавность управления

- **Исключение рывков** - плавное изменение частоты предотвращает механические удары
- **Контролируемое ускорение** - настраиваемая скорость изменения частоты
- **Защита оборудования** - мягкий пуск и останов продлевают срок службы

### Гибкость настройки

- **Настраиваемые параметры** - максимальная частота и шаг изменения
- **Различные режимы** - плавный переход или мгновенная установка
- **Условное управление** - возможность блокировки изменений

### Простота интеграции

- **Стандартный интерфейс** - единообразное управление для разных применений
- **Обратная связь** - информация о состоянии процесса изменения
- **Диагностика** - контроль достижения целевых значений

## Рекомендации по применению

### Когда использовать FB_FrequencyControl

- ✅ Частотные преобразователи требующие плавного управления
- ✅ Системы с механическими ограничениями на скорость изменения
- ✅ Процессы где важна стабильность переходных режимов
- ✅ Автоматизированные системы с переменной производительностью
- ✅ Оборудование требующее защиты от резких изменений нагрузки

### Когда НЕ использовать FB_FrequencyControl

- ❌ Системы реального времени с критичными временными ограничениями
- ❌ Простые on/off устройства без регулирования скорости
- ❌ Применения где требуется мгновенная реакция на команды
- ❌ Системы с аналоговым управлением частотой

## Примечания

- Блок обеспечивает защиту оборудования через плавное изменение параметров
- Частота обновления определяется частотой импульсов `xPulse`
- Рекомендуется использовать с таймерами для стабильной работы
- Поддерживает как автоматические, так и ручные режимы управления
- Идеально подходит для интеграции с частотными преобразователями
- Обеспечивает предсказуемое поведение системы при изменении нагрузки
- Упрощает создание сложных алгоритмов управления производительностью