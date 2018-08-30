function GetIntCoords(inst)
    if not inst or not inst.Transform or not inst.Transform.GetWorldPosition then
        print('Findomizer couldn\'t determine coordinates of inst')
        return 0, 0
    end

    local x, _, z = inst.Transform:GetWorldPosition()

    --This one is from base game, probably to kill infinity
    --And round it to 1st sign,
    x = x == x and math.floor(x*10) or 0
    z = z == z and math.floor(z*10) or 0
    return x, z
end

function GetIdentifierSet(x, z, BufferSize)
    -- 10 from coordinate increment, 4 more for how much one square contains
    BufferSize = BufferSize * 40
    local round_x = math.floor(x / BufferSize)
    local round_z = math.floor(z / BufferSize)
    local mod_x = x % BufferSize
    local mod_z = z % BufferSize
    return
    -- MemoryBuffer Identifier
    tostring(round_x)..'_'..tostring(round_z),
    -- LocalIdentifier, a positive number from 0 to 2 * BufferSize
    tostring(mod_x + BufferSize)..'_'..tostring(mod_z + BufferSize)
end

return {
    GetIntCoords = GetIntCoords,
    GetIdentifierSet = GetIdentifierSet,
}