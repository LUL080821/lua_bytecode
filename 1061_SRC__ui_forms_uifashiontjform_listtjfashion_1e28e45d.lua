
------------------------------------------------
--作者： 王圣
--日期： 2020-08-24
--文件： ListTjFashion.lua
--模块： ListTjFashion
--描述： 时装图鉴 时装别表 data = {ItemId, IconId, Quality, StarNum, Name, IsActive}
------------------------------------------------

local ItemBase = CS.Thousandto.Code.Logic.ItemBase
local ListTjFashion = {
    Trans = nil,
    Go = nil,
    -- Icon = nil,
    -- IconSpr = nil,
    IconTex = nil,
    IconId = nil,
    Quality = nil,
    Btn = nil,
    Name = nil,
    StarList = List:New(),
    ItemId = 0,
    -- CUSTOM - thêm RedPoint
    Redpoint = nil,
    -- CUSTOM - thêm RedPoint
    -- CUSTOM - thêm Select
    Select = nil,
    -- CUSTOM - thêm Select
    -- CUSTOM - thêm Border
    Border = nil,
    -- CUSTOM - thêm Border
    -- CUSTOM - thêm Data
    DataName = nil,
    DataType = nil,
    DataIsActive = nil,
    DataQuality = nil,
    DataStarNum = nil,
    DataDesc = nil,
    -- CUSTOM - thêm Data
}

function ListTjFashion:New(trans)
    if trans == nil then
        return
    end
    local _m = Utils.DeepCopy(self)
    _m.Trans = trans
    _m.Go = trans.gameObject
    _m:FindAllComponents()
    return _m
end

function ListTjFashion:FindAllComponents()
    local _myTrans = self.Trans
    -- self.Icon = UIUtils.RequireUIIconBase(_myTrans:Find("Icon"))
    -- self.IconSpr = UIUtils.FindSpr(_myTrans:Find("Icon"))
    self.IconTex = UIUtils.FindTex(_myTrans, "IconTex")
    self.Quality = UIUtils.FindSpr(_myTrans, "Quality")
    self.Name = UIUtils.FindLabel(_myTrans, "Name")
    self.Btn = UIUtils.FindBtn(_myTrans, "Btn")
    -- CUSTOM - thêm RedPoint
    self.Redpoint = UIUtils.FindGo(_myTrans, "RedPoint")
    -- CUSTOM - thêm RedPoint
    -- CUSTOM - thêm Select
    self.Select = UIUtils.FindTrans(_myTrans, "Select")
    -- CUSTOM - thêm Select
    -- CUSTOM - thêm Border
    self.Border = UIUtils.FindSpr(_myTrans, "Boder")
    -- CUSTOM - thêm Border
    UIUtils.AddBtnEvent(self.Btn, self.OnClickBtn, self)
    self.StarList:Clear()
    local gridTrans = UIUtils.FindTrans(_myTrans, "Star/Grid")
    for i = 1, gridTrans.childCount do
        local go = gridTrans:GetChild(i - 1).gameObject
        self.StarList:Add(go)
    end
end

function ListTjFashion:SetCmp(data)
    if data == nil then
        return
    end
    self.ItemId = data.ItemId
    self.IconId = data.IconId
    self.DataName = data.Name
    self.DataIsActive = data.IsActive
    self.DataQuality = data.Quality
    self.DataStarNum = data.StarNum
    self.DataType = data.Type
    self.DataDesc = data.Desc

    -- self.Icon:UpdateIcon(data.IconId)
    self.Quality.spriteName = "n_fashiontj_" .. data.Quality .. "_1"
    self.Border.spriteName = "n_fashiontj_" .. data.Quality

    UIUtils.SetTextByString(self.Name, data.Name)
    for i = 1,#self.StarList do
        local star = self.StarList[i]
        local _spr = UIUtils.FindSpr(self.StarList[i].transform)
        if i <= data.StarNum then
            _spr.spriteName = "n_z_5"
        else
            _spr.spriteName = "n_z_5_1"
        end
    end
    -- self.IconSpr.IsGray = not data.IsActive
    self.Quality.IsGray = not data.IsActive
    self.Border.IsGray = not data.IsActive
    self.IconTex.IsGray = not data.IsActive

    self.Redpoint:SetActive(false)
end

function ListTjFashion:SetActive(b)
    self.Go:SetActive(b)
end

-- CUSTOM - set select
function ListTjFashion:SetSelect(b)
    self.Select.gameObject:SetActive(b)
end
-- CUSTOM - set select

-- CUSTOM - set redpoint
function ListTjFashion:SetRedPoint(b)
    self.Redpoint.gameObject:SetActive(b)
end
-- CUSTOM - set redpoint

-- CUSTOM - select item
function ListTjFashion:OnClickBtn()
    GameCenter.PushFixEvent(LogicLuaEventDefine.EID_DOGIAM_SINGLE_ACTIVE, self.ItemId)

    -- local item = ItemBase.CreateItemBase(self.ItemId)
    -- GameCenter.ItemTipsMgr:ShowTips(item, self.Trans.gameObject)
end
-- CUSTOM - select item

return ListTjFashion
