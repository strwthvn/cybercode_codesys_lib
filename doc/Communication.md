# Библиотека Communication

## Обзор

Модуль `communication` содержит вспомогательные функции и типы данных для работы с протоколами связи, преобразования данных и обмена информацией между устройствами.

## Компоненты

### Объединения (UNION)

#### U_ByteToWord
Преобразование между WORD и массивом байтов.

```pascal
TYPE U_ByteToWord :
UNION
    wTag: WORD;
    bTag: ARRAY [0..1] OF BYTE;
END_UNION
END_TYPE
```

**Применение:**
```pascal
VAR
    uConverter : U_ByteToWord;
END_VAR

uConverter.wTag := 16#1234;
// Результат: bTag[0] = 16#34, bTag[1] = 16#12
```

#### U_RealToWord
Преобразование между REAL и массивом WORD.

```pascal
TYPE U_RealToWord :
UNION
    wTag: ARRAY [0..1] OF WORD;
    rTag: REAL;
END_UNION
END_TYPE
```

**Применение:**
```pascal
VAR
    uConverter : U_RealToWord;
END_VAR

uConverter.rTag := 123.45;
// Результат: wTag[0] и wTag[1] содержат IEEE 754 представление
```

### Функции преобразования

#### FC_SwapBytesInWord
Меняет местами байты в WORD (изменение порядка байтов).

```pascal
FUNCTION FC_SwapBytesInWord : WORD
VAR_INPUT
    wInputValue : WORD;
END_VAR
```

**Применение:**
```pascal
VAR
    wResult : WORD;
END_VAR

wResult := FC_SwapBytesInWord(16#1234);
// Результат: wResult = 16#3412
```

#### FC_SwapBytesInWordArray
Меняет местами байты в каждом элементе массива WORD.

```pascal
FUNCTION FC_SwapBytesInWordArray : ARRAY [0..1] OF WORD
VAR_INPUT
    awInputArray : ARRAY [0..1] OF WORD;
END_VAR
```

**Применение:**
```pascal
VAR
    awInput : ARRAY [0..1] OF WORD := [16#1234, 16#5678];
    awResult : ARRAY [0..1] OF WORD;
END_VAR

awResult := FC_SwapBytesInWordArray(awInput);
// Результат: awResult[0] = 16#3412, awResult[1] = 16#7856
```

#### FC_SwapWordArrayElements
Меняет местами элементы массива WORD.

```pascal
FUNCTION FC_SwapWordArrayElements : ARRAY [0..1] OF WORD
VAR_INPUT
    awInputArray : ARRAY [0..1] OF WORD;
END_VAR
```

**Применение:**
```pascal
VAR
    awInput : ARRAY [0..1] OF WORD := [16#1234, 16#5678];
    awResult : ARRAY [0..1] OF WORD;
END_VAR

awResult := FC_SwapWordArrayElements(awInput);
// Результат: awResult[0] = 16#5678, awResult[1] = 16#1234
```

## Типовые сценарии применения

### Обмен данными REAL через Modbus

```pascal
VAR
    uRealConverter : U_RealToWord;
    awModbusData : ARRAY [0..1] OF WORD;
    rTemperature : REAL := 25.6;
END_VAR

// Передача REAL значения
uRealConverter.rTag := rTemperature;
awModbusData := FC_SwapWordArrayElements(uRealConverter.wTag);

// Прием REAL значения
uRealConverter.wTag := FC_SwapWordArrayElements(awModbusData);
rTemperature := uRealConverter.rTag;
```

### Обработка данных с разным порядком байтов

```pascal
VAR
    wEthernetData : WORD := 16#1234;  // Big-endian
    wPLCData : WORD;                  // Little-endian
END_VAR

// Преобразование порядка байтов
wPLCData := FC_SwapBytesInWord(wEthernetData);
```

## Примечания

- Функции предназначены для работы с протоколами связи требующими различный порядок байтов
- Объединения обеспечивают типобезопасное преобразование данных
- Особенно полезны при работе с Modbus, Ethernet/IP, Profinet
- Все функции работают без побочных эффектов