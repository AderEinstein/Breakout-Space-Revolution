--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:init()
    self.playTime = 0
    self.powerUps = {}
    self.balls = {}
    self.paused = false
    self.transitionBeta = 0

    -- To produce special effect for the collection of a powerUp by the paddle
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
    self.psystem:setParticleLifetime(0.5, 1)
    self.psystem:setLinearAcceleration(-15, 0, 15, 20)
    self.psystem:setAreaSpread('normal', 32, 16)
    self.psystem:setSpin(20, 50)

    self.lastScoreCheckPoint = 0

    -- Nav Buttons
    self.backButton = Button(Buttons['back'])
    self.pauseButton = Button(Buttons['pause'])

end

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.lastScoreCheckPoint = params.lastScoreCheckPoint == nil and 0 or params.lastScoreCheckPoint
    self.backgroundScroll = params.backgroundScroll

    -- give balls random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
end

function PlayState:update(dt)
    -- update timer for fading in/out
    Timer.update(dt)

    self.backgroundScroll = (self.backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    self.psystem:update(dt)

    if not self.paused then
        self.playTime = self.playTime + dt
        local nextPowerUpTimer = math.random(3, 10)

        if self.playTime > nextPowerUpTimer then
            table.insert(self.powerUps, PowerUp(math.random(3, 10))) -- Defined powerUps are within this interval in the powerUp table
            self.playTime = 0
        end
    end

    -- check for score checkPoint : We augment the brick size every +1000 points scored
    local scoreEvolution = self.score - self.lastScoreCheckPoint
    if scoreEvolution >= 1000 then
        if self.paddle.size < 4 then
            self.paddle.size = self.paddle.size + 1
            gSounds['paddle_growth']:play()
        end
        self.lastScoreCheckPoint = self.lastScoreCheckPoint + 1000
    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    -- Update nav button checking if pressed 
    if love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y) then
        love.audio.stop()
        gSounds['music-intro']:play()
        gStateMachine:change('start', { highScores = loadHighScores() })
    end

    if self.paused then
        if love.keyboard.wasPressed('space') or (love.mouse.wasPressed(1) and MouseIn(self.pauseButton, x, y)) then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') or (love.mouse.wasPressed(1) and MouseIn(self.pauseButton, x, y)) then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update paddles position based on velocity 
    self.paddle:update(dt, x, y)

    -- update balls position based on velocity 
    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end
    -- update powerUps position based on velocity 
    for k, powerUp in pairs(self.powerUps) do
        powerUp:update(dt)
    end

    -- detect ball and paddle collision
    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision / picking Up  of a powerUp with paddle
    for k, powerUp in pairs(self.powerUps) do
        if powerUp:collides(self.paddle) then
            self.psystem:setColors(
                PowerUpColor[powerUp.type].r,
                PowerUpColor[powerUp.type].b,
                PowerUpColor[powerUp.type].g,
                60,
                PowerUpColor[powerUp.type].r,
                PowerUpColor[powerUp.type].b,
                PowerUpColor[powerUp.type].g,
                0
            )
            self.psystem:setAreaSpread('normal', self.paddle.width - 30, self.paddle.height - 8)
            self.psystem:emit(64)

            powerUp:hit() -- Issue: Particle system insantiated from PowerUp class doesn't produce any effect :/

            powerUp.collected = true

            -- Life Boost PowerUp
            if powerUp.type == 3 then
                if self.health < 3 then
                    self.health = self.health + 1
                end
                if self.paddle.size == 1 and self.health == 3 then 
                    -- Recover size
                    self.paddle.size = 2
                    gSounds['paddle_growth']:play()
                end 
            -- Life Devil PowerUp    
            elseif powerUp.type == 4 then
                self.health = self.health - 1
                if self.paddle.size > 2 then 
                    self.paddle.size = self.paddle.size - 1
                    gSounds['paddle_shrink']:play()
                end
                -- Give a minimal size to the paddle if its life is already threaten irrespective of its current size
                if self.health == 1 then 
                    self.paddle.size = 1
                    gSounds['paddle_shrink']:play()
                end
                -- Change to game over only when the collection of a life Devil powerUp brings your life down to 0
                if self.health == 0 then
                    gSounds['paddle_shrink']:play()
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                   
                end
            -- Score Boost powerUp
            elseif powerUp.type == 5 then
                self.score = self.score + 100
            -- Score Jerk powerUp
            elseif powerUp.type == 6 then
                self.score = self.score - 100
            -- Ball SpeedUp PowerUp
            elseif powerUp.type == 7 then
                 -- slightly scale up the ball y velocity by 30% to speed up the game, capping at +- 200
                 for k, ball in pairs(self.balls) do
                    if math.abs(ball.dy) < 200 then
                        ball.dy = ball.dy * 1.03
                    end
                end
            -- Ball SlowDown PowerUp
            elseif powerUp.type == 8 then
                -- slightly scale down the ball y velocity by 30% to speed up the game, capping at +- 200
                for k, ball in pairs(self.balls) do
                    if math.abs(ball.dy) < 200 then
                        ball.dy = ball.dy * 0.7
                    end
                end
            -- Ball Multiplier powerUp
            elseif powerUp.type == 9 then
                for i = 1, 2 do -- Insert 2 new balls
                    local newBall = Ball(math.random(7))
                    --Initialize the new Ball to spawn downwards from the top edge of the screen and insert into table
                    newBall.x = math.random(0, VIRTUAL_WIDTH - newBall.width)
                    newBall.y = 0 -- Optional line since this is the default ball's Y set in its init function  
                    newBall.dx = math.random(-200, 200)
                    newBall.dy = math.random(50, 60)
                    table.insert(self.balls, newBall)
                end
                -- If any of the previous balls in the table possessed the Key, pass it to every other ball
                local keyCollected = false
                for b, ball in pairs(self.balls) do
                    if ball.possessKey == true then
                        keyCollected = true
                        break
                    end
                end
                if keyCollected then 
                    for b, ball in pairs(self.balls) do
                        ball.keyCollected = true
                    end
                end
         -- Key PowerUp
            elseif powerUp.type == 10 then
                for k, ball in pairs(self.balls) do
                    ball.possessKey = true
                end
            end
        end 
    end
    -- If any powerUp goes below bounds, remove it from our powerUps table
    for k, powerUp in pairs(self.powerUps) do
        if powerUp.remove or powerUp.collected then
            table.remove(self.powerUps, k)
        end
    end
    local keyUsed = false
    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for l, ball in pairs(self.balls) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                if brick.isLocked == true then
                    if ball.possessKey == true then
                        -- Add Extra Reward to score for breaking locked brick
                        self.score = self.score + 500 
                        -- trigger the brick's hit function, which removes it from play
                        brick:hit()
                        -- Release key - Will trigger its Erasel from the top right corner of the screen 
                        for m, ball in pairs(self.balls) do
                            ball.possessKey = false
                        end
                        keyUsed = true
                    end
                else
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()
                end
                --[[ Release Key from every current balls
                if keyUsed then
                    for k, brick in pairs(self.bricks) do
                        ball.possessKey = false
                    end
                end]]

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        balls = self.balls
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if every ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do

        if #self.balls == 1 and ball.y >= VIRTUAL_HEIGHT then
            self.health = self.health - 1
            gSounds['hurt']:play()
         -- Decrease size of paddle every time player looses a life 
            if self.paddle.size > 2 or (self.paddle.size > 1 and not (self.health == 2)) then 
                self.paddle.size = self.paddle.size - 1
                gSounds['paddle_shrink']:play()
            end
            -- Give a minimal size to the paddle if its life is already threaten irrespective of its current size
            if self.health == 1 then 
                self.paddle.size = 1
                gSounds['paddle_shrink']:play()
            end
            if self.health == 0 then
                    gSounds['paddle_shrink']:play()
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
           
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    lastScoreCheckPoint = self.lastScoreCheckPoint
                })
            end
        end
    end
    -- If any ball goes below bounds, remove it from our ball table
    for k, ball in pairs(self.balls) do
        if ball.remove == true then
            table.remove(self.balls, k)
    end
    
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
end
end

