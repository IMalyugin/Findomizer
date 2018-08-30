--[ highlighting when active item is changed
local Highlight = require 'components/highlight'
local __Highlight_ApplyColour = Highlight.ApplyColour
local __Highlight_UnHighlight = Highlight.UnHighlight

-- additional highlight of found container objects
local c = {r = 0, g = .25, b = 0}

return function(GLOBAL, env)
  local IsDST = GLOBAL.TheSim:GetGameID() == 'DST'

  -- this maintains colour when the game unhighlights our object
  local function ApplyHighlight(self, ...)
    local r, g, b =
    (self.base_add_colour_red   or 0),
    (self.base_add_colour_green or 0),
    (self.base_add_colour_blue  or 0)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue =
    r + c.r, g + c.g, b + c.b

    local result = __Highlight_ApplyColour(self, ...)

    self.base_add_colour_red,
    self.base_add_colour_green,
    self.base_add_colour_blue = r, g, b

    return result
  end

  -- prevents removal of the whole component on UnHighlight
  local function ClearHighlight(self, ...)
    local flashing = self.flashing
    self.flashing = true
    local result = __Highlight_UnHighlight(self, ...)
    self.flashing = flashing

    if IsDST and not self.flashing then
      local r, g, b =
      (self.highlight_add_colour_red   or 0),
      (self.highlight_add_colour_green or 0),
      (self.highlight_add_colour_blue  or 0)

      self.highlight_add_colour_red,
      self.highlight_add_colour_green,
      self.highlight_add_colour_blue =
      0, 0, 0

      self:ApplyColour()

      self.highlight_add_colour_red,
      self.highlight_add_colour_green,
      self.highlight_add_colour_blue = r, g, b
    end

    return result
  end

  return {
    ApplyHighlight = ApplyHighlight,
    ClearHighlight = ClearHighlight,
  }
end