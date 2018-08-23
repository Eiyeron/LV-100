-- LV-100

-- TODO : rethink character coloring to simplify stuff

local utf8 = require("utf8")

-- The good old 3-bit color scheme.
local basic_scheme = {
    [0] = {0,0,0,1},
    {1,0,0,1},
    {0,1,0,1},
    {1,1,0,1},
    {0,0,1,1},
    {1,0,1,1},
    {0,1,1,1},
    {1,1,1,1}
}

-- Origin of this snippet : https://stackoverflow.com/a/43139063
local function utf8_sub(s,i,j)
    i=utf8.offset(s,i)
    j=utf8.offset(s,j+1)-1
    return string.sub(s,i,j)
end

local function terminal_update_character(terminal, x, y, new_char)
    terminal.buffer[y][x] = new_char
    local char_color = terminal.cursor_color
    local char_backcolor = terminal.cursor_backcolor
    terminal.state_buffer[y][x].color = {char_color[1], char_color[2], char_color[3], char_color[4]}
    terminal.state_buffer[y][x].backcolor = {char_backcolor[1], char_backcolor[2], char_backcolor[3], char_backcolor[4]}
    terminal.state_buffer[y][x].reversed = terminal.cursor_reversed
    terminal.state_buffer[y][x].dirty = true
end

local function terminal_hide_cursor(terminal)
    table.insert(terminal.stdin, {type="hide_cursor"})
end

local function terminal_show_cursor(terminal)
    table.insert(terminal.stdin, {type="show_cursor"})
end

local function terminal_set_cursor_color(terminal, red, blue, green, alpha)
    -- Argument processing
    if type(red) == "table" and blue == nil then
        red, blue, green, alpha = red[1], red[2], red[3], red[4]
    end
    table.insert(terminal.stdin, {type="cursor_color", red=red, blue=blue, green=green, alpha=(alpha or 1)})
end

local function terminal_set_cursor_backcolor(terminal, red, blue, green, alpha)
    -- Argument processing
    if type(red) == "table" and blue == nil then
        red, blue, green, alpha = red[1], red[2], red[3], red[4]
    end
    table.insert(terminal.stdin, {type="cursor_backcolor", red=red, blue=blue, green=green, alpha=(alpha or 1)})
end


local function terminal_move_to(terminal, x, y)
    table.insert(terminal.stdin, {type="move", x=math.floor(x), y=math.floor(y)})
end

local function terminal_reverse(terminal, set)
    table.insert(terminal.stdin, {type="reverse", value=set})
end

local function terminal_clear(terminal, x, y, w, h)
    x = x or 1
    y = y or 1
    w = w or terminal.width
    h = h or terminal.height
    table.insert(terminal.stdin, {type="clear", x=x, y=y, w=w, h=h})
end

local line_style = "┌┐└┘─│"
local thick_style = "┏┓┗┛━┃"
local block_style = "██████"
local function terminal_frame(terminal, style, x, y, w, h)
    table.insert(terminal.stdin, {type="frame", style=style, x=math.floor(x), y=math.floor(y), w=math.floor(w), h=math.floor(h)})
end

local function terminal_roll_up(terminal, how_many)
    for times=1,how_many do
        local first_row = terminal.buffer[1]
        for y=2,terminal.height do
            terminal.buffer[y-1] = terminal.buffer[y]
        end
        terminal.buffer[terminal.height] = first_row
        for i=1,terminal.width do
            first_row[i] = ' '
        end
    end
end

local function wrap_if_bottom(terminal)
    if terminal.cursor_y > terminal.height then
        terminal_roll_up(terminal, terminal.cursor_y - terminal.height)
        terminal.cursor_y = terminal.height
    end
end

