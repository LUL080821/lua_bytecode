local MSG_Skill = {}
local Network = GameCenter.Network

function MSG_Skill.RegisterMsg()

    Network.CreatRespond("MSG_Skill.ResPassiveSkill",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResPassiveSkill(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResUpdateSkill",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResUpdateSkill(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResSkillOnline",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResSkillOnline(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResUpCell",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResUpCell(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResUpSkillStar",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResUpSkillStar(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResActivateMeridian",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResActivateMeridian(msg)
    end)


    Network.CreatRespond("MSG_Skill.ResResetMeridianSkillResult",function (msg)
        --TODO
    end)


    Network.CreatRespond("MSG_Skill.ResSelectMentalType",function (msg)
        --TODO
        GameCenter.PlayerSkillSystem:ResSelectMentalType(msg)
    end)

end
return MSG_Skill

