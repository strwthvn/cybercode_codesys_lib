FUNCTION_BLOCK FB_Mechanism
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR

VAR
    _power : BOOL;
END_VAR

(* Задание питания для механизма *)
METHOD SetPower
VAR_INPUT
    power : BOOL;
END_VAR

    _power := power;
END_METHOD

(* Возвращает текущее состояние питания механизма *)
METHOD GetPower : BOOL
    GetPower := _power;
END_METHOD

END_FUNCTION_BLOCK