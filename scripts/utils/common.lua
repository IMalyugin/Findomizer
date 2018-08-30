---
--- module contains reusable functions unrelated to mod
---
return function (GLOBAL, env)
    local SERVER_SIDE = nil
    local DEDICATED_SIDE = nil
    local CLIENT_SIDE = nil
    local ONLY_CLIENT_SIDE = nil

    -- code from star:
    -- Also notice that if SERVER_SIDE is nil and CLIENT_SIDE is nil too,
    -- that means the mod is force enabled and it's working on main screen. I guess.
    if GLOBAL.TheNet:GetIsServer() then
        SERVER_SIDE = true
        if GLOBAL.TheNet:IsDedicated() then
            -- Shouldn't use GetServerIsDedicated, because it only says if host is dedicated, not current client machine
            DEDICATED_SIDE = true
        else
            CLIENT_SIDE = true --A clever "ismastersim" problem solution.
            -- Should only be used for network variable initialization, not compatible with prefab "return"
        end
    elseif GLOBAL.TheNet:GetIsClient() then
        SERVER_SIDE = false
        CLIENT_SIDE = true
        ONLY_CLIENT_SIDE = true
    end

    local function AddPlayerPostInit(fn)
        env.AddPrefabPostInit("world", function(wrld)
            wrld:ListenForEvent("playeractivated", function(wlrd, player)
                if player == GLOBAL.ThePlayer then
                    fn(player)
                end
            end)
        end)
    end

    return {
      SERVER_SIDE = SERVER_SIDE,
      DEDICATED_SIDE = DEDICATED_SIDE,
      CLIENT_SIDE = CLIENT_SIDE,
      ONLY_CLIENT_SIDE = ONLY_CLIENT_SIDE,
      AddPlayerPostInit = AddPlayerPostInit,
    }
end