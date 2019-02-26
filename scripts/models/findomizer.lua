---
-- Container Hub for item finding and highlighting items,
-- in order to work prefabs must have container_memory and highlight_contoller components
-- each container must be added via AddContainer method to be tracked
--
local Findomizer = Class(function(self)
  self._list = {}
end)

function Findomizer:AddContainer(inst)
  table.insert(self._list, inst)
  inst:AddComponent('container_memory')
  inst:AddComponent('highlight_controller')
end

function Findomizer:HighlightItems(items)
  local itemProb

  -- loop through all added containers
  for _, haystack in ipairs(self._list) do
    local prob = -1
    -- loop throuh all the items we wish to find
    for _, needle in ipairs(items) do
      itemProb = haystack.components.container_memory:GetItemProbability(needle)
      -- if we are searching for more than one item, best we can do is find the highest probability
      if itemProb > 0 then
        prob = math.max(prob, itemProb)
      elseif prob <= 0 then
        -- if probability is not positive, make it worse
        prob = math.min(prob, itemProb)
      end
    end

    print('GetItemProbability is '..tostring(prob))

    -- highlight as green if we know there is an item, red if we know there isn't or leave default on unknown
    -- TODO: need to move smart highlighting to actual probability calculation
    if prob > 0 then
      haystack.components.highlight_controller:SetGreenHighlight(math.max(prob, .25))
    elseif prob < 0 then
      haystack.components.highlight_controller:SetRedHighlight(math.max(-prob, .25))
    end
  end
end

function Findomizer:ClearHighlight()
  -- loop through all added containers
  for _, haystack in ipairs(self._list) do
    haystack.components.highlight_controller:ClearHighlight()
  end
end

return Findomizer()
