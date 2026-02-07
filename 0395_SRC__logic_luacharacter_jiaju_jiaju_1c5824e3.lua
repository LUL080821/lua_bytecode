------------------------------------------------
-- Author:
-- Date: 2021-06-17
-- File: JiaJu.lua
-- Module: JiaJu
-- Description: Furniture role
------------------------------------------------
local L_CharBase = require "Logic.LuaCharacter.Base.CharacterBase"
local L_Vector3 = CS.UnityEngine.Vector3

local JiaJu = {
    MasterID = 0,
    Cfg = nil,
    DeleteWaitFrame = 0,
    IsMoving = nil,
    CurRow = 0,
    CurCol = 0,
    CurDir = 0,
    IsNew = true,
    MapMaxRow = 10,
    MapMaxCol = 10,
    FillCellList = List:New(),
}

function JiaJu:New(csChar, initInfo)
    local _m = Utils.DeepCopy(self)
    setmetatable(_m, {__index = L_CharBase:New()})
    _m:BindCSCharacter(csChar, initInfo.UserData.CharType)
    return _m
end

function JiaJu:OnSetupFSMBefore()
end

function JiaJu:OnSetupFSM()
end

function JiaJu:OnInitializeAfter(initInfo)
    self:OnSyncInfo(initInfo)
end

function JiaJu:OnSyncInfo(initInfo)
    self.MasterID = initInfo.UserData.MasterId
    self.Cfg = initInfo.UserData.Cfg
    self.HouseLv = initInfo.UserData.HouseLv
    self.DeleteWaitFrame = 5
    self:SetEquip(FSkinPartCode.Body, tonumber(self.Cfg.Res))
    self.CSChar.Skin:SetLayer(LayerUtils.GetTerrainLayer())
    self.IsMoving = nil
    self.IsNew = initInfo.UserData.IsNew
    self.AllFollowHeight = 0
    self.CurDir = initInfo.UserData.Dir
    self:SetHouseMapLength()
    self:SetCellData()
    self:RefreshCell(initInfo.UserData.Row, initInfo.UserData.Col, false, true, self.IsNew)
end

function JiaJu:OnUninitializeBefore()
end

function JiaJu:SetHouseMapLength()
    local _ar = DataConfig.DataSocialHouse[self.HouseLv]
    if _ar then
        self.MapMaxCol = _ar.SquareLength
        self.MapMaxRow = _ar.SquareWidth
    end
end

function JiaJu:SetCellData()
    self.PosTable = nil
    if self.Cfg.CellData0 and self.Cfg.CellData0 ~= "" then
        if self.CurDir == JiaJuDirDefine.Dir90 then
            self.PosTable = Utils.SplitNumber(self.Cfg.CellData90, "_")
        elseif self.CurDir == JiaJuDirDefine.Dir180 then
            self.PosTable = Utils.SplitNumber(self.Cfg.CellData180, "_")
        elseif self.CurDir == JiaJuDirDefine.Dir270 then
            self.PosTable = Utils.SplitNumber(self.Cfg.CellData270, "_")
        else
            self.PosTable = Utils.SplitNumber(self.Cfg.CellData0, "_")
        end
    end
end

function JiaJu:RefreshCell(col, row, isFreshBlock, isFreshMap, isNew)
    self.CurRow = row
    self.CurCol = col
    self:Refresh(isFreshBlock, isFreshMap, isNew)
end

function JiaJu:RefreshDir(dir, isFreshBlock, isFreshMap)
    self.CurDir = dir
    if self.CurDir > JiaJuDirDefine.Dir270 then
        self.CurDir = JiaJuDirDefine.Dir0
    end
    self:SetCellData()
    self:Refresh(isFreshBlock, isFreshMap)
end

function JiaJu:Refresh(isFreshBlock, isFreshMap, isNew)
    local _cellSize = self.CSChar.Scene.navigator.CellSize
    local _posX = _cellSize * self.CurCol
    local _posZ = _cellSize * self.CurRow
    if self.PosTable then
        self.CSChar:SetEulerAngle(L_Vector3(0, self.PosTable[5], 0))
        _posX = _posX + self.PosTable[3]
        _posZ = _posZ + self.PosTable[4]
    end
    if isNew ~= nil then
        self.IsNew = isNew
    end
    self:SetPos(_posX, _posZ)
    self:SetFillCellData(nil, isFreshBlock, isFreshMap)
end

function JiaJu:SetPosition(pos)
    local _cellSize = self.CSChar.Scene.navigator.CellSize
    local _col = 0
    local _row = 0
    if self.PosTable then
        _col = (pos.x - self.PosTable[3]) / _cellSize
        if _col + self.PosTable[2] > self.MapMaxCol then
            pos.x = (self.MapMaxCol - self.PosTable[2]) * _cellSize + self.PosTable[3]
        elseif _col < 0 then
            pos.x = self.PosTable[3]
        end

        _row = (pos.z - self.PosTable[4]) / _cellSize
        if _row + self.PosTable[1] > self.MapMaxRow then
            pos.z = (self.MapMaxRow - self.PosTable[1]) * _cellSize + self.PosTable[4]
        elseif _row < 0 then
            pos.z = self.PosTable[4]
        end
        self.CSChar:SetPosition(pos)
        self:SetFillCellData(pos, false, false)
    end
end

function JiaJu:PositionAligan()
    local pos = self:GetPos()
    local _cellSize = self.CSChar.Scene.navigator.CellSize
    local _posX = 0
    local _posZ = 0
    if self.PosTable then
        _posX = math.floor((pos.x - self.PosTable[3]) / _cellSize)
        _posZ = math.floor((pos.z - self.PosTable[4]) / _cellSize)
        if _posX + self.PosTable[2] > self.MapMaxCol then
            _posX = self.MapMaxCol - self.PosTable[2]
        elseif _posX < 0 then
            _posX = 0
        end
        if _posZ + self.PosTable[1] > self.MapMaxRow then
            _posZ = self.MapMaxRow - self.PosTable[1]
        elseif _posZ < 0 then
            _posZ = 0
        end
        self:RefreshCell(_posX, _posZ, true, false)
    end
end

-- Set the grid data occupied by furniture
function JiaJu:SetFillCellData(pos, isFreshBlock, isFreshMap)
    if pos == nil then
        pos = self:GetPos()
    end
    if isFreshMap == nil then
        isFreshMap = false
    end
    local _cellSize = self.CSChar.Scene.navigator.CellSize
    local _posX = 0
    local _posZ = 0
    self.FillCellList:Clear()
    if self.PosTable then
        _posX = math.floor((pos.x - self.PosTable[3]) / _cellSize)
        _posZ = math.floor((pos.z - self.PosTable[4]) / _cellSize)
        for row = 1, self.PosTable[1] do
            for col = 1, self.PosTable[2] do
                self.FillCellList:Add((_posZ + row - 1) * self.MapMaxRow + col + _posX)
            end
        end
    end
    if isFreshMap and not self.IsNew then
        GameCenter.MapLogicSystem.ActiveLogic:SetPathGridData(self.FillCellList, isFreshBlock)
    end
end

function JiaJu:Update(dt)
end

return JiaJu
