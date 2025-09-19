# Документация функционального блока FB_BasicAnalogSignal

## Обзор

### Назначение

Функциональный блок `FB_BasicAnalogSignal` является абстрактным базовым классом для обработки аналоговых сигналов. Блок определяет общую структуру и интерфейс для работы с аналоговыми значениями, включая валидацию диапазонов, обработку исходных значений и предоставление методов доступа к обработанным данным.

### Область применения

- Базовый класс для специализированных блоков обработки аналоговых сигналов
- Унификация интерфейса работы с различными типами аналоговых датчиков
- Стандартизация валидации и обработки аналоговых данных
- Основа для создания масштабируемых решений обработки сигналов

**Важно:** Данный блок является абстрактным и не может использоваться напрямую. Необходимо создавать производные классы, реализующие абстрактный метод `ProcessRawValue()`.

## Интерфейс функционального блока

### Входные параметры (VAR_INPUT)

|Параметр|Тип данных|Описание|
|---|---|---|
|`irRawValue`|`REAL`|Исходное значение аналогового сигнала|

### Внутренние переменные (VAR)

|Переменная|Тип данных|По умолчанию|Описание|
|---|---|---|---|
|`_rProcessedValue`|`REAL`|-|Обработанное значение сигнала|
|`_rMinValue`|`REAL`|0.0|Минимальное допустимое значение|
|`_rMaxValue`|`REAL`|100.0|Максимальное допустимое значение|
|`_xOutOfRange`|`BOOL`|FALSE|Флаг выхода за пределы диапазона|

## Принцип работы

1. **Обработка входного сигнала**: Вызывается абстрактный метод `ProcessRawValue()`, который должен быть реализован в производных классах
2. **Валидация диапазона**: Автоматическая проверка обработанного значения на соответствие заданному диапазону
3. **Установка флагов**: Обновление флага выхода за пределы диапазона

## Публичные методы

### GetRawValue

**Описание:** Возвращает исходное (необработанное) значение аналогового сигнала.

**Прототип:**

```pascal
METHOD GetRawValue : REAL
```

**Возвращаемое значение:** Исходное значение `irRawValue`

---

### GetProcessedValue

**Описание:** Возвращает обработанное значение сигнала.

**Прототип:**

```pascal
METHOD GetProcessedValue : REAL
```

**Возвращаемое значение:** Обработанное значение после применения алгоритмов производного класса

---

### IsOutOfRange

**Описание:** Проверяет, находится ли обработанное значение за пределами допустимого диапазона.

**Прототип:**

```pascal
METHOD IsOutOfRange : BOOL
```

**Возвращаемое значение:**
- TRUE = значение вне допустимого диапазона
- FALSE = значение в пределах диапазона

---

### GetMinValue

**Описание:** Возвращает минимальное значение допустимого диапазона.

**Прототип:**

```pascal
METHOD GetMinValue : REAL
```

**Возвращаемое значение:** Минимальное допустимое значение

---

### GetMaxValue

**Описание:** Возвращает максимальное значение допустимого диапазона.

**Prototип:**

```pascal
METHOD GetMaxValue : REAL
```

**Возвращаемое значение:** Максимальное допустимое значение

---

### SetRange

**Описание:** Устанавливает диапазон допустимых значений.

**Прототип:**

```pascal
METHOD SetRange
VAR_INPUT
    rMinValue : REAL;   // Минимальное значение
    rMaxValue : REAL;   // Максимальное значение
END_VAR
```

**Параметры:**
- `rMinValue` - нижняя граница диапазона
- `rMaxValue` - верхняя граница диапазона

**Примечание:** Диапазон устанавливается только если `rMinValue < rMaxValue`

---

### IsInRange

**Описание:** Проверяет принадлежность заданного значения к допустимому диапазону.

**Прототип:**

```pascal
METHOD IsInRange : BOOL
VAR_INPUT
    rValue : REAL;  // Проверяемое значение
END_VAR
```

**Возвращаемое значение:**
- TRUE = значение в пределах диапазона
- FALSE = значение вне диапазона

---

### ClampToRange

**Описание:** Ограничивает значение в пределах допустимого диапазона.

**Прототип:**

```pascal
METHOD ClampToRange : REAL
VAR_INPUT
    rValue : REAL;  // Входное значение
END_VAR
```

