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

PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores 
    Timer.tween(0.5, {
        [self] = {transitionAlpha = 0}
    })
end

function PaddleSelectState:init()
    -- the paddle we're highlighting; will be passed to the ServeState
    -- when we press Enter
    self.currentPaddle = 1
    self.transitionAlpha = 255
    self.transitionBeta = 0

    -- Nav Button for Mobile
    self.backButton = Button(Buttons['back'])
    self.selectButton = Button(Buttons['select-button'])
    self.leftButton = Button(Buttons['left-arrow'])
    self.rightButton = Button(Buttons['right-arrow'])

end

function PaddleSelectState:update(dt)
    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())
    -- Update Timer
    Timer.update(dt)

    if love.keyboard.wasPressed('left') or (love.mouse.wasPressed(1) and MouseIn(self.leftButton, x, y)) then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        end
    elseif love.keyboard.wasPressed('right') or (love.mouse.wasPressed(1) and MouseIn(self.rightButton, x, y)) then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end
    end
    
    if love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y) then
        gStateMachine:change('start', { highScores = loadHighScores() })
    end

    -- select paddle and move on to the serve state, passing in the selection
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') or (love.mouse.wasPressed(1) and MouseIn(self.selectButton, x, y)) then
        gSounds['confirm']:play()

        Timer.tween(1, {
            [self] = {transitionBeta = 255}
        }):finish(function()
            gStateMachine:change('serve', {
                paddle = Paddle(self.currentPaddle),
                bricks = LevelMaker.createMap(1),
                health = 3,
                score = 0,
                highScores = self.highScores,
                level = 1
            })
        end)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PaddleSelectState:render()
    -- instructions
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Select your paddle with left and right!", 0, VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf("(Press Enter to continue!)", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')
        
    -- left arrow; should render normally if we're higher than 1, else
    -- in a shadowy form to let us know we're as far left as we can go
    if self.currentPaddle == 1 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setColor(40, 40, 40, 128)
    end
    
    --love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
    --    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
   
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(255, 255, 255, 255)

    -- right arrow; should render normally if we're less than 4, else
    -- in a shadowy form to let us know we're as far right as we can go
    if self.currentPaddle == 4 then
        -- tint; give it a dark gray with half opacity
        love.graphics.setColor(40, 40, 40, 128)
    end
    
    --love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
    --    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    
    -- reset drawing color to full white for proper rendering
    love.graphics.setColor(255, 255, 255, 255)

    -- draw the paddle itself, based on which we have selected
    love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)],
        VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

    -- Render nav Buttons

    self.backButton:render()
    self.selectButton:render()
    self.leftButton:render()
    self.rightButton:render()


    -- reset the color
    love.graphics.setColor(255, 255, 255, 255)

    -- draw special effect to produce snow effect
    love.graphics.draw (Psystem, VIRTUAL_WIDTH / 2, 0)

    -- fade out
    love.graphics.setColor(0, 0, 0, self.transitionBeta)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- fade in
    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end