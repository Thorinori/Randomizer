--Made by Joseph Pace (Thorinori)

--Maybe not needed. Not needed especially until Windows support is the focus.
local sep = package.config:sub(1,1)
if(sep == "/") then
    package.cpath = package.cpath .. ";./libs/UNIX/iup/Lua53/lib?53.so;"
else
    package.cpath = package.cpath .. ";./libs/Windows/iup/Lua53/?53.dll;"
end

iup = require("iuplua")
lfs = require("lfs")
require("Modules/FileIO")
require("Modules/TableFunctions")
require("Modules/Components")

function debug(s)
  if debug_mode then
    multitext.append = s
  end
end

--Instantiate seed
math.randomseed(os.time())

--Configs
config = iup.config{}
config.app_name = "Randomizer"
config:Load()

--Globals
debug_mode = true
comp_actions = {} -- access them with comp_actions[n]() to call all in one loop
data = {}
filedata = {}
current_file = ''
create_rule_panel = iup.hbox{padding="10x5"}
randomization_panel = iup.vbox{visible="NO", padding="10x5", alignment = "ACENTER"}
randomization_scroll = iup.scrollbox{randomization_panel, alignment = "ARIGHT", padding="10x5"}
available_scripts_panel =iup.vbox{visible="YES"}
available_scripts = {}
randomize_all_button = iup.button{title = "Randomize All", padding = "5x5"}
main_panel = iup.vbox{create_rule_panel, available_scripts_panel,randomization_scroll, randomize_all_button, alignment = "ACENTER"}
randomization_panel.alignment = "ACENTER"
randomization_panel.padding = "10x2"
randomization_panel.expandchildren = "YES"

local visible = "NO"
local console = config:GetVariable("MainWindow", "Console")
if console == "YES" then
 visible = "YES"
end
multitext = iup.text{multiline = "YES", expand = "HORIZONTAL", scrollbar = "YES", visiblelines = 12, alignment = "ALEFT", config = config, visible=visible}
--fill = iup.fill{}
--iup.Append(main_panel,fill)
--iup.Map(fill)
iup.Append(main_panel,multitext)
iup.Map(multitext)
iup.Refresh(randomization_panel)   


function randomize_all_button:action()
  
  for _, item in ipairs(comp_actions) do
      item()
      for i = 1, math.random(10) do --Extra random calls to make smaller ranges more varied
        math.random()
      end
  end
end

--Menu Seperator
local horiz_sep = iup.separator{}

--File Menu
local open_button = iup.item{title = "Open...\t Ctrl+O"}
local save_button = iup.item{title = "Save...\t Ctrl+S"}
local saveas_button = iup.item{title = "Save as.."}
local exit_button = iup.item{title = "Exit"}

function open_button:action()
  local open_file_window = iup.filedlg{
    dialogtype = "OPEN",
    filter = "*.lua",
    filterinfo = "Lua Files",
    directory = "./Scripts"
  }

  open_file_window:popup(iup.CENTER,iup.CENTER)

  if (tonumber(open_file_window.status) ~= -1) then
    local fname = open_file_window.value
    filedata = readfile(fname)
    debug("Filedata: ".. filedata)
    load(filedata)()
    current_file = fname
    main_win.title = current_file .. "- Randomizer"
    iup.Refresh(main_win)
    for k,v in ipairs(data) do
        local func = v["func"].."("
        for key, val in ipairs(v["args"]) do
            debug("Type of argument: "..type(val))
            if type(val) == "string" then
              func = func .."\"".. tostring(val).."\","
            elseif type(val) == "table" then
              func = func .. table.tostring(val).."}"
            else
              func = func .. val..","
            end
        end
        func = func:sub(1,-2)
        func = func..")"
        debug(func)
        load(func)()
    end
    debug(table.tostring(data))
  end

  open_file_window:destroy()
end

