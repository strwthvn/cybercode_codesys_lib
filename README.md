# Нейминг переменных

### Язык и регистр

- Использовать **английский язык** для всех имен переменных
- Применять **CamelCase** для составных имен: `MotorSpeed`, `ValveOpen`
- Для констант использовать **UPPER_CASE** с подчеркиваниями: `MAX_TEMPERATURE`, `TIMEOUT_VALUE`
- Имя должно быть самодокументируемым и понятным без дополнительных комментариев

### Префиксы по области видимости
- Глобальные переменные не используют префикс.
- `_` - Локальные переменные внутри ФБ, метода, функции и другие, имеющие модификатор доступа PRIVATE, имеют префикс . Например `_xVariable`
- `q` `i` - Переменные входа и выхода ФБ: префиксы: `qxVariable`, `ixVariable`

### Базовые типы
- **x** - BOOL: `xMotorRunning`, `xAlarmActive`
- **n** - INT/SINT/DINT/LINT: `nCounter`, `nErrorCode`
- **u** - UINT/USINT/UDINT/ULINT: `uProductCount`
- **r** - REAL/LREAL: `rTemperature`, `rPressure`
- **s** - STRING: `sDeviceName`, `sErrorMessage`
- **t** - TIME/DATE/TOD/DT: `tCycleTime`, `tStartDate`
- **by** - BYTE: `byStatusByte`
- **w** - WORD: `wControlWord`
- **dw** - DWORD: `dwSerialNumber`

### Специальные типы

- **a** - ARRAY: `aDataBuffer`, `aSensorValues`
- **st** - STRUCT: `stMotorData`, `stRecipe`
- **e** - ENUM: `eOperationMode`, `eSystemState`
- **fb** - экземпляр функционального блока: `fbPumpControl`, `fbPIDController`
- **ifc** - интерфейс: `ifcDriver`, `ifcCommunication`

## 5. Именование компонентов проекта

### Проект
- CC_25_012_PLC (`CC_год_порядковый номер_тип устройства`)

### Программы (PRG)
- Префикс **PRG_**: `PRG_Main`, `PRG_AlarmHandler`, `PRG_DataLogging`

### Функциональные блоки (FB)
- Префикс **FB_**: `FB_MotorControl`, `FB_ValveActuator`, `FB_PIDController`

### Функции (FC/FUN)
- Префикс **FC_** `FC_CalculateCRC`

### Структуры данных (DUT)
- Префикс **ST_** для структур: `ST_MotorData`, `ST_RecipeParameters`
- Префикс **E_** для перечислений: `E_SystemMode`, `E_ErrorCodes`
- Префикс **U_** для объединений: `U_DataConverter`

### Методы (METHOD)
- Использовать глаголы в начале имени: `Execute()`, `Calculate()`, `Initialize()`
- Для методов проверки использовать **Is**, **Has**, **Can**: `IsReady()`, `HasError()`, `CanStart()`
- Для приватных методов добавлять префикс `_`: `_ValidateInput()`, `_ProcessData()`

### Префиксы для свойств (PROPERTY)
- **prop_** - для свойств: `prop_IsRunning`, `prop_CurrentSpeed`
- Для свойств только для чтения добавлять **Get**: `prop_GetStatus`
- Для свойств записи добавлять **Set**: `prop_SetSpeed`

## 6. Специальные соглашения

### Таймеры и счетчики
- Таймеры TON: `ton_DelayStart`, `ton_Timeout`
- Таймеры TOF: `tof_MotorStop`, `toffCooling`
- Таймеры TP: `tp_PulseGenerator`
- Счетчики CTU: `ctu_ProductCounter`
- Счетчики CTD: `ctd_BatchCounter`
### Триггеры
- R_TRIG : `rt_cmdStart`
- F_TRIG: `ft_cmdStart`
- RS: `rs_Start`
- SR: `sr_Start`
### Границы и пределы
- **MIN_** для минимальных значений: `MIN_TEMPERATURE`
- **MAX_** для максимальных значений: `MAX_PRESSURE`
- **DEFAULT_** для значений по умолчанию: `DEFAULT_TIMEOUT`
### Состояния и команды
- **cmd** для команд: `cmdStart`, `cmdStop`, `cmdReset`
- **state** для состояний:
	- `stateRun` - работа
	- `stateErr` - ошибка
	- `stateRdy` - готовность
	- `stateNRdy` - неготовность
	- `stateWrn` - предупреждение
### Названия устройств
https://alfapolus.by/archives/27909

# Принципы ООП проектирования POU

## 1. Основные принципы ООП в контексте ПЛК

### 1.1 Инкапсуляция

Каждый функциональный блок должен скрывать свою внутреннюю реализацию и предоставлять только необходимый интерфейс для взаимодействия. Внутренние переменные должны быть приватными (с префиксом `_`), а доступ к ним осуществляется через свойства (PROPERTY) или методы (METHOD).

**Правильный подход:**

