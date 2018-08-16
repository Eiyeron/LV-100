package.path = package.path .. ";../../?.lua;../../?/init.lua;../libs/?.lua;../libs/?/init.lua" -- Small loading hack, not needed in normal times.
local Terminal = require "terminal"
local moonshine = require 'moonshine'
local utf8 = require "utf8"

effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
effect.scanlines.opacity=0.6
effect.glow.min_luma = 0.2


local font = love.graphics.newFont("x14y24pxHeadUpDaisy.ttf", 24)
local term = Terminal(14*51, (font:getHeight()-4)*25, font, nil, font:getHeight()-4)
term:hide_cursor()

term:set_cursor_color(Terminal.schemes.basic[7])
term:set_cursor_backcolor(Terminal.schemes.basic[0])

function color_this(x, y, str)
    term:move_to(x, y)
    local mode = "normal"
    for i,p in utf8.codes(str) do
        local ch = utf8.char(p)
        if ch == "█" then
            if mode ~= "color" then
                mode = "color"
                term:set_cursor_color(Terminal.schemes.basic[6])
                term:set_cursor_backcolor(Terminal.schemes.basic[5])
            end
            if (i + x) %2 == 1 then
                term:print("▀")
            else
                term:print("▄")
            end
        else
            if mode ~= "normal" then
                mode = "normal"
                term:set_cursor_color(Terminal.schemes.basic[7])
                term:set_cursor_backcolor(Terminal.schemes.basic[0])
            end
            term:print(ch)
        end
    end
end

color_this(5,2,[[██┓    ██┓   ██┓       ██┓ ██████┓  ██████┓ ]])
color_this(5,3,[[██┃    ██┃   ██┃      ███┃██┏━████┓██┏━████┓]])
color_this(5,4,[[██┃    ██┃   ██┃█████┓┗██┃██┃██┏██┃██┃██┏██┃]])
color_this(5,5,[[██┃    ┗██┓ ██┏┛┗━━━━┛ ██┃████┏┛██┃████┏┛██┃]])
color_this(5,6,[[███████┓┗████┏┛        ██┃┗██████┏┛┗██████┏┛]])
color_this(5,7,[[┗━━━━━━┛ ┗━━━┛         ┗━┛ ┗━━━━━┛  ┗━━━━━┛ ]])

term:set_cursor_color(Terminal.schemes.basic[7])
term:set_cursor_backcolor(Terminal.schemes.basic[0])

term:print(4, 9, "Now with two colors per ")
local str = "character!"
for i,c in utf8.codes(str) do
    local ch = utf8.char(c)
    local index_fg, index_bg = (i-1)%8, (i+5)%8
    term:set_cursor_color(Terminal.schemes.basic[index_fg])
    term:set_cursor_backcolor(Terminal.schemes.basic[index_bg])
    term:print(ch)
end
function love.update(dt)
    term:update(dt)
end

function love.resize(width, height)
    effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.glow)
    effect.scanlines.opacity=0.6
    effect.glow.min_luma = 0.2
end

function love.draw()
    effect(function()
        love.graphics.push()
            love.graphics.setColor(1,1,1,0.5)
            love.graphics.scale(love.graphics.getWidth()/term.canvas:getWidth(), love.graphics.getHeight()/term.canvas:getHeight())
            term:draw()
        love.graphics.pop()

        love.graphics.push()
            local sx,sy = 0.95,0.95
            love.graphics.setColor(1,1,1,1)
            love.graphics.scale(love.graphics.getWidth()/term.canvas:getWidth()*sx, love.graphics.getHeight()/term.canvas:getHeight()*sy)
            love.graphics.translate((love.graphics.getWidth()*(1-sx))/2, (love.graphics.getHeight()*(1-sy))/2)
            term:draw()
        love.graphics.pop()
    end)
end