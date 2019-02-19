local MemoryBufferGate = require('models/memory_buffer')

local function IsClientSim()
  return TheNet:GetIsClient()
end



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

local function key_to_str ( k )
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
      table.insert( result, indent..key_to_str( k ) .. "=" .. val_to_str( v, indent.."  " ) )
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



---
-- Extends `class` `method` with function `extendFn` that takes same arguments
--
function ExtendInstMethod(inst, method, extendFn)
  local originalMethod = inst[method]
  inst[method] = function(...)
    local result = originalMethod(...)
    extendFn(result, ...)
    return result
  end
end

local ContainerMemory = Class(function(self, inst)
  self.inst = inst
  self._items = {}
  self._GetStorage = nil

  if IsClientSim() then
    inst:DoTaskInTime(0, function()
      self:OnLoad()
      self:PrintContents()
    end)
  end
end)

function ContainerMemory:AddItem(prefab, quantity)
  quantity = quantity or 1
  print('Adding '..prefab)
  self._items[prefab] = (self._items[prefab] or 0) + quantity
end

---
-- Bridge method from container_memory to container_replica
-- creates listeners to keep memory up to date
--
function ContainerMemory:InjectHandlers(replica)
  local TrackNextGetItems = false

  ExtendInstMethod(replica, 'Open', function()
    print('~~~ Open')
    TrackNextGetItems = true
  end)

  ExtendInstMethod(replica, 'GetItems', function(items)
    print('~~~ Getitems')
    if TrackNextGetItems then
      print('~~~ GetItems fired')
      TrackNextGetItems = false

      self._items = {}
      for k, v in pairs( items ) do
        -- print('~~~~~ items for GetItems:')
        -- print(table.stringify(v))
        self:AddItem(v.prefab)
      end
      self:PrintContents()
    end
  end)

  local function changefn(inst)
    print('onchange')
    self:PrintContents()
  end

  local function savefn(inst)
    print('onremove')
    self:OnSave()
  end

  self.inst:ListenForEvent("itemget", changefn)
  self.inst:ListenForEvent("itemlose", changefn)
  self.inst:ListenForEvent("onremove", savefn)
end

function ContainerMemory:OnSave()
  local data = self:GetItems()
  print('~~~ saving items')
  self:PrintContents()
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
  for _, item in pairs(items) do
    -- TODO: make count of items actually count
    if self._items[item] then
      return self._accuracy
    else
      return -self._accuracy
    end
  end
end

function ContainerMemory:PrintContents()
  print('~~~Printing Container contents')
  for k, v in pairs( self:GetItems() ) do
    print('~~~Contains'..k)
  end
end

return ContainerMemory
