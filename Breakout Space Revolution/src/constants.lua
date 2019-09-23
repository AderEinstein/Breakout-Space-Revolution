--[[
    GD50 2018
    Breakout Remake

    -- constants --

    Author: Franklin Ader
    adereinstein1@gmail.com

    Some global constants for our application.
]]

-- size of our actual window
WINDOW_WIDTH = 648
WINDOW_HEIGHT = 377

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- Background scrolling variables
BACKGROUND_LOOPING_POINT = 455

BACKGROUND_SCROLL_SPEED = 60


Buttons = {
    ['left-arrow'] = {
        texture = 'arrows',
        frame = 1,
        width = 24,
        height = 24,
        x = VIRTUAL_WIDTH / 4 - 24,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    },
    ['right-arrow'] = {
        texture = 'arrows',
        frame = 2,
        width = 24,
        height = 24,
        x = VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    },
    ['select-button'] = {
        texture = 'select-button',
        frame = 1,
        width = 71,
        height = 25,
        x = VIRTUAL_WIDTH / 2 - 35,
        y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3 + 30
    },

    ['back'] = {
        texture = 'arrows',
        frame = 1,
        width = 24,
        height = 24,
        x = 5,
        y = 5
    },

    ['pause'] = {
        texture = 'arrows',
        frame = 3,
        width = 24,
        height = 24,
        x = 5,
        y = 30  
    },

    ['start'] = {
        x = VIRTUAL_WIDTH / 2 - 26.5,
        y = VIRTUAL_HEIGHT / 2 + 69,
        width = 52,
        height = 20
    },

    ['high-scores'] = {
        x = VIRTUAL_WIDTH / 2 - 60,
        y = VIRTUAL_HEIGHT / 2 + 70 + 20,
        width = 120,
        height = 20
    }

}