**Возвращаемое значение:** 
- Если значение < минимума → возвращает минимум
- Если значение > максимума → возвращает максимум  
- Иначе → возвращает исходное значение

---

### Reset

**Описание:** Сбрасывает состояние функционального блока.

**Прототип:**

```pascal
METHOD Reset
```

**Функциональность:**
- Устанавливает обработанное значение = 0.0
- Сбрасывает флаг выхода за пределы диапазона

## Абстрактные методы

### ProcessRawValue

**Описание:** Абстрактный метод обработки исходного значения. Должен быть переопределен в каждом производном классе.

**Прототип:**

```pascal
METHOD ABSTRACT ProcessRawValue
```

**Назначение:** Реализует специфичную логику обработки сигнала для конкретного типа датчика или применения.

## Защищенные методы

### ValidateRange

**Описание:** Проверяет диапазон обработанного значения и обновляет флаг выхода за пределы.

**Прототип:**

```pascal
METHOD PROTECTED ValidateRange
```

**Использование:** Автоматически вызывается в основном цикле блока

---

### SetProcessedValue

**Описание:** Устанавливает обработанное значение сигнала.

**Прототип:**

```pascal
METHOD PROTECTED SetProcessedValue
VAR_INPUT
    rValue : REAL;  // Обработанное значение
END_VAR
```

**Использование:** Используется в производных классах для установки результата обработки

## Создание производных классов

### Пример простого производного класса

```pascal
FUNCTION_BLOCK FB_SimpleAnalogSignal EXTENDS FB_BasicAnalogSignal
VAR_INPUT
    rGain : REAL := 1.0;        // Коэффициент усиления
    rOffset : REAL := 0.0;      // Смещение
END_VAR

// Реализация абстрактного метода
METHOD ProcessRawValue
VAR_INPUT
END_VAR
VAR
    rScaledValue : REAL;
END_VAR
    // Простое масштабирование: Y = Gain * X + Offset
    rScaledValue := GetRawValue() * rGain + rOffset;
    SetProcessedValue(rScaledValue);
END_METHOD

END_FUNCTION_BLOCK
```

### Пример использования производного класса

```pascal
PROGRAM PRG_Main
VAR
    fbAnalogSignal : FB_SimpleAnalogSignal;
    rSensorInput : REAL;        // Вход от датчика
    rProcessValue : REAL;       // Обработанное значение
    xValueValid : BOOL;         // Валидность значения
END_VAR

// Настройка диапазона и параметров
fbAnalogSignal.SetRange(0.0, 200.0);

// Обработка сигнала
fbAnalogSignal(
    irRawValue := rSensorInput,
    rGain := 2.0,
    rOffset := 10.0
);

// Получение результатов
rProcessValue := fbAnalogSignal.GetProcessedValue();
xValueValid := NOT fbAnalogSignal.IsOutOfRange();

// Использование вспомогательных методов
IF NOT xValueValid THEN
    // Ограничение значения в допустимых пределах
    rProcessValue := fbAnalogSignal.ClampToRange(rProcessValue);
END_IF
```

## Расширенные примеры производных классов

### Блок с фильтрацией

```pascal
FUNCTION_BLOCK FB_FilteredAnalogSignal EXTENDS FB_BasicAnalogSignal
VAR_INPUT
    rFilterConstant : REAL := 0.1;  // Константа фильтра (0..1)
END_VAR
VAR
    _rFilteredValue : REAL := 0.0;  // Отфильтрованное значение
    _xFirstRun : BOOL := TRUE;      // Флаг первого запуска
END_VAR

METHOD ProcessRawValue
VAR_INPUT
END_VAR
    // Инициализация при первом запуске
    IF _xFirstRun THEN
        _rFilteredValue := GetRawValue();
        _xFirstRun := FALSE;
    ELSE
        // Экспоненциальный фильтр
        _rFilteredValue := _rFilteredValue * (1.0 - rFilterConstant) + 
                          GetRawValue() * rFilterConstant;
    END_IF
    
    SetProcessedValue(_rFilteredValue);
END_METHOD

END_FUNCTION_BLOCK
```

### Блок с калибровкой

