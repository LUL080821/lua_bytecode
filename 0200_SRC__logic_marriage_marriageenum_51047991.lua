
local MarriageEnum =
{
    -- Types of marriages held
    MarryTypeEnum =
    {
        -- ordinary
        Normal  = 1,
        -- Luxury
        Comfort = 2,
        -- luxury
        Deluxe  = 3,
    },

    -- Intimacy rewards status
    IntimacyStateEnum =
    {
        -- receive
        Receiving = 1,
        -- Received
        Received = 2,
        -- Not achieved
        UnReceive = 3,
    },

    -- Type classification of Xianju data
    HouseTypeEnum =
    {
        -- upgrade
        Upgrade = 1,
        -- breakthrough
        Overfulfil = 2,
        -- Preview
        Preview = 3,
    },

    -- Divorce Type
    DivorceTypeEnum =
    {
        -- Ordinary divorce
        Normal = 0,
        -- Complaint
        Appeal = 1,
        -- Forced divorce
        Force = 2,
    },

    -- Type of marriage proposal
    ProposeTypeEnum =
    {
        -- Proposal
        Propose = 1,
        -- Being proposed
        BeProposed = 2,
    },

    -- Poetry interface type
    PoetryEnum =
    {
        Waitting = 1,
        BlessResult = 2,
        BlessTopic = 3,
    },
}

return MarriageEnum