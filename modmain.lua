local _G = GLOBAL
local require = _G.require

local __commonUtils = require('utils/common')(GLOBAL, env)
local SERVER_SIDE = __commonUtils.SERVER_SIDE
local CLIENT_SIDE = __commonUtils.CLIENT_SIDE
local AddPlayerPostInit = __commonUtils.AddPlayerPostInit

local __highlight = require('utils/highlight')(GLOBAL, env)
local ApplyHighlight = __highlight.ApplyHighlight
local ClearHighlight = __highlight.ClearHighlight

local client_option = GetModConfigData("active", true) -- to allow clients to disable highlighting






-- stringify lib


local function val_to_str ( v, indent )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  elseif "table" == type( v ) then
    if indent == "        " then
		return "~TooDeep~"
	else
		return table.stringify( v, indent )
	end
  else
    return tostring( v )
  end
end

local function key_to_str ( k, indent )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. tostring( k ) .. "]"
  end
end


table.stringify = function( tbl, indent )
  indent = indent or ""
  local count = 0
  local result, done = {}, {}

  if type( tbl ) ~= 'table' then
      return val_to_str( tbl )
  end

  for k, v in ipairs( tbl ) do
    table.insert( result, val_to_str( v, indent.."  " ) )
    done[ k ] = true
	count = count + 1
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result, indent..key_to_str( k, indent ) .. "=" .. val_to_str( v, indent.."  " ) )
	  count = count + 1
    end
  end
  if count > 1 then
	return "{\n" .. table.concat( result, ",\n" ) .. "\n"..indent.."}"
  else
    return "{ " .. table.concat( result, "," ) .. " }"
  end
end


-- /stringify lib


