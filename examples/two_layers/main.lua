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

local logo_pos = {
    {3,2},
    {24,8},
    {45, 2},
    {3,14},
    {45,14}
}

for _,pos in ipairs(logo_pos) do
    local x, y = pos[1], pos[2]
    color_this(x,y+0,[[█    █     █        ██   ██   ██]])
    color_this(x,y+1,[[█    █     █       █ █  █  █ █  █]])
    color_this(x,y+2,[[█     █   █   ███    █  █  █ █  █]])
    color_this(x,y+3,[[█      █ █           █  █  █ █  █]])
    color_this(x,y+4,[[█████   █           ███  ██   ██]])

    term:blit(x,y,[[
█    █     █        ██   ██   ██
█    █     █       █ █  █  █ █  █
█     █   █   ███    █  █  █ █  █
█      █ █           █  █  █ █  █
█████   █           ███  ██   ██
    ]])
end

function love.update(dt)
    term:update(dt)
    term_back:update(dt)
end

function love.draw()
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