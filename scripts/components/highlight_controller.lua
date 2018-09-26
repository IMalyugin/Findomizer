local g = function() return 0, .25, 0 end
local r = function() return 0.25, 0, 0 end

---
-- Hightlight controller is a component for manual highlighting of prefabs,
-- provides simplified persistent interface for highlight component,
-- to avoid unneccesary checks and low level method calls
--
local HighlightController = Class(function(self, inst)
  self.inst = inst
end)

function HighlightController:_SetHighlight(colour, percentage)
  if not inst.components.highlight then
    inst.AddComponent('highlight')
  end
  local r, g, b = colour()

  inst.components.highlight:Highlight(r * percentage, g * percentage, b * percentage)
end

function HighlightController:SetGreenHighlight(percentage)
  self:_SetHighlight(g, percentage)
end

function HighlightController:SetRedHighlight(percentage)
  self:_SetHighlight(r, percentage)
end

function HighlightController:ClearHighlight()
  if inst.components.highlight then
    inst.components.highlight:UnHighlight()
  end
end

return HighlightController
