local g = function() return 0, .25, 0 end
local r = function() return .25, 0, 0 end

---
-- Hightlight controller is a component for manual highlighting of prefabs,
-- provides simplified persistent interface for highlight component,
-- to avoid unneccesary checks and low level method calls
--
local HighlightController = Class(function(self, inst)
  self.inst = inst
end)

function HighlightController:_SetHighlight(colour, percentage)
  if not self.inst.components.highlight then
    self.inst:AddComponent('highlight')
  end
  local _r, _g, _b = colour()

  self.inst.components.highlight:Highlight(_r * percentage, _g * percentage, _b * percentage)
end

function HighlightController:SetGreenHighlight(percentage)
  print('Set green '..tostring(percentage))
  self:_SetHighlight(g, percentage)
end

function HighlightController:SetRedHighlight(percentage)
  print('Set red '..tostring(percentage))
  self:_SetHighlight(r, percentage)
end

function HighlightController:ClearHighlight()
  if self.inst.components.highlight then
    self.inst.components.highlight:UnHighlight()
  end
end

return HighlightController
