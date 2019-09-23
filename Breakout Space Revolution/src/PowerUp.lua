


PowerUp = Class{}

PowerUpColor = {
    [1] = paletteColors[3],
    [2] = paletteColors[2],
    [3] = paletteColors[4],
    [4] = paletteColors[4],
    [5] = paletteColors[5],
    [6] = paletteColors[5],
    [7] = paletteColors[1],
    [8] = paletteColors[1],
    [9] = paletteColors[1],
    [10] = paletteColors[5],
}
function PowerUp: init(type)
    
    self.type = type
    self.width = 16
    self.height = 16
    self.remove = false
    self.collected = false -- Flag to note wether or not a PowerUp was collected. Only the key(10) and ball_multiplier(9) powerUps are collectible.
    
    -- Make PowerUp spawn down the screen
    self.dx = math.random(-200, 200)
    self.dy = math.random(50, 60)
    -- Make PowerUp spawn from anywhere from the top edge of the screen 
    self.x = math.random(0, VIRTUAL_WIDTH - self.width) 
    self.y = 0 - self.height  

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-15, 0, 15, 20)
    self.psystem:setAreaSpread('normal', 10, 10)
end
--[[
    Expects an argument with a bounding box: only the paddle will be a valid candidate in terms of the game logic
    and returns true if the powerUp bounding boxes and the paddle's overlap.
]]
function PowerUp:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--Function called to add fancy effect near paddle as it collects a power up
------Not Working :/
function PowerUp:hit()
    self.psystem:setColors(
        PowerUpColor[self.type].r,
        PowerUpColor[self.type].b,
        PowerUpColor[self.type].g,
        60,
        PowerUpColor[self.type].r,
        PowerUpColor[self.type].b,
        PowerUpColor[self.type].g,
        0
    )
    self.psystem:emit(64)

    gSounds['powerUp']:stop()
    gSounds['powerUp']:play()
    gSounds['powerUp']:setVolume(0.5)
end

function PowerUp:update(dt)

    self.psystem:update(dt)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- allow paddle to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    self.remove = self.collected == true and true or false -- Set remove flag to true if collected became true
    -- remove powerUp if it goes pass bottom edge of the screen
    if self.y > VIRTUAL_HEIGHT then
        self.remove = true
    end
end

function PowerUp:render()
    love.graphics.draw(gTextures['main'], gFrames['powerUps'][self.type], self.x, self.y)
end

function PowerUp:renderParticles()
    love.graphics.draw(self.psystem, self.x, self.y)
end
