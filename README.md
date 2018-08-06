# LV-100
A Love2D library to make terminal-like stuff

## Note
This is a WIP repo. I haven't studied or to make a proper library for Lua/Love2D.

![Screenshot of the result of the following code](https://raw.githubusercontent.com/Eiyeron/LV-100/master/screenshot.png)

```lua
local Terminal = require "terminal"
local moonshine = require 'moonshine'

effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
effect.scanlines.opacity=0.6
effect.glow.min_luma = 0.2

local font = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", 24) -- Thanks @hicchicc for the font
local term = Terminal(14*80, (font:getHeight()-4)*25, font, nil, font:getHeight()-4)

term:frame("line", 1,1,80,25)

term:print(3,2,[[ ___      __   __         ____   _______  _______ ]])
term:print(3,3,[[|   |    |  | |  |       |    | |  _    ||  _    |]])
term:print(3,4,[[|   |    |  |_|  | ____   |   | | | |   || | |   |]])
term:print(3,5,[[|   |    |       ||____|  |   | | | |   || | |   |]])
term:print(3,6,[[|   |___ |       |        |   | | |_|   || |_|   |]])
term:print(3,7,[[|       | |     |         |   | |       ||       |]])
term:print(3,8,[[|_______|  |___|          |___| |_______||_______|]])

term:print(55, 8, "By Eiyeron")

term:print(4, 10, "-A terminal-ish library for Love2D--------------")

term:print(4, 12, "Features")
term:print(4, 14, "☛ Unicode support")
term:print(4, 15, "☛ Slow terminal emulation")
term:print(4, 16, "☛ Helpers")
term:print(4, 16, "☛ Settings (speed, dimensions, font, ...)")

function love.update(dt)
    term:update(dt)
end

function love.draw()
    love.graphics.clear()
    effect(function()
        love.graphics.push()
        love.graphics.scale(love.graphics.getWidth()/term.canvas:getWidth(), love.graphics.getHeight()/term.canvas:getHeight())
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0,0,term.canvas:getWidth(), term.canvas:getHeight())
        love.graphics.setColor(0.964, 0.635, 0.156)
        term:draw()
        love.graphics.pop()
    end)
end
```

Note : the CRT effect is done with [moonshine's](https://github.com/vrld/moonshine) shaders.