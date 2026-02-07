------------------------------------------------
-- Author: 
-- Date: 2019-08-07
-- File: UIOccupationDescPanel.lua
-- Module: UIOccupationDescPanel
-- Description: Select the role career description information
------------------------------------------------
-- Quote

local UIOccupationDescPanel = {
    Trs = nil, -- node
    Go = nil, -- node
    LogoSprite = nil, -- icon
    AttrProgressBarList = nil, -- Properties bar
    AttrThumbVfxList = nil, -- VFX of the Properties Bar
    AttrThumbVfxGoList = nil, -- VFX of the Properties Bar
    AttPicBg = nil,
    AttPic = nil,
    AttrItem= nil,
    -- NameSprite = nil, --name
    -- AttrScript = nil, --Attribute
    IntroductionLabal = nil,
    SpecialLabel = nil,
    SelectOccInfo = nil, -- Current selected occupation attribute information
    SelectOcc = 0,
    OccArray = {
        {
            Attrs = {0.5,0.6,0.7,0.3},
        },
        {
            Attrs ={0.8,0.6,0.4,0.7},                   
        },
        {
            Attrs ={0.6,0.2,0.9,0.6},                   
        },
        {
            Attrs ={0.7,0.8,0.4,0.3},                   
        }
    }
}
UIOccupationDescPanel.__index = UIOccupationDescPanel

function UIOccupationDescPanel:New(trs)
    local _M = Utils.DeepCopy(self)
    _M.Trs = trs
    _M.Go = trs.gameObject
    _M:Init()
    return _M
end

-- Get Components
function UIOccupationDescPanel:FindAllComponents()
    self.LogoSprite = UIUtils.FindSpr(self.Trs,"Logo")
    self.AttPicBg = UIUtils.FindSpr(self.Trs,"Attrs/spAttBg")
    self.AttPicBg.gameObject:SetActive(false)
    self.AttPic = UIUtils.FindSpr(self.Trs,"Attrs/spAttBg/spAtt")
    self.AttrProgressBarList = List:New();
    self.AttrItem = List:New();
    self.AttrThumbVfxGoList = List:New();
    self.AttrThumbVfxList = List:New();
    local _tmpTrans = nil;
    local _vfx = nil;
    
    for i = 1,4 do
        local Item = UIUtils.FindTrans(self.Trs,string.format( "Attrs/Item_0%d",i));
        self.AttrItem:Add(Item.gameObject);
        --if(self.AttrItem) then 
           Item.gameObject:SetActive(true)
        --end
        self.AttrProgressBarList:Add(UIUtils.FindProgressBar(self.Trs,string.format( "Attrs/Item_0%d/ProgressBar",i)));
        _tmpTrans = UIUtils.FindTrans(self.Trs,string.format( "Attrs/Item_0%d/ProgressBar/Thumb/Vfx/Node",i));
        self.AttrThumbVfxGoList:Add(_tmpTrans.gameObject);
        _vfx = UIUtils.RequireUIVfxSkinCompoent(_tmpTrans);
        self.AttrThumbVfxList:Add(_vfx);
    end       
    self.IntroductionLabal = UIUtils.FindLabel(self.Trs,"Title/Text")
end

-- Set up career
function UIOccupationDescPanel:SetOccupation( csocc,  changeNum)    
    if  #self.OccArray > csocc and 0 <= csocc then
        self.SelectOcc = csocc;
        self.SelectOccInfo = self.OccArray[csocc + 1];
        self.LogoSprite.spriteName = string.format("n_w_chuangjue_%s",csocc);
        UIUtils.SetTextByStringDefinesID(self.IntroductionLabal, DataConfig.DataPlayerOccupation[csocc]._Introduction)        
    end
end

function UIOccupationDescPanel:SetAttr(value)
    if self.SelectOccInfo then
        local _val = math.Clamp(value,0,1);
        for i = 1,4 do    
            
            self.AttrProgressBarList[i].value = self.SelectOccInfo.Attrs[i] * _val;            
            if _val >= 1 then
                if self.AttrThumbVfxGoList[i] ~= nil then                                                   
                    self.AttrThumbVfxGoList[i]:SetActive(false);
                end
            end
            --if self.SelectOccInfo.Attrs[i] < _val then
            --    self.AttrProgressBarList[i].value = self.SelectOccInfo.Attrs[i] ;
            --else
            --    self.AttrProgressBarList[i].value = _val;
            --end
        end
        self.LogoSprite.FlowValue = math.floor(_val * 10000);
    end
end

function UIOccupationDescPanel:ShowAttrPic()
    self.AttPic.spriteName = string.format("zheyebg_%s",self.SelectOcc+1)
end


function UIOccupationDescPanel:OnOpen()    
    for i = 1,4 do         
        self.AttrThumbVfxGoList[i]:SetActive(true);        
    end
    self.Go:SetActive(true)
    for i = 1,4 do                
        self.AttrThumbVfxList[i]:OnCreateAndPlay(ModelTypeCode.UIVFX,294,LayerUtils.AresUI);
    end
end

function UIOccupationDescPanel:OnClose()
    --self:OnHideBefore()
    for i = 1,4 do                
        self.AttrThumbVfxList[i]:OnDestory();
    end
    self.Go:SetActive(false)
    --self:OnHideAfter()
end


function UIOccupationDescPanel:Init()
    self:FindAllComponents()
end

return UIOccupationDescPanel