local function terminal_update(terminal, dt)
    if #terminal.stdin == 0 then return end
    local frame_budget = terminal.speed * dt + terminal.accumulator
    local stdin_index = 1
    while frame_budget > terminal.char_cost do
        local char_or_command = terminal.stdin[stdin_index]
        if char_or_command == nil then break end
        stdin_index = stdin_index + 1
        frame_budget = frame_budget - terminal.char_cost

        if type(char_or_command) == "string" then
            if char_or_command == '\b' then
                terminal.cursor_x = math.max(terminal.cursor_x - 1, 1)
            elseif char_or_command == '\n' then
                terminal.cursor_x = 1
                terminal.cursor_y = terminal.cursor_y + 1
                wrap_if_bottom(terminal)
            else
                terminal_update_character(terminal, terminal.cursor_x, terminal.cursor_y, char_or_command)
                terminal.cursor_x = terminal.cursor_x + 1
                if terminal.cursor_x > terminal.width then
                    terminal.cursor_x = 1
                    terminal.cursor_y = terminal.cursor_y + 1
                    wrap_if_bottom(terminal)
                end
                terminal.dirty = true
            end
        elseif char_or_command.type == "clear" then
            local x,y,w,h = char_or_command.x or 1, char_or_command.y or 1, char_or_command.w or terminal.width, char_or_command.h or terminal.h
            for y=y,y+h-1 do
                for x=x,x+w-1 do
                    terminal_update_character(terminal, x, y, " ")
                    terminal.buffer[y][x] = " "
                end
            end
            terminal.dirty = true
        elseif char_or_command.type == "hide_cursor" then
            terminal.show_cursor = false
        elseif char_or_command.type == "show_cursor" then
            terminal.show_cursor = true
        elseif char_or_command.type == "cursor_color" then
            terminal.cursor_color[1] =  char_or_command.red
            terminal.cursor_color[2] = char_or_command.blue
            terminal.cursor_color[3] = char_or_command.green
            terminal.cursor_color[4] = char_or_command.alpha
        elseif char_or_command.type == "cursor_backcolor" then
            terminal.cursor_backcolor[1] =  char_or_command.red
            terminal.cursor_backcolor[2] = char_or_command.blue
            terminal.cursor_backcolor[3] = char_or_command.green
            terminal.cursor_backcolor[4] = char_or_command.alpha
        elseif char_or_command.type == "move" then
            terminal.cursor_x = char_or_command.x
            terminal.cursor_y = char_or_command.y
        elseif char_or_command.type == "reverse" then
            terminal.cursor_reversed = (char_or_command.value ~= nil) and char_or_command.value or not terminal.cursor_reversed
        elseif char_or_command.type == "save" then
            terminal.saved_cursor_x = terminal.cursor_x
            terminal.saved_cursor_y = terminal.cursor_y
        elseif char_or_command.type == "load" then
            terminal.cursor_x = terminal.saved_cursor_x
            terminal.cursor_y = terminal.saved_cursor_y
        elseif char_or_command.type == "frame" then
            local style = char_or_command.style
            if style == "line" then
                style = line_style
            elseif style == "thick" then
                style = thick_style
            elseif style == "block" then
                style = block_style
            else
                assert(false, string.format("Unrecognized style %s", style))
            end

            local buffer = terminal.buffer
            local state_buffer = terminal.state_buffer
            local char_color = terminal.cursor_color
            local x,y,width,height = char_or_command.x, char_or_command.y, char_or_command.w, char_or_command.h

            local left, right = x, x+width - 1
            local top, bottom = y, y+height - 1
            terminal_update_character(terminal, left, top, utf8_sub(style,1,1))
            terminal_update_character(terminal, right, top, utf8_sub(style,2,2))
            terminal_update_character(terminal, left, bottom, utf8_sub(style,3,3))
            terminal_update_character(terminal, right, bottom, utf8_sub(style,4,4))

            local horizontal_char = utf8_sub(style, 5, 5)
            local vertical_char = utf8_sub(style, 6, 6)
            for i=left+1, right-1 do
                terminal_update_character(terminal, i, top, horizontal_char)
                terminal_update_character(terminal, i, bottom, horizontal_char)
            end
            for i=top+1, bottom-1 do
                terminal_update_character(terminal, left, i, vertical_char)
                terminal_update_character(terminal, right, i, vertical_char)
            end
            terminal.dirty = true
        else
            assert(false, "Unrecognized command", char_or_command.type)
        end
    end
    terminal.accumulator = frame_budget
    local rest = {}
    for i=stdin_index,#terminal.stdin do
        table.insert(rest, terminal.stdin[i])
    end
    terminal.stdin = rest
end

