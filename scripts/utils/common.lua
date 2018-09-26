---
--- module contains reusable functions unrelated to mod
---
return function (GLOBAL, env)
    local IsServerSide
    local IsDedicatedSide
    local IsClientSide
    if GLOBAL.TheNet:GetIsServer() then
        IsServerSide = true
        if GLOBAL.TheNet:IsDedicated() then
            IsDedicatedSide = true
        else
            IsClientSide = true
        end
    elseif GLOBAL.TheNet:GetIsClient() then
        IsServerSide = false
        IsClientSide = true
    end

    local function AddPlayerPostInit(fn)
        env.AddPrefabPostInit("world", function(wrld)
            wrld:ListenForEvent("playeractivated", function(_, player)
                if player == GLOBAL.ThePlayer then
                    fn(player)
                end
            end)
        end)
    end

    return {
      IsServerSide = IsServerSide,
      IsDedicatedSide = IsDedicatedSide,
      IsClientSide = IsClientSide,
      AddPlayerPostInit = AddPlayerPostInit,
    }
end