function open_shortcut(fname)
    filedata = readfile(fname)
    debug("Filedata: ".. filedata)
    load(filedata)()
    current_file = fname
    main_win.title = current_file .. "- Randomizer"
    iup.Refresh(main_win)
    for k,v in ipairs(data) do
      local func = v["func"].."("
      for key, val in ipairs(v["args"]) do
          debug("Type of argument: "..type(val))
          if type(val) == "string" then
            func = func .."\"".. tostring(val).."\","
          else
            func = func .. val
          end
      end
      func = func..")"
      debug(func)
      load(func)()
  end
  debug(table.tostring(data))
end

function save_button:action()
  if(current_file ~= '') then
    writefile(current_file, data)
  else
    iup.Message("Save Warning", "Please use Save As to Save a fresh file!")
  end
end

function saveas_button:action()
  local saveas_file_window = iup.filedlg{
    dialogtype = "SAVE",
    filter = "*.lua",
    directory = "./Scripts"
  }

  saveas_file_window:popup(iup.CENTER,iup.CENTER)
  debug("Hit Save As")

  debug("Starting Save As")
  fname = saveas_file_window.value
  writefile(fname, data)
  debug("Ended Save As")
  current_file = fname    main_win.title = current_file .. "- Randomizer"
  iup.Refresh(main_win)
  saveas_file_window:destroy()
end

function exit_button:action()
  config:DialogClosed(main_win, "MainWindow")
  config:Save()
  config:destroy()
  return iup.CLOSE
end

local file_menu = iup.menu{open_button,save_button,saveas_button,horiz_sep,exit_button}
local file_submenu = iup.submenu{file_menu, title="File"}

--Help Menu
local about_button = iup.item{title="About"}

function about_button:action()
  iup.Message("About", "Randomizer\n\nAuthor:\t Joseph Pace (Thorinori)")
end

local help_menu = iup.menu{about_button}
local help_submenu = iup.submenu{help_menu, title="Help"}

--View Menu

local console_button = iup.item{title="About"}

function console_button:action()
  local curr = multitext.visible
  if curr == "YES" then
    multitext.visible = "NO"
    config:SetVariable("MainWindow", "Console", "NO")
  else
    config:SetVariable("MainWindow", "Console", "YES")
    multitext.visible = "YES"
  end
  iup.Map(multitext)
  iup.Refresh(main_win)
  iup.RefreshChildren(main_win)
end

local view_menu = iup.menu{console_button}
local view_submenu = iup.submenu{view_menu, title="Toggle Console"}

--Main Menu
local menu = iup.menu{file_submenu,view_submenu,help_submenu}

--Create Rule Section
local create_rule_dropdown_button = iup.list{"Random Number", "Random Choice from List", dropdown="YES"}
iup.Append(create_rule_panel,create_rule_dropdown_button)
iup.Refresh(create_rule_panel)

--[[
--Available Scripts Panel (Easy Open Panel)
debug("Looking for scripts")
for file in lfs.dir("./Scripts") do
    if file ~= "." and file ~= ".." then
        local path = "./Scripts/"..file
        table.insert(available_scripts, path)
        print(path)
    end
end


function shortcut_button_action(v)
    open_shortcut(v)
end

for k,v in ipairs(available_scripts) do
  local comp = iup.flatbutton{title=v, action=shortcut_button_action(v)}
  iup.Append(available_scripts_panel, comp)
  iup.Map(comp)
  iup.Refresh(available_scripts_panel)
end
debug("Done looking for scripts")

]]--


main_win = iup.dialog{
  menu=menu,
  main_panel,
  title = "Randomizer",
  size="HALFxHALF",
  close_cb = exit_button.action
}

--Keybinds
function main_win:k_any(c)
  if (c == iup.K_cO) then --Ctrl O
    open_button:action()
  elseif (c == iup.K_cS) then --Ctrl S
    save_button:action()
  end

end

config:DialogShow(main_win, "MainWindow")

-- to be able to run this script inside another context (From IUP Documentation)
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
  iup.Close()
end