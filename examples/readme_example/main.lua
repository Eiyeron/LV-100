package.path = package.path .. ";../../?.lua;../../?/init.lua;../libs/?.lua;../libs/?/init.lua" -- Small loading hack, not needed in normal times.
local Terminal = require "terminal"
local moonshine = require 'moonshine'

effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
effect.scanlines.opacity=0.6
effect.glow.min_luma = 0.2

local font = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", 24) -- Thanks @hicchicc for the font
local term = Terminal(14*80, (font:getHeight()-4)*25, font, nil, font:getHeight()-4)
term:hide_cursor()

term:set_cursor_color(Terminal.schemes.basic[4])
term:frame("line", 1,1,80,25)

term:set_cursor_color(Terminal.schemes.basic[3])
term:blit(3,2,
[[ ___      __   __         ____   _______  _______
|   |    |  | |  |       |    | |  _    ||  _    |
|   |    |  |_|  | ____   |   | | | |   || | |   |
|   |    |       ||____|  |   | | | |   || | |   |
|   |___ |       |        |   | | |_|   || |_|   |
|       | |     |         |   | |       ||       |
|_______|  |___|          |___| |_______||_______|]])

term:set_cursor_color(Terminal.schemes.basic[7])
term:print(55, 8, "By Eiyeron")

term:set_cursor_color(Terminal.schemes.basic[6])
term:print(4, 10, "-A terminal-ish library for Love2D--------------")

term:print(4, 12, "Features")
term:print(4, 14, "☛ Unicode support")
term:print(4, 15, "☛ Slow terminal emulation")
term:print(4, 16, "☛ Helpers")
term:print(4, 16, "☛ Settings (speed, dimensions, font, ...)")

term:print(4, 17, "☛ ")
local text_line = "2 colors per character !"
for i=1,#text_line do
    term:set_cursor_color(Terminal.schemes.basic[i%8])
    term:set_cursor_backcolor(Terminal.schemes.basic[(i+6)%8])
    term:print(text_line:sub(i, i))
end

term:set_cursor_color(Terminal.schemes.basic[6])
term:set_cursor_backcolor(Terminal.schemes.basic[0])
term:reverse_cursor(true)
term:print(4, 18, "☛ Reversed color mode")

term:reverse_cursor()
term:print(4, 22, "Shaders courtesy of the Moonshine library.")
term:print(4, 23, "x14y24HeadUpDaisy font by @hicchicc.")

function love.update(dt)
    term:update(dt)
end

function love.draw()
    love.graphics.clear()
    effect(function()
        love.graphics.push()
        love.graphics.scale(love.graphics.getWidth()/term.canvas:getWidth(), love.graphics.getHeight()/term.canvas:getHeight())
        love.graphics.rectangle("fill", 0,0,term.canvas:getWidth(), term.canvas:getHeight())
        term:draw()
        love.graphics.pop()
    end)
end
