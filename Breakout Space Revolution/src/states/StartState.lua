--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the state the game is in when we've just started; should
    simply display "Breakout" in large text, as well as a message to press
    Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that BaseState has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
StartState = Class{__includes = BaseState}

-- whether we're highlighting "Start" or "High Scores"
local highlighted = 1

function StartState:enter(params)
    self.highScores = params.highScores

    self.transitionAlpha = 0

    self.startButton = Button(Buttons['start'])
    self.hightScoreButton = Button(Buttons['high-scores'])
end

function StartState:update(dt)

    -- update our Timer, which will be used for our fade transitions
    Timer.update(dt)

    
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    -- confirm whichever option we have selected to change screens
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()
        if highlighted == 2 then
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('high-scores', {
                highScores = self.highScores})
            end)
            
        elseif highlighted == 1 then
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('paddle-select', {
                    highScores = self.highScores    
                })
            end)
        end
    end

    if love.mouse.wasPressed(1) then
        if MouseIn(self.hightScoreButton, x, y) then
            gSounds['confirm']:play()
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('high-scores', {
                highScores = self.highScores})
            end)
            
        elseif MouseIn(self.startButton, x, y) then
            gSounds['confirm']:play()
            Timer.tween(1, {
                [self] = {transitionAlpha = 255}
            }):finish(function()
                gStateMachine:change('paddle-select', {
                    highScores = self.highScores    
                })
            end)
        end
    end

    -- we no longer have this globally, so include here
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

end

function StartState:render()
    -- title
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Space-Revolution', 0, VIRTUAL_HEIGHT / 3 + 35, VIRTUAL_WIDTH, 'center')

    love.graphics.draw(gTextures['instructions'], 5, 5)
    DisplayInstruction()

    -- Render menu buttons
    self.startButton:render()
    self.hightScoreButton:render()

    -- if we're highlighting 1, render that option blue
    if highlighted == 1 then
        love.graphics.setColor(103, 255, 255, 255)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70,
        VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- render option 2 blue if we're highlighting that one
    if highlighted == 2 then
        love.graphics.setColor(103, 255, 255, 255)
    end
    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90,
        VIRTUAL_WIDTH, 'center')

    -- draw our transition rect; is normally fully transparent, unless we're moving to a new state
    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    
    -- reset to white (for particle system below to be white!)
    love.graphics.setColor(255, 255, 255, 255)
    -- draw special effect to produce snow effect
    love.graphics.draw (Psystem, VIRTUAL_WIDTH / 2, 0)
end