-------------------------------------------------
-- CPU Widget for Awesome Window Manager
-- Shows the current CPU utilization
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/cpu-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. '/.config/awesome/awesome-wm-widgets/cpu-widget'

local widget = {}
local cpu_rows = {
    spacing = 4,
    layout = wibox.layout.fixed.vertical,
}
local is_update = true
local process_rows = {
    layout = wibox.layout.fixed.vertical,
}

-- Splits the string by separator
-- @return table with separated substrings
local function split(string_to_split, separator)
    if separator == nil then separator = "%s" end
    local t = {}

    for str in string.gmatch(string_to_split, "([^".. separator .."]+)") do
        table.insert(t, str)
    end

    return t
end

-- Checks if a string starts with a another string
local function starts_with(str, start)
    return str:sub(1, #start) == start
end


local function create_textbox(args)
    return wibox.widget{
        font = 'Sans 10',
        text = args.text,
        align = args.align or 'left',
        markup = args.markup,
        forced_width = args.forced_width or 50,
        widget = wibox.widget.textbox
    }
end

local function create_process_header(params)
    local res = wibox.widget{
        create_textbox{markup = '<b>PID</b>'},
        create_textbox{markup = '<b>Name</b>'},
        {
            create_textbox{markup = '<b>CPU</b>'},
            create_textbox{markup = '<b>MEM</b>'},
            params.with_action_column and create_textbox{forced_width = 20} or nil,
            layout = wibox.layout.align.horizontal
        },
        layout  = wibox.layout.ratio.horizontal
    }
    res:ajust_ratio(2, 0.2, 0.47, 0.33)

    return res
end

local function create_kill_process_button()
    return wibox.widget{
        {
            id = "icon",
            image = WIDGET_DIR .. '/window-close-symbolic.svg',
            resize = false,
            opacity = 0.1,
            widget = wibox.widget.imagebox
        },
        widget = wibox.container.background
    }
end

local function worker(args)

    local args = args or {}

    local width = args.width or 80
    local step_width = args.step_width or 2
    local step_spacing = args.step_spacing or 1
    local color = args.color or beautiful.fg_normal
    local enable_kill_button = args.enable_kill_button or true
    local process_info_max_length = args.process_info_max_length or -1

    local cpugraph_widget = wibox.widget {
        max_value = 100,
        background_color = "#00000000",
        forced_width = width,
        step_width = step_width,
        step_spacing = step_spacing,
        widget = wibox.widget.graph,
        color = "linear:0,0:0,20:0,#FF0000:0.3,#FFFF00:0.6," .. color
    }

    local popup = awful.popup{
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_width = 1,
        border_color = beautiful.bg_normal,
        maximum_width = 400,
        offset = { y = 5 },
        widget = {}
    }

    -- Do not update process rows when mouse cursor is over the widget
    popup:connect_signal("mouse::enter", function(c) is_update = false end)
    popup:connect_signal("mouse::leave", function(c) is_update = true end)

    cpugraph_widget:buttons(
            awful.util.table.join(
                    awful.button({}, 1, function()
                        if popup.visible then
                            popup.visible = not popup.visible
                        else
                            popup:move_next_to(mouse.current_widget_geometry)
                        end
                    end)
            )
    )

    --- By default graph widget goes from left to right, so we mirror it and push up a bit
    local cpu_widget = wibox.container.margin(wibox.container.mirror(cpugraph_widget, { horizontal = true }), 0, 0, 0, 2)

    local cpus = {}
    watch([[bash -c "cat /proc/stat | grep '^cpu.' ; ps -eo '%p|%c|%C|' -o "%mem" -o '|%a' --sort=-%cpu | head -11 | tail -n +2"]], 1,
            function(widget, stdout)
                local i = 1
                local j = 1
                for line in stdout:gmatch("[^\r\n]+") do
                    if starts_with(line, 'cpu') then

                        if cpus[i] == nil then cpus[i] = {} end

                        local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
                            line:match('(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')

                        local total = user + nice + system + idle + iowait + irq + softirq + steal

                        local diff_idle = idle - tonumber(cpus[i]['idle_prev'] == nil and 0 or cpus[i]['idle_prev'])
                        local diff_total = total - tonumber(cpus[i]['total_prev'] == nil and 0 or cpus[i]['total_prev'])
                        local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

                        cpus[i]['total_prev'] = total
                        cpus[i]['idle_prev'] = idle

                        if i == 1 then
                            widget:add_value(diff_usage)
                        end

                        local row = wibox.widget
                        {
                            create_textbox{text = name},
                            create_textbox{text = math.floor(diff_usage) .. '%'},
                            {
                                max_value = 100,
                                value = diff_usage,
                                forced_height = 20,
                                forced_width = 150,
                                paddings = 1,
                                margins = 4,
                                border_width = 1,
                                border_color = beautiful.bg_focus,
                                background_color = beautiful.bg_normal,
                                bar_border_width = 1,
                                bar_border_color = beautiful.bg_focus,
                                color = "linear:150,0:0,0:0,#D08770:0.3,#BF616A:0.6," .. beautiful.fg_normal,
                                widget = wibox.widget.progressbar,

                            },
                            layout  = wibox.layout.ratio.horizontal
                        }
                        row:ajust_ratio(2, 0.15, 0.15, 0.7)
                        cpu_rows[i] = row
                        i = i + 1
                    else
                        if is_update == true then

                            local columns = split(line, '|')

                            local pid = columns[1]
                            local comm = columns[2]
                            local cpu = columns[3]
                            local mem = columns[4]
                            local cmd = columns[5]

                            local kill_proccess_button = enable_kill_button and create_kill_process_button() or nil

                            local pid_name_rest = wibox.widget{
                                create_textbox{text = pid, align = 'left'},
                                create_textbox{text = comm},
                                {
                                    create_textbox{text = cpu, align = 'center'},
                                    create_textbox{text = mem, align = 'center'},
                                    kill_proccess_button,
                                    layout = wibox.layout.fixed.horizontal
                                },
                                layout  = wibox.layout.ratio.horizontal
                            }
                            pid_name_rest:ajust_ratio(2, 0.2, 0.47, 0.33)

                            local row = wibox.widget {
                                {
                                    pid_name_rest,
                                    top = 4,
                                    bottom = 4,
                                    widget = wibox.container.margin
                                },
                                widget = wibox.container.background
                            }

                            row:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.bg_focus) end)
                            row:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_normal) end)
                            
                            if enable_kill_button then
                                row:connect_signal("mouse::enter", function(c) kill_proccess_button.icon.opacity = 1 end)
                                row:connect_signal("mouse::leave", function(c) kill_proccess_button.icon.opacity = 0.1 end)
                                
                                kill_proccess_button:buttons(
                                    awful.util.table.join( awful.button({}, 1, function() 
                                        row:set_bg('#ff0000')
                                        awful.spawn.with_shell('kill -9 ' .. pid)
                                    end) ) )
                            end

                            awful.tooltip {
        font = 'Sans 10',
                                objects = { row },
                                mode = 'outside',
                                preferred_positions = {'bottom'},
                                timer_function = function()
                                    local text = cmd
                                    if process_info_max_length > 0 and text:len() > process_info_max_length then
                                        text = text:sub(0, process_info_max_length - 3) .. '...'
                                    end

                                    return text
                                            :gsub('%s%-', '\n\t-') -- put arguments on a new line
                                            :gsub(':/', '\n\t\t:/') -- java classpath uses : to separate jars
                                end,
                            }

                            process_rows[j] = row

                            j = j + 1
                        end

                    end
                end
                popup:setup {
                    {
                        cpu_rows,
                        {
                            orientation = 'horizontal',
                            forced_height = 15,
                            color = beautiful.bg_focus,
                            widget = wibox.widget.separator
                        },
                        create_process_header{with_action_column = enable_kill_button},
                        process_rows,
                        layout = wibox.layout.fixed.vertical,
                    },
                    margins = 8,
                    widget = wibox.container.margin
                }
            end,
            cpugraph_widget
    )

    return cpu_widget
end

return setmetatable(widget, { __call = function(_, ...)
    return worker(...)
end })
