﻿package.path = package.path .. ";../../?.lua;../../?/init.lua;../libs/?.lua;../libs/?/init.lua" -- Small loading hack, not needed in normal times.
local Terminal = require "terminal"
local moonshine = require 'moonshine'

effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
effect.scanlines.opacity=0.6
effect.glow.min_luma = 0.2


local font = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", 24)
local term = Terminal(14*80, (font:getHeight()-4)*25, font, nil, font:getHeight()-4)

-- Tweaking a bit the colors and canvas to get the transparent effect
term.clear_color = {0,0,0,0}
local previous_canvas = love.graphics.getCanvas()
love.graphics.setCanvas(term.canvas)
love.graphics.clear(term.clear_color)
love.graphics.setCanvas(previous_canvas)

term:hide_cursor()

term:set_cursor_color(Terminal.schemes.basic[7])
term:frame("line", 1,1,80,25)
term:reverse_cursor()
term:print(68, 1, "Layering")
term:set_cursor_color(Terminal.schemes.basic[7])
term:print(77, 1, "−☐")
term:set_cursor_color(Terminal.schemes.basic[1])
term:print(79, 1, "☠")
term:reverse_cursor()

term:set_cursor_color(Terminal.schemes.basic[3])
term:print(3,2,[[ ___      __   __         ____   _______  _______ ]])
term:print(3,3,[[|   |    |  | |  |       |    | |  _    ||  _    |]])
term:print(3,4,[[|   |    |  |_|  | ____   |   | | | |   || | |   |]])
term:print(3,5,[[|   |    |       ||____|  |   | | | |   || | |   |]])
term:print(3,6,[[|   |___ |       |        |   | | |_|   || |_|   |]])
term:print(3,7,[[|       | |     |         |   | |       ||       |]])
term:print(3,8,[[|_______|  |___|          |___| |_______||_______|]])

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
local text_line = "Per character-colors !"
for i=1,#text_line do
    term:set_cursor_color(Terminal.schemes.basic[i%7 +1])
    term:print(text_line:sub(i, i))
end

term:set_cursor_color(Terminal.schemes.basic[6])
term:reverse_cursor(true)
term:print(4, 18, "☛ Reversed color mode")

term:reverse_cursor()
term:print(4, 22, "Shaders courtesy of the Moonshine library.")
term:print(4, 23, "x14y24HeadUpDaisy font by @hicchicc.")

function love.update(dt)
    term:update(dt)
end

function love.draw()
    local ww,wh = love.window.getMode()
    -- local v,w = love.mouse.getX()/ww, love.mouse.getY()/wh
    local t = love.timer.getTime()
    local v,w = math.sin(t)/2+.5, -math.cos(t)/2+.5
    local limit = math.floor(v*19+1)
    local spacing = w * 0.10
    effect(function()
        for i=1,limit do
            love.graphics.push()
                local sq = math.sqrt((i-1)/limit)
                local alpha = 1-sq
                local scale = 1-i*spacing
                local scale_x, scale_y = (love.graphics.getWidth()/term.canvas:getWidth())*scale, (love.graphics.getHeight()/term.canvas:getHeight())*scale
                love.graphics.setColor(1,1,1,alpha)
                love.graphics.translate(400, 300)
                love.graphics.rotate((i-1)*0.02)
                love.graphics.translate(-400, -300)
                love.graphics.translate((love.graphics.getWidth()*(1-scale))/2, (love.graphics.getHeight()*(1-scale))/2)
                love.graphics.scale(scale_x, scale_y)
                term:draw()
            love.graphics.pop()
        end
    end)
end