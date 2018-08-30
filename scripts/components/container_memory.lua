local MemoryBufferGate = require('models/memory_buffer')

local function IsClientSim()
    return TheNet:GetIsClient()
end

local ContainerMemory = Class(function(self, inst)
    self.inst = inst
    self._items = {}
    self._itemsDict = {}
    self._GetStorage = nil
    self.persists = true
    inst.persists = true

    if IsClientSim() then
        inst:DoTaskInTime(0, function()
            self:OnLoad()
            self:PrintContents()
        end)
    end
end)

function ContainerMemory:AddItem(item)
    local prefab = item.prefab
    if not self._itemsDict[prefab] then
        table.insert(self._items, prefab)
        self._itemsDict[prefab] = true
    end
end

function ContainerMemory:InjectHandlers(inst)
    local prefab = inst.inst
    local TrackNextGetItems = false

    -- store base methods
    -- local onclosefn = inst.Close

    -- define modded actions
    local onopenfn = inst.Open
    local function mod_onopen(inst, doer, ...)
        TrackNextGetItems = true
        onopenfn(inst, doer, ...)
    end
    inst.Open = mod_onopen


    local getitemsfn = inst.GetItems
    local function mod_getitems(inst, ...)
        local items = getitemsfn(inst, ...)
        if TrackNextGetItems then
            TrackNextGetItems = false

            self._items = {}
            for k, v in pairs( items ) do
                print(tostring(k))
                self:AddItem(v)
            end
            self:PrintContents()
            --self:SetOutdated()
        end
        return items
    end
    inst.GetItems = mod_getitems



    local function changefn(inst)
        print('onchange')
        self:PrintContents()
        --self:SetOutdated()
        --local player = GetPlayer()
        --if player and player.HUD then player.HUD.controls.foodcrafting:SortFoods() end
    end

    local OnRemoveEntity = inst.OnRemoveEntity
    local function mod_OnRemoveEntity(...)
        print('removing Entity')
        self:OnSave()
        return OnRemoveEntity(...)
    end
    inst.OnRemoveEntity = mod_OnRemoveEntity
    -- override methods

    --inst.Close = mod_onclose

    prefab:ListenForEvent("itemget", changefn)
    prefab:ListenForEvent("itemlose", changefn)
end

function ContainerMemory:OnSave()
    local data = self._items
    MemoryBufferGate:OnSave(data, self)
end

function ContainerMemory:OnLoad()
  self._items = MemoryBufferGate:OnLoad(self) or {}
  self:PrintContents()
end

function ContainerMemory:GetItems()
  return self._items
end

function ContainerMemory:PrintContents()
    for k, v in ipairs( self:GetItems() ) do
        print('~~~Contains'..v)
    end
end

return ContainerMemory
