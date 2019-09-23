--[[
    Breakout Space Rev

    -- Button Class

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents an Button which will serve as a movement button for mobile users of the game
]]

Button = Class{}

function Button:init(button)
    self.texture = button.texture
    self.frame = button.frame
    self.width = button.width
    self.height = button.height
    self.x = button.x
    self.y = button.y
    self.mouseIn = false
    self.mouseX, self.mouseY = 0, 0
end

function Button:update(dt)
    
end

function Button:render()
    if not self.texture then
        love.graphics.setColor(0, 0, 0, 200)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 6)
        love.graphics.setColor(255, 255, 255, 255)
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
    end
end


