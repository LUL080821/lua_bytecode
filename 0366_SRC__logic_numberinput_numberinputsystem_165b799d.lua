------------------------------------------------
-- Author:
-- Date: 2021-02-19
-- File: NumberInputSystem.lua
-- Module: NumberInputSystem
-- Description: Digital input
------------------------------------------------
local NumberInputSystem={}

-- Open the input interface
function NumberInputSystem:OpenInput(maxValue, pos, OnInputChanged, initValue, OnInputFormClose, posType)
    local info = {};
    if not initValue then
        info.InitValue = 0
    else
        info.InitValue = initValue;
    end
    if not posType then
        info.PosType = NumInputPosType.ELEFTMID
    else
        info.PosType = posType;
    end
    info.MaxValue = maxValue;
    info.Pos = pos;
    info.OnInputFormClosed = OnInputFormClose;
    info.OnInputChanged = OnInputChanged;
    GameCenter.PushFixEvent(UIEventDefine.UI_NUMBER_INPUT_FORM_OPEN, info)

end

function NumberInputSystem:OpenInputHasInfo(maxValue, pos, OnInputChanged, initValue, OnConfirmed, OnFormShowed, OnInputFormClose, posType)
    local info = {};
    if not initValue then
        info.InitValue = 0
    else
        info.InitValue = initValue;
    end
    info.MaxValue = maxValue;
    if not posType then
        info.PosType = NumInputPosType.ELEFTMID
    else
        info.PosType = posType
    end
    info.Pos = pos;
    info.MaxValue = maxValue;
    info.OnConfirmed = OnConfirmed;
    info.OnFormShowed = OnFormShowed;
    info.OnInputFormClosed = OnInputFormClose;
    info.OnInputChanged = OnInputChanged;
    GameCenter.PushFixEvent(UIEventDefine.UI_NUMBER_INPUT_FORM_OPEN, info);
end

-- Close the input interface
function NumberInputSystem:CloseInput()
    GameCenter.PushFixEvent(UIEventDefine.UI_NUMBER_INPUT_FORM_CLOSE)
end
return NumberInputSystem