```pascal
FUNCTION_BLOCK FB_Motor
VAR
    _rCurrentSpeed: REAL;      // Приватная переменная
    _xIsRunning: BOOL;         // Приватная переменная
END_VAR

PROPERTY prop_Speed : REAL
    GET: prop_Speed := _rCurrentSpeed;
    SET: _rCurrentSpeed := prop_Speed;
END_PROPERTY
```

### 1.2 Наследование

Наследование для создания специализированных версий базовых функциональных блоков. Базовый блок содержит общую функциональность, а производные блоки добавляют специфичное поведение.

**Структура наследования:**

```pascal
FB_Motor (базовый класс)
    ├── FB_MotorWithEncoder (добавляет обратную связь)
    ├── FB_MotorWithBrake (добавляет управление тормозом)
    └── FB_ServoMotor (специализированная реализация)
```

### 1.3 Полиморфизм

Полиморфизм через интерфейсы (INTERFACE). Разные функциональные блоки могут реализовывать один интерфейс, позволяя использовать их взаимозаменяемо.


## 2. Принципы SOLID в проектировании POU

### 2.1 Single Responsibility Principle (Принцип единственной ответственности)

Каждый POU должен отвечать только за одну функциональность. Не создавайте "супер-блоки", которые управляют всем процессом.

**Неправильно:**

```pascal
FB_MachineControl - управляет моторами, клапанами, считывает датчики, ведет логи, обрабатывает HMI
```

**Правильно:**

```pascal
FB_MotorControl - только управление мотором
FB_ValveControl - только управление клапаном  
FB_SensorReader - только чтение датчиков
FB_DataLogger - только логирование
FB_MachineCoordinator - координация работы компонентов
```

### 2.2 Open/Closed Principle (Принцип открытости/закрытости)

Функциональные блоки должны быть открыты для расширения, но закрыты для модификации. Используйте наследование и виртуальные методы для добавления новой функциональности без изменения существующего кода.

**Реализация:**

```pascal
FUNCTION_BLOCK FB_BaseController
METHOD PROTECTED ProcessLogic : BOOL  // Виртуальный метод
    // Базовая логика
END_METHOD

METHOD PUBLIC Execute : BOOL
    // Подготовка
    ProcessLogic();  // Вызов виртуального метода
    // Завершение
END_METHOD
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_AdvancedController EXTENDS FB_BaseController
METHOD PROTECTED ProcessLogic : BOOL  // Переопределение
    // Расширенная логика
    SUPER^.ProcessLogic();  // Вызов родительского метода если нужно
END_METHOD
END_FUNCTION_BLOCK
```

### 2.3 Liskov Substitution Principle (Принцип подстановки Барбары Лисков)

Объекты производных классов должны быть взаимозаменяемы с объектами базового класса без нарушения корректности программы. Производный блок не должен ужесточать предусловия или ослаблять постусловия.

**Правило:** Если FB_ServoMotor наследуется от FB_Motor, то везде, где используется FB_Motor, можно использовать FB_ServoMotor без изменения логики программы.

### 2.4 Interface Segregation Principle (Принцип разделения интерфейса)

Создавайте специализированные интерфейсы вместо одного универсального. Клиенты не должны зависеть от методов, которые они не используют.

**Неправильно:**

```pascal
INTERFACE I_Device
    METHOD Start
    METHOD Stop  
    METHOD Calibrate
    METHOD PrintReport
    METHOD SaveToDatabase
END_INTERFACE
```

**Правильно:**

```pascal
INTERFACE I_Controllable
    METHOD Start
    METHOD Stop
END_INTERFACE

INTERFACE I_Calibratable
    METHOD Calibrate
    METHOD ResetCalibration
END_INTERFACE

INTERFACE I_Reportable
    METHOD GenerateReport
END_INTERFACE
```

### 2.5 Dependency Inversion Principle (Принцип инверсии зависимостей)

Модули верхнего уровня не должны зависеть от модулей нижнего уровня. Оба должны зависеть от абстракций. Используйте интерфейсы для связи между компонентами.

**Реализация через интерфейсы:**

```pascal
FUNCTION_BLOCK FB_MachineController
VAR
    _ifcMotor: I_Motor;  // Зависимость от интерфейса, не от конкретной реализации
    _ifcSensor: I_Sensor;
END_VAR

METHOD Init
    VAR_INPUT
        ifcMotor: I_Motor;
        ifcSensor: I_Sensor;
    END_VAR
    _ifcMotor := ifcMotor;
    _ifcSensor := ifcSensor;
END_METHOD
```


## Контрольный чек-лист проектирования POU

- [ ]  POU выполняет только одну задачу (SRP)
- [ ]  Используются интерфейсы для абстракции
- [ ]  Приватные переменные начинаются с `_`
- [ ]  Реализована обработка ошибок
- [ ]  Есть диагностические свойства
- [ ]  Документированы все публичные методы
- [ ]  Нет циклических зависимостей
- [ ]  Используется наследование где уместно
- [ ]  Соблюдается принцип DRY (Don't Repeat Yourself)