--
--local function filter(chest, item)
--  return chest.components.container and item and
--         chest.components.container:Has(item, 1)
--end
--
---- because of server client communication delay, everything has to be done in a row, in this order:
---- unhighlight at client -> unhighlight at server (set nil) -> server highlight (:set()) -> client highlighted with OnDirtyEventSearchedChest
--
--local function ServerRPCFunction(owner,prefab,source,unhighlighten,highlighten)
--    -- print("serverfkt called")
--    if unhighlighten then
--        local v = nil
--        for i=1,50 do
--            v = owner["mynetvarSearchedChest"..tostring(i)]:value()
--            if v~=nil and not (not v:HasTag("HighlightSourceCraftPot") and source=="CraftPotClose") then
--                -- print("server unhighlight "..tostring(v).." hattag: "..tostring(v:HasTag("HighlightSourceCraftPot")).." source: "..tostring(source))
--                v:RemoveTag("HighlightSourceCraftPot")
--                owner["mynetvarSearchedChest"..tostring(i)]:set(nil) -- remove tag and set nil at serverside
--            end
--        end
--    end
--    if highlighten then
--        if owner and prefab then -- if no prefab is given, nothing will be highlighted :)
--            local x, y, z = owner.Transform:GetWorldPosition()
--            local e = TheSim:FindEntities(x, y, z, 20, nil, {'NOBLOCK', 'player', 'FX'}) or {}
--            for k, v in pairs(e) do
--                if v and v:IsValid() and v.entity:IsVisible() and filter(v,prefab) then
--                    -- print("server highlight "..tostring(v))
--                    if source=="CraftPot" then
--                        v:AddTag("HighlightSourceCraftPot") -- when craft pot closes, it should unhighlight everything that was previously highlighted by craftpot. That's why we use this Tag and all the source stuff
--                    end
--                    for i=1,50 do
--                        if owner["mynetvarSearchedChest"..tostring(i)]:value()==nil then -- look for empty slot
--                           v.highlightsource = source -- add this temporary info
--                           owner["mynetvarSearchedChest"..tostring(i)]:set(v)
--                           break
--                       end
--                   end
--               end
--            end
--        end
--    end
--end
--
--local function ClientUnhighlightChests(owner,prefab,source,unhighlighten,highlighten)
--    print ('ClientUnhighlightChests')
--    if CLIENT_SIDE then -- only client pass
--        print ('I am Client')
--        if unhighlighten then
--            -- print("client unhighlight start")
--            for i=1,50 do -- alle bekannten Chests unhighlighten
--                local chest = owner["mynetvarSearchedChest"..tostring(i)]:value()
--                if chest and chest.components.highlight then
--                  -- print("client unhighlight "..tostring(chest).." hattag: "..tostring(chest:HasTag("HighlightSourceCraftPot")).." source: "..tostring(source))
--                  if not (not chest:HasTag("HighlightSourceCraftPot") and source=="CraftPotClose") then
--
--                      if chest.components.highlight.ApplyColour == ApplyHighlight then
--                        chest.components.highlight.ApplyColour = nil
--                      end
--
--                      if chest.components.highlight.UnHighlight == ClearHighlight then
--                        chest.components.highlight.UnHighlight = nil
--                      end
--
--                      chest.components.highlight:UnHighlight()
--                    end
--                end
--            end
--        end
--        if SERVER_SIDE then -- can be both client and server for player 1
--            print("~~~ServerSide call");
--            ServerRPCFunction(owner,prefab,source,unhighlighten,highlighten) -- call it directly without rpc, if we are also server
--        else
--            local rpc = GetModRPC("FinderMod", "CheckContainersItem")
--            SendModRPCToServer(rpc,prefab,source,unhighlighten,highlighten)
--        end
--    end
--end
--
--local function DoHighlightStuff(owner,prefab,source,unhighlighten,highlighten)
--    print ('Do highlight stuff please')
--    if CLIENT_SIDE and owner==GLOBAL.ThePlayer then
--        print ('Do highlight as client')
--        ClientUnhighlightChests(owner,prefab,source,unhighlighten,highlighten)
--    end
--end
--
--local function onactiveitem(owner,data)
--    print ('On active item call')
--    local prefab = data.item and data.item.prefab or nil
--    local source = "newactiveitem"
--    if owner and prefab then -- unhighlight + highlight
--        DoHighlightStuff(owner,prefab,source,true,true)
--    else -- only unhighlight
--        DoHighlightStuff(owner,prefab,source,true,false)
--    end
--end
--
--local function OnDirtyEventSearchedChest(inst,i) -- this is called on client, if the server does inst.mynetvarTitleStufff:set(...)
--    -- print("OnDirtyEventSearchedChest i "..tostring(i))
--    if CLIENT_SIDE and inst==GLOBAL.ThePlayer then -- only this specific client pass
--        if client_option then
--            local chest = inst["mynetvarSearchedChest"..tostring(i)]:value()
--            if chest then
--                -- print("client highlight event number "..tostring(i).." chest: "..tostring(chest))
--                if not chest.components.highlight then
--                    chest:AddComponent('highlight')
--                end
--
--                if chest.components.highlight then
--                    chest.components.highlight.ApplyColour = ApplyHighlight
--                    chest.components.highlight.UnHighlight = ClearHighlight
--                    chest.components.highlight:Highlight(0, 0, 0)
--                end
--            end
--        end
--    end
--end
--
--
--local function RegisterListeners(inst)
--    for i=1,50 do
--        inst:ListenForEvent("DirtyEventSearchedChest"..tostring(i), function(inst) inst:DoTaskInTime(0,OnDirtyEventSearchedChest(inst,i)) end)
--    end
--end
--
--local function init(inst)
--    if not inst then return end
--    for i=1,50 do -- allow up to 50 containers (cause we can't use an array of entities, we use 50 entity netvars)
--        inst["mynetvarSearchedChest"..tostring(i)] = GLOBAL.net_entity(inst.GUID, "SearchedChest"..tostring(i).."NetStuff", "DirtyEventSearchedChest"..tostring(i))
--        inst["mynetvarSearchedChest"..tostring(i)]:set(nil)
--    end
--    inst:DoTaskInTime(0, RegisterListeners)
--    inst:ListenForEvent('newactiveitem', onactiveitem)
--end
--
--AddPlayerPostInit(function (owner)
--    print ('Adding player post init')
--    init(owner)
--end)
--
--AddModRPCHandler("FinderMod", "CheckContainersItem", ServerRPCFunction)
--
---- ######################
--
----[ highlighting when ingredient in recipepopup is hovered
--AddClassPostConstruct("widgets/ingredientui", function(self)
--    local __IngredientUI_OnGainFocus = self.OnGainFocus
--
--    function self:OnGainFocus (...)
--      local tex   = self.ing and self.ing.texture and self.ing.texture:match('[^/]+$'):gsub('%.tex$', '')
--      local owner = self.parent and self.parent.parent and self.parent.parent.owner
--      if tex and owner then
--        DoHighlightStuff(owner,tex,"Crafting",true,true)
--      end
--      if __IngredientUI_OnGainFocus then
--        return __IngredientUI_OnGainFocus(self, ...)
--      end
--    end
--
--    local __IngredientUI_OnLoseFocus = self.OnLoseFocus
--    function self:OnLoseFocus(...)
--        local owner = self.parent and self.parent.parent and self.parent.parent.owner
--        DoHighlightStuff(owner,nil,"Crafting",true,false)
--        if __IngredientUI_OnLoseFocus then
--            return __IngredientUI_OnLoseFocus(self,...)
--        end
--    end
--end)
--
--
---- ### Compatible to Craft Pot Mod, to find food with the searched tags
--local function testCraftPot()
--    local FoodIngredientUI = _G.require 'widgets/foodingredientui'
--end
--if GLOBAL.pcall(testCraftPot) then
--    local cooking = _G.require("cooking")
--    local ing = cooking.ingredients
--
--    AddClassPostConstruct("widgets/foodingredientui", function(self)
--        local __FoodIngredientUI_OnGainFocus = self.OnGainFocus
--        function self:OnGainFocus(...)
--            local searchtag = self.prefab -- tag or name
--            local isname = self.is_name
--            local owner = self.owner
--            local prefabs = {} -- find all the prefabs with that cooking tag
--
--            if not isname then
--                for prefab,xyz in pairs(ing) do
--                    for tag,number in pairs(xyz.tags) do
--                        if tag==searchtag then
--                            table.insert(prefabs,prefab)
--                        end
--                    end
--                end
--            elseif isname and GLOBAL.PREFABDEFINITIONS[searchtag] then
--                table.insert(prefabs,GLOBAL.PREFABDEFINITIONS[searchtag].name)
--            end
--            DoHighlightStuff(owner,nil,"CraftPot",true,false) -- to unhighlight everything
--            for k,prefab in pairs(prefabs) do -- send one prefab after the other, cause sedning an array via rpc does not work..
--                if prefab and owner then
--                  DoHighlightStuff(owner,prefab,"CraftPot",false,true) -- highlight every prefab, without unhighlighting in between
--                end
--            end
--            if __FoodIngredientUI_OnGainFocus then
--                return __FoodIngredientUI_OnGainFocus(self,...)
--            end
--        end
--    end)
--
--    AddClassPostConstruct("widgets/foodcrafting", function(self)
--        local _OnLoseFocus = self.OnLoseFocus
--        self.OnLoseFocus = function(...)
--            local owner = self.owner
--            DoHighlightStuff(owner,nil,"CraftPot",true,false) -- to unhighlight
--            if _OnLoseFocus then
--                return _OnLoseFocus(self, ...)
--            end
--        end
--
--        local _Close = self.Close
--        self.Close = function(...)
--            local owner = self.owner
--            DoHighlightStuff(owner,nil,"CraftPotClose",true,false) -- this unhighlight ony should work for highlights made with craft pot
--            if _Close then
--                return _Close(self, ...)
--            end
--        end
--    end)
--end
--
--
--AddClassPostConstruct("widgets/tabgroup", function(self)
--    local __TabGroup_DeselectAll = self.DeselectAll
--    function self:DeselectAll(...)
--      DoHighlightStuff(GLOBAL.ThePlayer,nil,"CraftingClose",true,false)
--      return __TabGroup_DeselectAll(self, ...)
--    end
--end)
--


function GetStorage()
    return GLOBAL.ThePlayer.components.container_memory_storage
end


local function ContainerPostConstruct(inst, prefab)
  if prefab:HasTag('structure') then
    prefab:AddComponent('container_memory')
    prefab.components.container_memory:InjectHandlers(inst)
  end
end

AddPlayerPostInit(function(self)
  --  print('~~~SECRETS of TheSim'..table.stringify(TheSim))
  --print('~~~SECRETS of TheNet'..table.stringify(GLOBAL.TheNet))
  --  print('adding ContainerMemoryStorage')
  --self:AddComponent('container_memory_storage')
end)

-- first block is used for DST clients, second - for DS/DST Host
if CLIENT_SIDE then
	AddClassPostConstruct("components/container_replica",  ContainerPostConstruct)
end