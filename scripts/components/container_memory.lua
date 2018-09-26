local MemoryBufferGate = require('models/memory_buffer')

local function IsClientSim()
  return TheNet:GetIsClient()
end

---
-- Extends `class` `method` with function `extendFn` that takes same arguments
--
function ExtendInstMethod(inst, method, extendFn)
  local originalMethod = inst[method]
  inst[method] = function(...)
    local result = originalMethod(...)
    extendFn(...)
    return result
  end
end

local ContainerMemory = Class(function(self, inst)
  self.inst = inst
  self._items = {}
  self._GetStorage = nil

  inst.components.container_memory:InjectHandlers(inst)
  if IsClientSim() then
    inst:DoTaskInTime(0, function()
      self:OnLoad()
      self:PrintContents()
    end)
  end
end)

function ContainerMemory:AddItem(item, quantity)
  local quantity = quantity or 1
  local prefab = item.prefab
  if not self._items[prefab] then
    self._items[prefab] = (self._items[prefab] or 0) + quantity
  end
end

---
-- Bridge method from container_memory to container_replica
-- creates listeners to keep memory up to date
--
function ContainerMemory:InjectHandlers(inst)
  local prefab = inst.inst
  local TrackNextGetItems = false

  ExtendInstMethod(inst, 'Open', function()
    print('~~~ Open')
    TrackNextGetItems = true
  end)

  ExtendInstMethod(inst, 'GetItems', function()
    print('~~~ Getitems')
    if TrackNextGetItems then
      print('~~~ GetItems fired')
      TrackNextGetItems = false

      self._items = {}
      for k, v in pairs( items ) do
        print(tostring(k))
        self:AddItem(v.prefab, v.quantity)
      end
      self:PrintContents()
    end
  end)


  ExtendInstMethod(inst, 'OnEntityRemove', function()
    print('removing Entity')
    self:OnSave()
  end)


  local function changefn(inst)
    print('onchange')
    self:PrintContents()
  end
  prefab:ListenForEvent("itemget", changefn)
  prefab:ListenForEvent("itemlose", changefn)
end

function ContainerMemory:OnSave()
  local data = self._items
  MemoryBufferGate:OnSave(data, self)
end

function ContainerMemory:OnLoad()
  self._items = MemoryBufferGate:OnLoad(self)
  if self._items == nil then
    self._items = {}
    self._accuracy = 0
    print('~~~Container loaded no items')
  else
    -- TODO: save and adjust accuracy
    self._accuracy = 1
    self:PrintContents()
  end
end

function ContainerMemory:GetItems()
  return self._items
end

function ContainerMemory:HasItemProbability()
  local items = self:GetItems()
  for _, item in ipairs(items) do
    -- TODO: make count of items actually count
    if self._items[prefab] then
      return self._accuracy
    else
      return -self._accuracy
    end
  end
end

function ContainerMemory:PrintContents()
  for k, v in ipairs( self:GetItems() ) do
    print('~~~Contains'..v)
  end
end

return ContainerMemory
