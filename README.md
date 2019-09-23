# Breakout Space Revolution

A remake of the iconic breakout
It is implemented using Lua (Programming Language) and Love2d (Framework).

It uses the classic breakout formula for the game logic while powerups,
player health, particle systems, and persistent data saving(to keep track of highscores) are some additions to the game play.

Other implementations include procedural generation of brick patterns for every new level,
The growth/shrinking of paddle size wih respect to your health or score,
Locked bricks which require a key to be brocken,
A scrolling space background, cool sound effects and sound tracks.

Collision detection is achieved using a simple concept called AABB collision detection.
On top of this is added a logic to determine the bouncing off direction/behaviour of the ball when it hits a brick or paddle.
For instance, the Ball can be given a greater speed by beign hit at an angle with our paddle.
