package.path = package.path .. ";../../?.lua;../../?/init.lua;../libs/?.lua;../libs/?/init.lua" -- Small loading hack, not needed in normal times.
local Terminal = require "terminal"
local moonshine = require 'moonshine'
local utf8 = require "utf8"

effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
effect.scanlines.opacity=0.6
effect.glow.min_luma = 0.2


local font = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", 24)
local term = Terminal(14*80, (font:getHeight()-4)*20, font, nil, font:getHeight()-4)
local term_back = Terminal(14*80, (font:getHeight()-4)*20, font, nil, font:getHeight()-4)

-- Tweaking a bit the colors and canvas to get the transparent effect
Terminal.schemes.basic[0][4] = 0

-- This snippet could be interesting
local function clear_canvas(t)
    t.clear_color = {0,0,0,0}
    local previous_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(t.canvas)
    for y=1,t.height do
        for x=1,t.width do
            t.state_buffer[y][x].backcolor = {unpack(t.clear_color)}
            t.buffer[y][x] = " "
        end
    end
love.graphics.setCanvas(previous_canvas)
end
clear_canvas(term)
clear_canvas(term_back)

term:hide_cursor()
term_back:hide_cursor()

term:set_cursor_color(Terminal.schemes.basic[7])
term:set_cursor_backcolor({0,0,0,1})
term:frame("line", 1,1,80,20)
term:reverse_cursor()
term:print(67, 1, "Two layer!")
term:set_cursor_color(Terminal.schemes.basic[7])
term:print(77, 1, "−☐")
term:set_cursor_color(Terminal.schemes.basic[1])
term:print(79, 1, "☠")
term:reverse_cursor()
term:set_cursor_backcolor(Terminal.schemes.basic[0])

function color_this(x, y, str)
    term_back:move_to(x, y)
    local mode = "normal"
    for i,p in utf8.codes(str) do
        local ch = utf8.char(p)
        if ch == "█" then
            if mode ~= "color" then
                mode = "color"
                term_back:set_cursor_color(Terminal.schemes.basic[6])
                term_back:set_cursor_backcolor(Terminal.schemes.basic[5])
            end
            if (i + x) %2 == 1 then
                term_back:print("▀")
            else
                term_back:print("▄")
            end
        else
            if mode ~= "normal" then
                mode = "normal"
                term_back:set_cursor_color(Terminal.schemes.basic[7])
                term_back:set_cursor_backcolor(Terminal.schemes.basic[0])
            end
            term_back:print(ch)
        end
    end
end

term:set_cursor_color(Terminal.schemes.basic[7])

color_this(3,2,[[█    █     █        ██   ██   ██]])
color_this(3,3,[[█    █     █       █ █  █  █ █  █]])
color_this(3,4,[[█     █   █   ███    █  █  █ █  █]])
color_this(3,5,[[█      █ █           █  █  █ █  █]])
color_this(3,6,[[█████   █           ███  ██   ██]])

term:blit(3,2,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
]])

color_this(24,8,[[█    █     █        ██   ██   ██]])
color_this(24,9,[[█    █     █       █ █  █  █ █  █]])
color_this(24,10,[[█     █   █   ███    █  █  █ █  █]])
color_this(24,11,[[█      █ █           █  █  █ █  █]])
color_this(24,12,[[█████   █           ███  ██   ██]])

term:blit(24,8,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
]])

color_this(45,2,[[█    █     █        ██   ██   ██]])
color_this(45,3,[[█    █     █       █ █  █  █ █  █]])
color_this(45,4,[[█     █   █   ███    █  █  █ █  █]])
color_this(45,5,[[█      █ █           █  █  █ █  █]])
color_this(45,6,[[█████   █           ███  ██   ██]])

term:blit(45,2,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
]])

color_this(3,14,[[█    █     █        ██   ██   ██]])
color_this(3,15,[[█    █     █       █ █  █  █ █  █]])
color_this(3,16,[[█     █   █   ███    █  █  █ █  █]])
color_this(3,17,[[█      █ █           █  █  █ █  █]])
color_this(3,18,[[█████   █           ███  ██   ██]])

term:blit(3,14,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
]])

color_this(45,14,[[█    █     █        ██   ██   ██]])
color_this(45,15,[[█    █     █       █ █  █  █ █  █]])
color_this(45,16,[[█     █   █   ███    █  █  █ █  █]])
color_this(45,17,[[█      █ █           █  █  █ █  █]])
color_this(45,18,[[█████   █           ███  ██   ██]])

term:blit(45,14,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
]])


local canvas = love.graphics.newCanvas(800*4, 600*4)
function love.keypressed(key)
    local previous_y = item_y
    if key == "up" and item_y > 0 then
        item_y = item_y - 1
    elseif key == "down" and item_y < 3 then
        item_y = item_y + 1
    end
    if key == "space" then
        glitch_on =  not glitch_on
        print(space)
    end
end

function love.update(dt)
    term:update(dt)
    term_back:update(dt)
end

function love.resize(width, height)
    effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
    effect.scanlines.opacity=0.6
    effect.glow.min_luma = 0.2
end

function love.draw()
    local ww,wh = love.window.getMode()
    -- local v,w = love.mouse.getX()/ww, love.mouse.getY()/wh
    local t = love.timer.getTime()
    local v,w = math.sin(t)/2+.5, -math.cos(t)/2+.5
    local limit = math.floor(v*19+1)
    local spacing = w * 0.10
    effect(function()
        love.graphics.setBlendMode( "alpha" )
        do
            local scale = 0.95
            local scale_x, scale_y = (love.graphics.getWidth()/term.canvas:getWidth())*scale, (love.graphics.getHeight()/term.canvas:getHeight())*scale
            love.graphics.push()
            love.graphics.setColor(1,1,1,1)
            love.graphics.translate((love.graphics.getWidth()*(1-scale))/2, (love.graphics.getHeight()*(1-scale))/2)
            love.graphics.scale(scale_x, scale_y)
            term_back:draw()
            love.graphics.pop()
        end
        do
            local scale = 1
            local scale_x, scale_y = (love.graphics.getWidth()/term.canvas:getWidth())*scale, (love.graphics.getHeight()/term.canvas:getHeight())*scale
            love.graphics.push()
            love.graphics.setColor(1,1,1,0.7)
            love.graphics.translate((love.graphics.getWidth()*(1-scale))/2, (love.graphics.getHeight()*(1-scale))/2)
            love.graphics.scale(scale_x, scale_y)
            term:draw()
            love.graphics.pop()
        end
    end)
end