local function terminal_draw(terminal)
    local char_width, char_height = terminal.char_width, terminal.char_height
    if terminal.dirty then
        local previous_color = {love.graphics.getColor()}
        local previous_canvas = love.graphics.getCanvas()

        love.graphics.push()
        love.graphics.origin()

        love.graphics.setCanvas(terminal.canvas)
        -- love.graphics.clear(unpack(terminal.clear_color))
        love.graphics.setFont(terminal.font)
        local font_height = terminal.font:getHeight()
        for y,row in ipairs(terminal.buffer) do
            for x,char in ipairs(row) do
                local state = terminal.state_buffer[y][x]
                if state.dirty then
                    local left, top = (x-1)*char_width, (y-1)*char_height
                    -- Character background
                    if state.reversed then
                        love.graphics.setColor(unpack(state.color))
                    else
                        love.graphics.setColor(unpack(state.backcolor))
                    end
                    love.graphics.rectangle("fill", left, top + (font_height - char_height), terminal.char_width, terminal.char_height)

                    -- Character
                    if state.reversed then
                        love.graphics.setColor(unpack(state.backcolor))
                    else
                        love.graphics.setColor(unpack(state.color))
                    end
                    love.graphics.print(char, left, top)
                    state.dirty = false
                end
            end
        end
        terminal.dirty = false
        love.graphics.pop()

        love.graphics.setCanvas(previous_canvas)
        love.graphics.setColor(unpack(previous_color))
    end

    love.graphics.draw(terminal.canvas)
    if terminal.show_cursor then
        love.graphics.setFont(terminal.font)
            if love.timer.getTime()%1 > 0.5 then
            love.graphics.print("_", (terminal.cursor_x-1) * char_width, (terminal.cursor_y -1) * char_height)
        end
    end
end

local function terminal_print(terminal, x, y, ...)
    local res_string = nil

    -- argument processing
    -- shortcut : no coordinates => print at cursor position
    if type(x) == "string" then
        res_string = x
    else
        terminal:move_to(x, y)
        res_string = string.format(...)
    end

    for i,p in utf8.codes(res_string) do
        table.insert(terminal.stdin, utf8.char(p))
    end
end

local function terminal_blit(terminal, x, y, str)
    for line in str:gmatch("[^\r\n]+") do
        terminal_print(terminal, x, y, "%s", line)
        y = y + 1
    end
end


local function terminal_save_position(terminal)
    table.insert(terminal.stdin, {type="save"})

end

local function terminal_load_position(terminal)
    table.insert(terminal.stdin, {type="load"})
end


local function terminal (self, width, height, font, custom_char_width, custom_char_height)
    local char_width = custom_char_width or font:getWidth('█')
    local char_height = custom_char_height or font:getHeight()
    local num_columns = math.floor(width/char_width)
    local num_rows = math.floor(height/char_height)
    local instance = {
        width = math.floor(num_columns),
        height = math.floor(num_rows),
        font = font,

        show_cursor = true,
        cursor_x = 1,
        cursor_y = 1,
        saved_cursor_x = 1,
        saved_cursor_y = 1,
        cursor_color = {1,1,1,1},
        cursor_backcolor = {0,0,0,1},
        cursor_reversed = false,

        dirty = false,
        char_width = char_width,
        char_height = char_height,

        speed = 800,
        char_cost = 1,
        accumulator = 0,
        stdin = {},

        clear_color = {0,0,0},

        canvas = love.graphics.newCanvas(width, height),
        buffer = {},
        state_buffer = {}
    }

    for i=1,num_rows do
        local row = {}
        local state_row = {}
        for j=1,num_columns do
            row[j] = ' '
            state_row[j] = {
                color = {1,1,1,1},
                backcolor = {0,0,0,1},
                dirty = true
            }
        end
        instance.buffer[i] = row
        instance.state_buffer[i] = state_row
    end

    instance.update = terminal_update
    instance.draw = terminal_draw
    instance.print = terminal_print
    instance.blit = terminal_blit
    instance.clear = terminal_clear
    instance.save_position = terminal_save_position
    instance.load_position = terminal_load_position
    instance.move_to = terminal_move_to
    instance.hide_cursor = terminal_hide_cursor
    instance.show_cursor = terminal_show_cursor
    instance.reverse_cursor = terminal_reverse
    instance.set_cursor_color = terminal_set_cursor_color
    instance.set_cursor_backcolor = terminal_set_cursor_backcolor

    instance.frame = terminal_frame

    local previous_canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(instance.canvas)
    love.graphics.clear(instance.clear_color)
    love.graphics.setCanvas(previous_canvas)

    return instance
end

local module = {
    _VERSION = 'lv-100 v0.0.1',
    _DESCRIPTION = "A simple terminal-like emulator for Love2D",
    _URL = "https://github.com/Eiyeron/LV-100",
    _LICENCE = [[
MIT License

Copyright (c) 2018 Florian Dormont

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]],
    terminal = terminal,
    schemes = {
        basic = basic_scheme
    }
}
setmetatable(module, {__call = module.terminal})

return module