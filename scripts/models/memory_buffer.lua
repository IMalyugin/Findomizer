local __coordinates = require('utils/coordinates')
local GetIntCoords = __coordinates.GetIntCoords
local GetIdentifierSet = __coordinates.GetIdentifierSet


--- Memory buffer is a class that accumulates a data set for multiple instances
--- it saves and loads them in bulks, preventing overhead to disk I/O
local MemoryBuffer = Class(function(self, globalId)
    self._classToUID = {}
    self._saveInProgress = false
    self._data = {}
    self._filepath = "session/"
        ..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/"
        .."mbd_"..globalId -- [M]emory [B]uffer [D]ata
    print('Initialized a MemoryBuffer '..self._filepath)
    self:__DoLoad()
end)

function MemoryBuffer:__DoSave()
    local strdata = json.encode(self._data)
    TheSim:SetPersistentString(self._filepath, strdata, true)
end

function MemoryBuffer:__DoLoad()
    TheSim:GetPersistentString(self._filepath, function(success, strdata)
        if success then
            print('loaded successfully')
            self._data = json.decode(strdata)
        end
    end)
end


function MemoryBuffer:CreateClassBinding(uid, class)
    -- `uid` is unique identifier across MemoryBuffer
    self._classToUID[class] = uid
end

--- Save method works in two different mods,
---  master mode - is when save orchestration is performed,
---  slave mode - is when the data is gathered
function MemoryBuffer:OnSave(data, class)
    if not self._saveInProgress then
        --- master mode
        self._saveInProgress = true
        for k, v in pairs(self._classToUID) do
            k:OnSave()
        end
        self:__DoSave()
        self._saveInProgress = false
    else
        --- slave mode, just fill in the data from all classes
        local uid = self._classToUID[class]
        self._data[uid] = data
    end
end

--- Simple load method actually has no disc I/O,
--- all the data is read on MemoryBuffer initialization
--- this method can't be called before CreateClassBinding
function MemoryBuffer:OnLoad(class)
    local uid = self._classToUID[class]
    return self._data[uid]
end



--- Memory gate is a singleton entry point for memory buffers,
--- it initializes new buffers when needed
--- and forwards requests towards them
--- utilizes global identifiers
---
--- Model works under one HUGE assumption, every method is called via class passed to it,
--- that class must have inst field pointing to a prefab
local MemoryGate = Class(function(self, size)
    self._size = size
    self._buffers = {} -- contains table of MemoryBuffers by globalId
    self._classToBuffer = {} -- contains MemoryBuffer by class
end)

function MemoryGate:__GetMemoryBufferById(globalId)
    -- if buffer is initialized - use it, otherwise create it
    return self._buffers[globalId] or MemoryBuffer(globalId)
end

--- this method will be called automatically on first access to MemoryGate
function MemoryGate:__AssignMemoryBuffer(class)
    local x, z = GetIntCoords(class.inst)
    local globalId, localId = GetIdentifierSet(x, z, self._size)

    local buffer = self:__GetMemoryBufferById(globalId)
    self._classToBuffer[class] = buffer
    buffer:CreateClassBinding(localId, class)

    return buffer
end

function MemoryGate:__GetMemoryBuffer(class)
    return self._classToBuffer[class] or self:__AssignMemoryBuffer(class)
end


function MemoryGate:OnLoad(class)
    return self:__GetMemoryBuffer(class):OnLoad(class)
end

function MemoryGate:OnSave(data, class)
    return self:__GetMemoryBuffer(class):OnSave(data, class)
end


return MemoryGate(4)