```pascal
FUNCTION_BLOCK FB_CalibratedAnalogSignal EXTENDS FB_BasicAnalogSignal
VAR_INPUT
    rZeroPoint : REAL := 0.0;       // Точка нуля
    rSpanPoint : REAL := 100.0;     // Точка диапазона
    rZeroRaw : REAL := 0.0;         // Сырое значение в точке нуля
    rSpanRaw : REAL := 100.0;       // Сырое значение в точке диапазона
END_VAR

METHOD ProcessRawValue
VAR_INPUT
END_VAR
VAR
    rGain : REAL;
    rOffset : REAL;
    rCalibratedValue : REAL;
END_VAR
    // Расчет коэффициентов калибровки
    IF (rSpanRaw - rZeroRaw) <> 0 THEN
        rGain := (rSpanPoint - rZeroPoint) / (rSpanRaw - rZeroRaw);
        rOffset := rZeroPoint - rGain * rZeroRaw;
        
        // Применение калибровки
        rCalibratedValue := GetRawValue() * rGain + rOffset;
    ELSE
        rCalibratedValue := rZeroPoint; // Защита от деления на ноль
    END_IF
    
    SetProcessedValue(rCalibratedValue);
END_METHOD

END_FUNCTION_BLOCK
```

## Диагностические возможности

### Мониторинг состояния

```pascal
// Пример комплексной диагностики
VAR
    fbAnalogDiag : FB_BasicAnalogSignal;
    stDiagnostics : ST_AnalogDiagnostics;
END_VAR

TYPE ST_AnalogDiagnostics :
STRUCT
    rRawValue : REAL;           // Исходное значение
    rProcessedValue : REAL;     // Обработанное значение
    xOutOfRange : BOOL;         // Выход за диапазон
    rRangeMin : REAL;           // Минимум диапазона
    rRangeMax : REAL;           // Максимум диапазона
    rRangeUtilization : REAL;   // Использование диапазона (%)
END_STRUCT
END_TYPE

// Сбор диагностической информации
stDiagnostics.rRawValue := fbAnalogDiag.GetRawValue();
stDiagnostics.rProcessedValue := fbAnalogDiag.GetProcessedValue();
stDiagnostics.xOutOfRange := fbAnalogDiag.IsOutOfRange();
stDiagnostics.rRangeMin := fbAnalogDiag.GetMinValue();
stDiagnostics.rRangeMax := fbAnalogDiag.GetMaxValue();

// Расчет использования диапазона
IF (stDiagnostics.rRangeMax - stDiagnostics.rRangeMin) <> 0 THEN
    stDiagnostics.rRangeUtilization := 
        (stDiagnostics.rProcessedValue - stDiagnostics.rRangeMin) / 
        (stDiagnostics.rRangeMax - stDiagnostics.rRangeMin) * 100.0;
END_IF
```

## Рекомендации по проектированию

### Архитектурные принципы

1. **Единственная ответственность**: Каждый производный класс должен решать одну конкретную задачу обработки
2. **Открытость для расширения**: Используйте наследование для добавления новой функциональности
3. **Инкапсуляция**: Скрывайте детали реализации за публичным интерфейсом

### Именование производных классов

```pascal
FB_AnalogSignal4_20mA       // Токовая петля 4-20 мА
FB_AnalogSignalPt100        // Температурный датчик Pt100
FB_AnalogSignalPressure     // Датчик давления
FB_AnalogSignalFiltered     // С фильтрацией
FB_AnalogSignalCalibrated   // С калибровкой
```

### Обработка ошибок

```pascal
// Рекомендуемый подход к обработке ошибок в ProcessRawValue
METHOD ProcessRawValue
VAR_INPUT
END_VAR
VAR
    rProcessedValue : REAL;
END_VAR
    // Валидация входного значения
    IF GetRawValue() < 0 OR GetRawValue() > 1000 THEN
        // Установка безопасного значения при ошибке
        rProcessedValue := GetMinValue();
    ELSE
        // Нормальная обработка
        rProcessedValue := GetRawValue() * 2.0;
    END_IF
    
    SetProcessedValue(rProcessedValue);
END_METHOD
```

## Примечания

- Блок является абстрактным и требует реализации метода `ProcessRawValue()` в производных классах
- Автоматическая валидация диапазона выполняется после обработки значения
- Защищенные методы предназначены только для использования в производных классах
- Рекомендуется устанавливать диапазон значений сразу после создания экземпляра
- Для критичных применений реализуйте дополнительную валидацию в методе `ProcessRawValue()`
- Используйте метод `Reset()` для приведения блока в известное состояние при инициализации системы