function PlayState:render()

    --render scrolling background
    love.graphics.draw(gTextures['background-game'], 
        -- draw at coordinates 0, -backgroundScroll
        0, -self.backgroundScroll, 
        -- no rotation
        0)

    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    -- render ball and duplicates if any
    for k, ball in pairs(self.balls) do
        ball:render()
    end
    -- render powerUps
    for k, powerUp in pairs(self.powerUps) do
        powerUp:render()
    end
    -- render particle system
    for k, powerUp in pairs(self.powerUps) do
        powerUp:renderParticles()
    end

    -- Render key power up at top right edge of the screen to indicate the player possesses the key to break a locked brick
    for k, ball in pairs(self.balls) do
        if ball.possessKey == true then
            love.graphics.draw(gTextures['main'], gFrames['powerUps'][10], VIRTUAL_WIDTH - 26, 12)
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- Render nav Buttons
    self.backButton:render()
    self.pauseButton:render()

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 50, VIRTUAL_WIDTH, 'center')
        
        -- Power Up Guide / Key
        for power_Up = 3, 10 do 
            love.graphics.draw(gTextures['main'], gFrames['powerUps'][power_Up], VIRTUAL_WIDTH / 2 - 60, VIRTUAL_HEIGHT / 2 - 75 + 18 * power_Up)
        end
        love.graphics.setFont(gFonts['medium'])
        love.graphics.print ('LIFE BOOST', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 54)
        love.graphics.print ('LIFE DEVIL', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 72)
        love.graphics.print ('SCORE BOOST', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 90)
        love.graphics.print ('SCORE JERK', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 108)
        love.graphics.print ('BALL SPEED UP', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 126)
        love.graphics.print ('BALL SLOW DOWN', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 144)
        love.graphics.print ('BALL MULTIPLIER', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 162)
        love.graphics.print ('LOCKED BLOCK KEY', VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 2 - 75 + 180)
    end

    -- draw special effect on paddle
    love.graphics.draw (self.psystem, self.paddle.x, self.paddle.y)

    -- fade out
    love.graphics.setColor(0, 0, 0, self.transitionBeta)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    --[[ Debug paddle size increase algorithm
    love.graphics.setFont(gFonts['small-normal'])
    love.graphics.print ('LastScoreCP: ' .. tostring(self.lastScoreCheckPoint), VIRTUAL_WIDTH - 80, 30)
    love.graphics.print ('ScoreEvo: ' .. tostring(scoreEvolution), VIRTUAL_WIDTH - 80, 40)]]
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end
    return true
end
