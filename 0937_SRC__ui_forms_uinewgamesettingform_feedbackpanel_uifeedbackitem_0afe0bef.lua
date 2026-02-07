------------------------------------------------
--==============================--
-- author:
-- Date: 2019-05-13
-- File: UIFeedBackItem.lua
-- Module: UIFeedBackItem
-- Description: Display of feedback information Item
--==============================--

local UIFeedBackItem = {
    -- The owner object of the current Item
    Owner = nil,
    -- GameObject associated with the current Item
    GO = nil,
    -- Transform associated with the current Item
    Trans = nil,
    -- The current Item uses a data object.
    Data = nil,

    -- Information about GM on the left Go
    LeftGo = nil,
    -- My message on the right Go
    RightGo = nil,
    -- Time Go
    TimeGo = nil,
    -- GM information on the left Label
    LeftLabel = nil,
    -- Background of GM information on the left
    LeftBackSprite = nil,    
    -- My message on the right
    RightLabel = nil,
    -- My information background on the right
    RightBackSprite = nil,
    -- time
    TimeLabel = nil,
}

-- New function
function UIFeedBackItem:New(owner,trans)
    local _m = Utils.DeepCopy(self);
    _m.Owner = owner;
    _m.GO = trans.gameObject;
    _m.Trans = trans;
    _m:FindAllComponent();
    return _m;
end

function UIFeedBackItem:FindAllComponent()
    local _myTrans = self.Trans;
    self.LeftGo = UIUtils.FindGo(_myTrans,"Left");
    self.RightGo = UIUtils.FindGo(_myTrans,"Right");
    self.TimeGo = UIUtils.FindGo(_myTrans,"Time");
    self.LeftLabel = UIUtils.FindLabel(_myTrans,"Left/Container/Text");
    self.LeftBackSprite = UIUtils.FindSpr(_myTrans,"Left/Container/Back");
    self.RightLabel = UIUtils.FindLabel(_myTrans,"Right/Container/Text");
    self.RightBackSprite = UIUtils.FindSpr(_myTrans,"Right/Container/Back");
    self.TimeLabel = UIUtils.FindLabel(_myTrans,"Time/Text");
end

-- Clone an object
function UIFeedBackItem:Clone()
    local _go = GameObject.Instantiate(self.GO);
    local _trans = _go.transform;
    _trans.parent = self.Trans.parent;
    UnityUtils.ResetTransform(_trans);
    return UIFeedBackItem:New(self.Owner, _trans);
end

-- Setting up Active
function UIFeedBackItem:SetActive(active)
    self.GO:SetActive(active);
end

-- Setting up data or configuration files
function UIFeedBackItem:SetData(dat)
    self.Data = dat;
    
end
-- Innovative data
function UIFeedBackItem:RefreshData()
    if(self.Data ~= nil) then
       if self.Data.Sender == 0 then           
            self.LeftGo:SetActive(false);
            self.RightGo:SetActive(false);
            self.TimeGo:SetActive(true);
            UIUtils.SetTextByString(self.TimeLabel, self.Data.Content)
       else
            if self.Data.Sender == 1 then
                self.LeftGo:SetActive(true);
                self.RightGo:SetActive(false);
                self.TimeGo:SetActive(false);
                UIUtils.SetTextByString(self.LeftLabel, self.Data.Content)
            else
                self.LeftGo:SetActive(false);
                self.RightGo:SetActive(true);
                self.TimeGo:SetActive(false);
                UIUtils.SetTextByString(self.RightLabel, self.Data.Content)
            end
       end  
    else
        Debug.LogError("UIServerPairItem: The current data is null");
    end
end
-- Set a name
function UIFeedBackItem:SetName(name)
    self.GO.name = name; 
end
return UIFeedBackItem;