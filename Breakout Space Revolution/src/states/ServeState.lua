--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Franklin Ader
    adereinstein1@gmail.com

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.lastScoreCheckPoint = params.lastScoreCheckPoint == nil and 0 or params.lastScoreCheckPoint
    -- init new ball (random color for fun) and put it in the ball table
    self.ball = Ball(math.random(7))
    
    self.balls = {}
    table.insert(self.balls, self.ball)

    self.backgroundScroll = 0

     -- Play state sound
     gSounds['music-intro']:stop()
     gSounds['music-game']:play()
     gSounds['music-game']:setLooping(true)
     gSounds['music-game']:setVolume(0.3)
    
    -- Nav Button(s)
    self.backButton = Button(Buttons['back'])
    self.pauseButton = Button(Buttons['pause']) 
end

function ServeState:update(dt)

    self.backgroundScroll = (self.backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- have the ball track the player
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
        self.ball.y = self.paddle.y - 8
    end

    -- grab mouse coordinates
    local x, y = push:toGame(love.mouse.getPosition())

    if love.mouse.wasPressed(1) and MouseIn(self.backButton, x, y) then
        gStateMachine:change('start', { highScores = loadHighScores() })
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.mouse.wasPressed(1)  then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            balls = self.balls,
            level = self.level,
            lastScoreCheckPoint = self.lastScoreCheckPoint,
            backgroundScroll = self.backgroundScroll
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()

    --render scrolling background
    love.graphics.draw(gTextures['background-game'], 
        -- draw at coordinates 0, -backgroundScroll
        0, -self.backgroundScroll, 
        -- no rotation
        0)

    self.paddle:render()
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    self.backButton:render()

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium-normal'])
    love.graphics.printf('Press Enter or Tap screen to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end