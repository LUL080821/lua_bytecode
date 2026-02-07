------------------------------------------------
-- Author: 
-- Date: 2020-02-29
-- File: UIGuildItem.lua
-- Module: UIGuildItem
-- Description: Item of the gang flag
------------------------------------------------

local UIGuildBannerItem ={
    Trans = nil,
    Go = nil,   

    -- background
    BgSprite = nil,
    -- decorate
    FlagSprite = nil,
}

function UIGuildBannerItem:New(trans, cSharpForm)
    local _M = Utils.DeepCopy(self)
    _M.Trans = trans
    _M.Go = trans.gameObject
    _M.CSForm = cSharpForm
    _M:OnFirstShow();   
    return _M
end

-- The first display function is provided to the CS side to call.
function UIGuildBannerItem:OnFirstShow()	
	self:FindAllComponents();	
end

-- Find all components
function UIGuildBannerItem:FindAllComponents()
    local _myTrans = self.Trans;
    self.BgSprite = UIUtils.FindTex(_myTrans,"Bg");
    self.FlagSprite = UIUtils.FindSpr(_myTrans,"Flag");
end

-- Callback function that binds UI components
function UIGuildBannerItem:SetIcon(icon, isSetBack)
    local _icon = icon;
    --the code is copy from GuildInfoPanel.lua
    if _icon ~= nil then
        local _num = math.modf(_icon % 100 / 10)
        if _num == 0 then
            _num = 1
        end
        if _num == 1 then
            self.FlagSprite.spriteName = "n_d_121";
        else
            self.FlagSprite.spriteName = UIUtils.CSFormat("n_d_121_{0}", _num - 1);
        end
        self:SetSprColor(_icon % 10, self.FlagSprite)
        _num = math.modf(_icon / 1000)
        if _num == 0 then
            _num = 1
        end
        -- self.BgSprite.spriteName =;
        -- _num = math.modf(_icon % 1000 / 100)
        -- if _num == 0 then
        --     _num = 1
        -- end
        -- self:SetBackSprColor(_num, self.BgSprite)
        if isSetBack then
            self.CSForm:LoadTexture(self.BgSprite, AssetUtils.GetImageAssetPath(ImageTypeCode.UI,  UIUtils.CSFormat("tex_n_d_98_{0}", _num + 1)))
        end
        self.BgSprite.gameObject:SetActive(true)
    else
        --self.BgSprite.spriteName = "";
        self.BgSprite.gameObject:SetActive(false)
		self.FlagSprite.spriteName = "";	
    end
end

-- Set the color of the flag --the code is copy from GuildInfoPanel.lua
function UIGuildBannerItem:SetBackSprColor(color, sprite)
    if (color == 1) then
        UIUtils.SetColorByString(sprite, "#C6493B")
    elseif (color == 2) then
        UIUtils.SetColorByString(sprite, "#E88129")
    elseif (color == 3) then
        UIUtils.SetColorByString(sprite, "#E7417A")
    elseif (color == 4) then
        UIUtils.SetColorByString(sprite, "#38C555")
    elseif (color == 5) then
        UIUtils.SetColorByString(sprite, "#23AAC8")
    elseif (color == 6) then
        UIUtils.SetColorByString(sprite, "#7B38F1")
    end
 end
 function UIGuildBannerItem:SetSprColor(color, sprite)
    if (color == 1) then
        UIUtils.SetColorByString(sprite, "#B63923")
    elseif (color == 2) then
        UIUtils.SetColorByString(sprite, "#EA8739")
    elseif (color == 3) then
        UIUtils.SetColorByString(sprite, "#EB5287")
    elseif (color == 4) then
        UIUtils.SetColorByString(sprite, "#54D772")
    elseif (color == 5) then
        UIUtils.SetColorByString(sprite, "#41C8E6")
    elseif (color == 6) then
        UIUtils.SetColorByString(sprite, "#8D49F6")
    end
 end

return UIGuildBannerItem