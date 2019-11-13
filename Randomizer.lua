--Made by Joseph Pace (Thorinori)

--Maybe not needed. Not needed especially until Windows support is the focus.
local sep = package.config:sub(1,1)
if(sep == "/") then
    package.cpath = package.cpath .. ";./libs/UNIX/iup/Lua53/lib?53.so;"
else
    package.cpath = package.cpath .. ";./libs/Windows/iup/Lua53/?53.dll;"
end

iup = require("iuplua")
require("Modules/FileIO")
require("Modules/TableFunctions")
require("Modules/Components")

function init_panel()
  randomization_panel = iup.vbox{}
  randomization_panel.alignment = "ACENTER"
  randomization_panel.padding = "10x2"
  randomization_panel.expandchildren = "YES"
end

--Globals
dialogs = {}
data = {}
current_file = ''
randomization_panel = iup.vbox{}
randomization_panel.alignment = "ACENTER"
randomization_panel.padding = "10x2"
randomization_panel.expandchildren = "YES"

--Configs
config = iup.config{}
config.app_name = "Randomizer"
config:Load()

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
    local filedata = readfile(fname)
    load(filedata)()
    current_file = fname
    for k,v in ipairs(data) do
      v()
    end
  end

  open_file_window:destroy()
end

function save_button:action()
  writefile(current_file, data)
end

function saveas_button:action()
  local saveas_file_window = iup.filedlg{
    dialogtype = "SAVE",
    filter = "*.lua",
    directory = "./Scripts"
  }

  saveas_file_window:popup(iup.CENTER,iup.CENTER)

  if (tonumber(saveas_file_window.status) == 1) then
    fname = saveas_file_window.value
    writefile(fname, data)
    current_file = fname
  end
  saveas_file_window:destroy()
end

function exit_button:action()
  return iup.CLOSE
end

local file_menu = iup.menu{open_button,save_button,saveas_button,horiz_sep,exit_button}
local file_submenu = iup.submenu{file_menu, title="File"}

--Main Menu
local menu = iup.menu{file_submenu}

--Main Window
main_win = iup.dialog{
  menu=menu,
  randomization_panel,
  title = "Randomizer",
  size="HALFxHALF"
}


dialogs.main = main_win

main_win:showxy(iup.CENTER,iup.CENTER)

-- to be able to run this script inside another context (From IUP Documentation)
if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
  iup.Close()
end